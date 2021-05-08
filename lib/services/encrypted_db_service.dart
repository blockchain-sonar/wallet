// Copyright 2021 Free TON Wallet Team

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

// 	http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import "dart:async" show Future;
import "dart:collection" show UnmodifiableSetView;
import "dart:convert"
    show base64Decode, base64Encode, jsonDecode, jsonEncode, utf8;
import "dart:html" show window;
import "dart:typed_data" show Uint8List;
import "dart:math" show max;

import "package:freemework/freemework.dart"
    show FreemeworkException, InvalidOperationException;
import "../data/key_pair.dart" show KeyPair;

import "../data/mnemonic_phrase.dart" show MnemonicPhrase;

import "crypto_service.dart" show CryptoService, DerivateResult, Encypter;

abstract class EncryptedDbService {
  bool get isInitialized;

  /// Resotre an encryption key by salt and iterations saved in DB.
  /// The encryption key is needed to `read` data set.
  Future<Uint8List> derivateEncryptionKey(String masterPassword);

  /// Uncrypt/Read data set.
  Future<DataSet> read(Uint8List encryptionKey);

  /// Wipe all data (re-initialize)
  ///
  /// Returns new encryption key
  Future<Uint8List> wipe(String masterPassword);

  Future<void> write(DataSet data);
}

abstract class DataSet {
  Uint8List get encryptionKey;

  WalletDataPlain addPlainWallet(
    String title,
    KeyPair keyPair,
    MnemonicPhrase? mnemonicPhrase,
  );
  UnmodifiableSetView<WalletData> get wallets;
  Map<String, dynamic> toJson();

  DataSet._(); // internal
}

abstract class WalletData {
  final int id;

  factory WalletData.fromJson(final Map<String, dynamic> rawJson) {
    final int? id = rawJson[WalletData._ID__PROPERTY];
    final String? kind = rawJson[_KIND__PROPERTY];

    if (id == null) {
      throw SerializationException(
          "A field '${WalletData._ID__PROPERTY}' is null");
    }
    if (kind == null) {
      throw SerializationException("A field '$_KIND__PROPERTY' is null");
    }

    switch (kind) {
      case "plain":
        return WalletDataPlain.fromJson(id, rawJson);
      default:
        throw SerializationException(
            "A field '$_KIND__PROPERTY' has unsupported value '$kind'.");
    }
  }

  Map<String, dynamic> toJson() {
    String kind;
    if (this is WalletDataPlain) {
      kind = "plain";
    } else {
      throw SerializationException(
          "Cannot serialize a field '$_KIND__PROPERTY'. Cannot resolve text representation by runtimeType '${this.runtimeType}'.");
    }

    final Map<String, dynamic> rawJson = <String, dynamic>{
      _ID__PROPERTY: this.id,
      _KIND__PROPERTY: kind
    };

    return rawJson;
  }

  static const String _ID__PROPERTY = "id";
  static const String _KIND__PROPERTY = "kind";

  WalletData._(this.id);
}

class WalletDataPlain extends WalletData {
  final String walletName;
  final String keyPublic;
  final String keySecret;
  final MnemonicPhrase? mnemonicPhrase;

  factory WalletDataPlain.fromJson(
    final int id,
    final Map<String, dynamic> rawJson,
  ) {
    final String? keyPublic = rawJson[_KEY_PUBLIC__PROPERTY];
    final String? keySecret = rawJson[_KEY_SECRET__PROPERTY];
    final String? mnemonicPhraseSentence = rawJson[_MNEMONIC_PHRASE__PROPERTY];
    final String? walletName = rawJson[_WALLET_NAME__PROPERTY];

    if (keyPublic == null) {
      throw SerializationException("A field '$_KEY_PUBLIC__PROPERTY' is null");
    }
    if (keySecret == null) {
      throw SerializationException("A field '$_KEY_SECRET__PROPERTY' is null");
    }
    if (walletName == null) {
      throw SerializationException("A field '$_WALLET_NAME__PROPERTY' is null");
    }

    MnemonicPhrase? mnemonicPhrase = null;
    if (mnemonicPhraseSentence != null) {
      try {
        mnemonicPhrase = MnemonicPhrase.parse(mnemonicPhraseSentence);
      } catch (e) {
        throw SerializationException(
          "A field '$_MNEMONIC_PHRASE__PROPERTY' cannot be parsed.",
          FreemeworkException.wrapIfNeeded(e),
        );
      }
    }

    return WalletDataPlain._(
      id,
      walletName,
      keyPublic,
      keySecret,
      mnemonicPhrase,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> rawJson = super.toJson()
      ..addAll(<String, dynamic>{
        _KEY_PUBLIC__PROPERTY: this.keyPublic,
        _KEY_SECRET__PROPERTY: this.keySecret,
        _WALLET_NAME__PROPERTY: this.walletName,
      });

    final MnemonicPhrase? mnemonicPhrase = this.mnemonicPhrase;
    if (mnemonicPhrase != null) {
      rawJson[_MNEMONIC_PHRASE__PROPERTY] = mnemonicPhrase.sentence;
    }

    return rawJson;
  }

  static const String _KEY_PUBLIC__PROPERTY = "keypub";
  static const String _KEY_SECRET__PROPERTY = "keysecret";
  static const String _MNEMONIC_PHRASE__PROPERTY = "mnemonic";
  static const String _WALLET_NAME__PROPERTY = "name";

  WalletDataPlain._(int id, this.walletName, this.keyPublic, this.keySecret,
      this.mnemonicPhrase)
      : super._(id);
}

// class WalletDataEncrypted extends WalletData {
//   WalletDataEncrypted._(int id) : super._(id);
// }

class DatabaseServiceException extends FreemeworkException {
  DatabaseServiceException(String message, FreemeworkException? innerException)
      : super(message, innerException);
}

class DatabaseCorruptedException extends DatabaseServiceException {
  DatabaseCorruptedException(
      [String message = "Database corrupted",
      FreemeworkException? innerException])
      : super("${message} ${innerException?.message}", innerException);
}

class SerializationException extends FreemeworkException {
  SerializationException(String message, [FreemeworkException? innerException])
      : super(message, innerException);
}

class WrongMasterPasswordException extends DatabaseServiceException {
  WrongMasterPasswordException(String message,
      [FreemeworkException? innerException])
      : super(message, innerException);
}

const String _DataServiceLocalStorageMetaKey =
    "org.freeton-wallet.schema.localstoragedb-meta-v0.0.0";
const String _DataServiceLocalStorageDataKey =
    "org.freeton-wallet.schema.localstoragedb-data-v0.0.0";

class LocalStorageEncryptedDbService extends EncryptedDbService {
  final CryptoService _cryptoService;

  LocalStorageEncryptedDbService(this._cryptoService);

  @override
  bool get isInitialized =>
      window.localStorage.containsKey(_DataServiceLocalStorageMetaKey) &&
      window.localStorage.containsKey(_DataServiceLocalStorageDataKey);

  @override
  Future<Uint8List> derivateEncryptionKey(String masterPassword) async {
    _DataServiceLocalStorageMeta dbMetaData;
    try {
      final String? dbMetaSerialized =
          window.localStorage[_DataServiceLocalStorageMetaKey];
      if (dbMetaSerialized == null) {
        throw InvalidOperationException(
            "Database is empty. Did you initialize(wipe) database? ");
      }
      final Map<String, dynamic> dbMetaJson = jsonDecode(dbMetaSerialized);
      dbMetaData = _DataServiceLocalStorageMeta.fromJson(dbMetaJson);
    } catch (e) {
      throw DatabaseCorruptedException(
          "Cannot deserialize meta.", FreemeworkException.wrapIfNeeded(e));
    }

    final DerivateResult derivateResult = await this._cryptoService.derivate(
          masterPassword,
          salt: dbMetaData.salt,
          iterations: dbMetaData.iterations,
          digest: dbMetaData.digest,
        );

    return derivateResult.derivatedKey;
  }

  @override
  Future<DataSet> read(Uint8List encryptionKey) async {
    String encryptedData;
    try {
      final String? dbDataSerialized =
          window.localStorage[_DataServiceLocalStorageDataKey];
      if (dbDataSerialized == null) {
        throw InvalidOperationException(
            "Database is empty. Did you initialize(wipe) database? ");
      }
      encryptedData = dbDataSerialized;
    } catch (e) {
      throw DatabaseCorruptedException(
          "Cannot deserialize meta.", FreemeworkException.wrapIfNeeded(e));
    }

    Encypter encrypter;
    try {
      encrypter = this._cryptoService.createEncypter(encryptionKey);
    } catch (e) {
      throw DatabaseServiceException(
        "Cannot create encrypter.",
        FreemeworkException.wrapIfNeeded(e),
      );
    }

    final String dataSerialized;
    try {
      dataSerialized = encrypter.decryptStringFromBas64(encryptedData);
      print(dataSerialized);
    } catch (e) {
      throw WrongMasterPasswordException(
        "Cannot decrypt data.",
        FreemeworkException.wrapIfNeeded(e),
      );
    }

    try {
      final Map<String, dynamic> dataJson = jsonDecode(dataSerialized);
      _DataSet dataSet = _DataSet.fromJson(
        dataJson,
        encryptionKey: encryptionKey,
      );
      return dataSet;
    } catch (e) {
      throw DatabaseCorruptedException(
        "Cannot deserialize decrypted data,",
        FreemeworkException.wrapIfNeeded(e),
      );
    }
  }

  @override
  Future<Uint8List> wipe(String masterPassword) async {
    DerivateResult derivateResult;
    try {
      derivateResult = await this._cryptoService.derivate(masterPassword);
    } catch (e) {
      throw DatabaseServiceException(
        "PBKDF2 failure.",
        FreemeworkException.wrapIfNeeded(e),
      );
    }

    final _DataSet emptyDataSet = _DataSet(
      derivateResult.derivatedKey,
      Set<WalletData>(),
    );

    LocalStorageEncryptedDbService._backupDto();

    final _DataServiceLocalStorageMeta dbData =
        _DataServiceLocalStorageMeta._internal(
      derivateResult.salt,
      derivateResult.iterations,
      derivateResult.digest,
    );
    final String dbMetaSerialized = jsonEncode(dbData);
    // final String dbSerializedBase64 =
    //     encrypter.encryptStringToBas64(dbSerialized);

    window.localStorage[_DataServiceLocalStorageMetaKey] = dbMetaSerialized;

    await this.write(emptyDataSet);

    return derivateResult.derivatedKey;
  }

  @override
  Future<void> write(DataSet dataSet) async {
    if (!(dataSet is _DataSet)) {
      throw InvalidOperationException(
          "Unsupported data set. You can write a data set that was constructed by the instance only.");
    }

    final _DataSet friendlyDataSet = dataSet;

    Encypter encrypter;
    try {
      encrypter =
          this._cryptoService.createEncypter(friendlyDataSet.encryptionKey);
    } catch (e) {
      throw DatabaseServiceException(
        "Cannot create encrypter.",
        FreemeworkException.wrapIfNeeded(e),
      );
    }

    final Map<String, dynamic> dataSetJson = dataSet.toJson();
    final String dataSetSerialized = jsonEncode(dataSetJson);
    final String dataSetEncryptedBase64 =
        encrypter.encryptStringToBas64(dataSetSerialized);

    window.localStorage[_DataServiceLocalStorageDataKey + "__debug"] =
        dataSetSerialized;

    window.localStorage[_DataServiceLocalStorageDataKey] =
        dataSetEncryptedBase64;
  }

  static void _backupDto() {
    final int millisecondsSinceEpoch = DateTime.now().millisecondsSinceEpoch;

    final String? meta = window.localStorage[_DataServiceLocalStorageMetaKey];
    final String? data = window.localStorage[_DataServiceLocalStorageDataKey];

    if (meta != null) {
      final String backupMetaKey =
          "${_DataServiceLocalStorageMetaKey}-bak$millisecondsSinceEpoch";
      window.localStorage[backupMetaKey] = meta;
    }

    if (data != null) {
      final String backupDataKey =
          "${_DataServiceLocalStorageDataKey}-bak$millisecondsSinceEpoch";
      window.localStorage[backupDataKey] = data;
    }
  }
}

class _DataServiceLocalStorageMeta {
  final Uint8List salt;
  final int iterations;
  final String digest;

  factory _DataServiceLocalStorageMeta.fromJson(Map<String, dynamic> rawJson) {
    final String? saltBase64 = rawJson[_SALT__PROPERTY];
    final int? iterations = rawJson[_ITERACTION__PROPERTY];
    final String? digest = rawJson[_DIGEST__PROPERTY];

    if (saltBase64 == null) {
      throw SerializationException("A field '$_SALT__PROPERTY' is null");
    }
    if (iterations == null) {
      throw SerializationException("A field '$_ITERACTION__PROPERTY' is null");
    }
    if (digest == null) {
      throw SerializationException("A field '$_DIGEST__PROPERTY' is null");
    }

    final Uint8List salt = base64Decode(saltBase64);
    if (salt.length != 32) {
      throw SerializationException(
          "A field 'salt' has bad value length: ${salt.length} (expected 32 bytes).");
    }

    return _DataServiceLocalStorageMeta._internal(salt, iterations, digest);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> rawJson = <String, dynamic>{
      _SALT__PROPERTY: base64Encode(this.salt),
      _ITERACTION__PROPERTY: this.iterations,
      _DIGEST__PROPERTY: this.digest,
    };

    return rawJson;
  }

  static const String _SALT__PROPERTY = "salt";
  static const String _ITERACTION__PROPERTY = "iterations";
  static const String _DIGEST__PROPERTY = "digest";

  _DataServiceLocalStorageMeta._internal(
    this.salt,
    this.iterations,
    this.digest,
  ) {
    assert(this.salt.length == 32);
  }
}

// class _DataServiceLocalStorageData {
//   factory _DataServiceLocalStorageData.fromJson(Map<String, dynamic> rawDto) {
//     return _DataServiceLocalStorageData._internal();
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> rawDto = {};

//     return rawDto;
//   }

//   _DataServiceLocalStorageData._internal();
// }

class _DataSet extends DataSet {
  final Uint8List _encryptionKey;
  final Set<WalletData> _wallets;

  @override
  Uint8List get encryptionKey => this._encryptionKey;

  @override
  WalletDataPlain addPlainWallet(
      String walletName, KeyPair keyPair, MnemonicPhrase? mnemonicPhrase) {
    int maxId = this._wallets.length > 0
        ? this._wallets.map((WalletData e) => e.id).reduce(max)
        : 0;

    final WalletDataPlain walletData = WalletDataPlain._(
      maxId + 1,
      walletName,
      keyPair.public,
      keyPair.secret,
      mnemonicPhrase,
    );

    this._wallets.add(walletData);

    return walletData;
  }

  @override
  UnmodifiableSetView<WalletData> get wallets =>
      UnmodifiableSetView<WalletData>(this._wallets);

  factory _DataSet.fromJson(
    final Map<String, dynamic> rawJson, {
    required final Uint8List encryptionKey,
  }) {
    final List<dynamic>? walletsJson = rawJson[_WALLETS__PROPERTY];

    if (walletsJson == null) {
      throw SerializationException("A field '$_WALLETS__PROPERTY' is null");
    }

    Set<WalletData> wallets = Set<WalletData>();
    for (final dynamic walletJson in walletsJson) {
      wallets.add(WalletData.fromJson(walletJson));
    }

    _DataSet dataSet = _DataSet(encryptionKey, wallets);
    return dataSet;
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> rawJson = <String, dynamic>{
      _WALLETS__PROPERTY: this
          ._wallets
          .map((WalletData walletData) => walletData.toJson())
          .toList(),
    };

    return rawJson;
  }

  static const String _WALLETS__PROPERTY = "wallets";

  _DataSet(this._encryptionKey, this._wallets) : super._();
}
