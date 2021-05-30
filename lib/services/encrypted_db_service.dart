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
import "dart:collection"
    show UnmodifiableListView, UnmodifiableMapView, UnmodifiableSetView;
import "dart:convert" show base64Decode, base64Encode, jsonDecode, jsonEncode;
import "dart:html" show window;
import "dart:typed_data" show Uint8List;
import "dart:math" show max;

import "package:flutter/widgets.dart" show ChangeNotifier;
import "package:freemework/freemework.dart"
    show FreemeworkException, InvalidOperationException;
import "../misc/ton_decimal.dart" show TonDecimal;
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

abstract class DataSet extends ChangeNotifier {
  String get activeNodeUrl;

  bool get autoLock;

  Uint8List get encryptionKey;

  KeypairBundlePlain addKeypairBundlePlain(
    String title,
    KeyPair keyPair,
    MnemonicPhrase? mnemonicPhrase,
  );

  void addNode(NodeBundle node);

  void deleteNodeByUrl(String nodeUrl);

  void setActiveNode(NodeBundle node);

  void switchAutoLock(bool value);

  UnmodifiableSetView<KeypairBundle> get keypairBundles;

  UnmodifiableListView<NodeBundle> get nodes;

  DataSet._(); // internal
}

abstract class DataAccount extends ChangeNotifier {
  final String blockchainAddress;
  final String smartContractFullQualifiedName;
  final TonDecimal balance;
  final AccountType accountType;

  KeypairBundle get parentKeypairBundle;

  DataAccount._(
    this.blockchainAddress,
    this.smartContractFullQualifiedName,
    this.accountType,
    this.balance,
  );
}

enum AccountType {
  /// Account is uninitialized when contract is not deployed yet.
  UNINITIALIZED,

  /// Account is active when contract is deployed.
  ACTIVE,
}

abstract class KeypairBundle extends ChangeNotifier {
  final int id;
  final String keypairName;
  final String keyPublic;

  /// The map of accounts. Key of the map is a SmartContract Identifier
  UnmodifiableMapView<String, DataAccount> get accounts =>
      this._accountsView ??
      (this._accountsView =
          UnmodifiableMapView<String, DataAccount>(this._accounts));

  DataAccount setAccount(
    String smartContractId,
    String blockchainAddress,
    AccountType accountType,
    TonDecimal balance,
  ) {
    final _Account account = _Account._(
      blockchainAddress,
      smartContractId,
      accountType,
      balance,
    );
    account._parentKeypairBundle = this;
    this._accounts[smartContractId] = account;

    this.notifyListeners();

    return account;
  }

  factory KeypairBundle._fromJson(final Map<String, dynamic> rawJson) {
    final int? id = rawJson[KeypairBundle._ID__PROPERTY];
    final String? kind = rawJson[KeypairBundle._KIND__PROPERTY];
    final String? keyPublic = rawJson[KeypairBundle._KEY_PUBLIC__PROPERTY];
    final String? keypairName = rawJson[KeypairBundle._KEYPAIR_NAME__PROPERTY];
    final Map<String, dynamic>? accountsJson =
        rawJson[KeypairBundle._ACCOUNTS__PROPERTY];

    if (id == null) {
      throw SerializationException(
          "A field '${KeypairBundle._ID__PROPERTY}' is null");
    }
    if (kind == null) {
      throw SerializationException(
          "A field '${KeypairBundle._KIND__PROPERTY}' is null");
    }
    if (keyPublic == null) {
      throw SerializationException(
          "A field '${KeypairBundle._KEY_PUBLIC__PROPERTY}' is null");
    }
    if (keypairName == null) {
      throw SerializationException(
          "A field '${KeypairBundle._KEYPAIR_NAME__PROPERTY}' is null");
    }
    if (accountsJson == null) {
      throw SerializationException(
          "A field '${KeypairBundle._ACCOUNTS__PROPERTY}' is null");
    }

    final Map<String, _Account> accounts = <String, _Account>{};

    for (final MapEntry<String, dynamic> kv in accountsJson.entries) {
      final String smartContractId = kv.key;
      final Map<String, dynamic> accountJson = kv.value;

      final _Account account = _Account.fromJson(accountJson);
      accounts[smartContractId] = account;
    }

    KeypairBundle keypairBundle;
    switch (kind) {
      case "plain":
        keypairBundle = KeypairBundlePlain._fromJson(
          id,
          keypairName,
          keyPublic,
          accounts,
          rawJson,
        );
        break;
      default:
        throw SerializationException(
            "A field '$_KIND__PROPERTY' has unsupported value '$kind'.");
    }

    for (final _Account account in accounts.values) {
      account._parentKeypairBundle = keypairBundle;
    }

    return keypairBundle;
  }

  Map<String, dynamic> _toJson() {
    String kind;
    if (this is KeypairBundlePlain) {
      kind = "plain";
    } else {
      throw SerializationException(
          "Cannot serialize a field '$_KIND__PROPERTY'. Cannot resolve text representation by runtimeType '${this.runtimeType}'.");
    }

    final Map<String, dynamic> accountJson = <String, dynamic>{};

    for (final MapEntry<String, DataAccount> kv in this.accounts.entries) {
      final String smartContractId = kv.key;
      final _Account account = kv.value as _Account;
      accountJson[smartContractId] = account.toJson();
    }

    final Map<String, dynamic> rawJson = <String, dynamic>{
      KeypairBundle._ID__PROPERTY: this.id,
      KeypairBundle._KIND__PROPERTY: kind,
      KeypairBundle._KEYPAIR_NAME__PROPERTY: this.keypairName,
      KeypairBundle._KEY_PUBLIC__PROPERTY: this.keyPublic,
      KeypairBundle._ACCOUNTS__PROPERTY: accountJson
    };

    return rawJson;
  }

  static const String _ID__PROPERTY = "id";
  static const String _KIND__PROPERTY = "kind";
  static const String _KEY_PUBLIC__PROPERTY = "keypub";
  static const String _KEYPAIR_NAME__PROPERTY = "name";
  static const String _ACCOUNTS__PROPERTY = "accounts";

  UnmodifiableMapView<String, DataAccount>? _accountsView;
  final Map<String, DataAccount> _accounts;

  KeypairBundle._(
    this.id,
    this.keypairName,
    this.keyPublic,
    this._accounts,
  ) : this._accountsView = null;
}

class KeypairBundlePlain extends KeypairBundle {
  final String keySecret;
  final MnemonicPhrase? mnemonicPhrase;

  factory KeypairBundlePlain._fromJson(
    final int id,
    final String keypairName,
    final String keyPublic,
    final Map<String, DataAccount> accounts,
    final Map<String, dynamic> rawJson,
  ) {
    final String? keySecret = rawJson[_KEY_SECRET__PROPERTY];
    final String? mnemonicPhraseSentence = rawJson[_MNEMONIC_PHRASE__PROPERTY];

    if (keySecret == null) {
      throw SerializationException("A field '$_KEY_SECRET__PROPERTY' is null");
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

    return KeypairBundlePlain._(
      id,
      keypairName,
      keyPublic,
      accounts,
      keySecret,
      mnemonicPhrase,
    );
  }

  @override
  Map<String, dynamic> _toJson() {
    final Map<String, dynamic> rawJson = super._toJson()
      ..addAll(<String, dynamic>{
        _KEY_SECRET__PROPERTY: this.keySecret,
      });

    final MnemonicPhrase? mnemonicPhrase = this.mnemonicPhrase;
    if (mnemonicPhrase != null) {
      rawJson[_MNEMONIC_PHRASE__PROPERTY] = mnemonicPhrase.sentence;
    }

    return rawJson;
  }

  static const String _KEY_SECRET__PROPERTY = "keysecret";
  static const String _MNEMONIC_PHRASE__PROPERTY = "mnemonic";

  KeypairBundlePlain._(
    int id,
    String keypairName,
    String keyPublic,
    Map<String, DataAccount> accounts,
    this.keySecret,
    this.mnemonicPhrase,
  ) : super._(id, keypairName, keyPublic, accounts);
}

class NodeBundle {
  final String name;
  final String url;
  final int? color;

  factory NodeBundle.fromJson(Map<String, dynamic> rawJson) {
    final name = rawJson[NodeBundle._NAME_PROPERTY];
    final url = rawJson[NodeBundle._URL_PROPERTY];
    final color = rawJson[NodeBundle._COLOR_PROPERTY];
    if (name == null) {
      throw SerializationException(
          "A field '${NodeBundle._NAME_PROPERTY}' is null");
    }
    if (url == null) {
      throw SerializationException(
          "A field '${NodeBundle._URL_PROPERTY}' is null");
    }
    // if (color == null) {
    // throw SerializationException(
    //     "A field '${NodeBundle._COLOR_PROPERTY}' is null");
    // }
    return NodeBundle(name, url, color);
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      NodeBundle._NAME_PROPERTY: this.name,
      NodeBundle._URL_PROPERTY: this.url,
      NodeBundle._COLOR_PROPERTY: this.color,
    };
  }

  NodeBundle(this.name, this.url, this.color);

  static const String _NAME_PROPERTY = "name";
  static const String _URL_PROPERTY = "url";
  static const String _COLOR_PROPERTY = "color";
}

// class KeyPairBundleDataEncrypted extends KeyPairBundleData {
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
      Set<KeypairBundle>(),
      <NodeBundle>[],
      "",
      false,
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
  final Set<KeypairBundle> _keypairBundles;
  final List<NodeBundle> _nodes;
  String _nodeUrl;
  bool _autoLock;

  @override
  Uint8List get encryptionKey => this._encryptionKey;

  @override
  String get activeNodeUrl => this._nodeUrl;

  @override
  bool get autoLock => this._autoLock;

  @override
  KeypairBundlePlain addKeypairBundlePlain(
    String keypairName,
    KeyPair keyPair,
    MnemonicPhrase? mnemonicPhrase,
  ) {
    int maxId = this._keypairBundles.length > 0
        ? this._keypairBundles.map((KeypairBundle e) => e.id).reduce(max)
        : 0;

    final KeypairBundlePlain keypairBundle = KeypairBundlePlain._(
      maxId + 1,
      keypairName,
      keyPair.public,
      <String, DataAccount>{},
      keyPair.secret,
      mnemonicPhrase,
    );

    this._keypairBundles.add(keypairBundle);

    return keypairBundle;
  }

  @override
  void addNode(NodeBundle node) {
    if (this._nodes.where((NodeBundle n) => n.url == node.url).isNotEmpty) {
      throw Exception("Node '${node.url}' alreay exist.");
    }
    this._nodes.add(node);
  }

  @override
  void deleteNodeByUrl(String nodeUrl) {
    this._nodes.removeWhere((NodeBundle node) => node.url == nodeUrl);
  }

  @override
  void setActiveNode(NodeBundle node) {
    this._nodeUrl = node.url;
  }

  @override
  void switchAutoLock(bool value) {
    this._autoLock = value;
  }

  @override
  UnmodifiableSetView<KeypairBundle> get keypairBundles =>
      UnmodifiableSetView<KeypairBundle>(this._keypairBundles);

  @override
  UnmodifiableListView<NodeBundle> get nodes =>
      UnmodifiableListView<NodeBundle>(this._nodes);

  factory _DataSet.fromJson(
    final Map<String, dynamic> rawJson, {
    required final Uint8List encryptionKey,
  }) {
    final List<dynamic>? walletsJson = rawJson[_WALLETS__PROPERTY];
    final List<dynamic>? nodesJson = rawJson[_NODES__PROPERTY];
    final String? nodeUrlJson = rawJson[_NODES_URL__PROPERTY];
    final bool? autoLockJson = rawJson[_AUTOLOCK__PROPERTY];

    if (walletsJson == null) {
      throw SerializationException("A field '$_WALLETS__PROPERTY' is null");
    }

    if (nodesJson == null) {
      throw SerializationException("A field '$_NODES__PROPERTY' is null");
    }

    if (nodeUrlJson == null) {
      throw SerializationException("A field '$_NODES_URL__PROPERTY' is null");
    }

    if (autoLockJson == null) {
      throw SerializationException("A field '$_AUTOLOCK__PROPERTY' is null");
    }

    Set<KeypairBundle> wallets = Set<KeypairBundle>();
    for (final dynamic walletJson in walletsJson) {
      wallets.add(KeypairBundle._fromJson(walletJson));
    }

    List<NodeBundle> nodes = <NodeBundle>[];
    for (final dynamic nodeJson in nodesJson) {
      nodes.add(NodeBundle.fromJson(nodeJson));
    }

    _DataSet dataSet =
        _DataSet(encryptionKey, wallets, nodes, nodeUrlJson, autoLockJson);
    return dataSet;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> rawJson = <String, dynamic>{
      _WALLETS__PROPERTY: this
          ._keypairBundles
          .map((KeypairBundle walletData) => walletData._toJson())
          .toList(),
      _NODES__PROPERTY:
          this._nodes.map((NodeBundle node) => node.toJson()).toList(),
      _NODES_URL__PROPERTY: this._nodeUrl,
      _AUTOLOCK__PROPERTY: this._autoLock,
    };

    return rawJson;
  }

  static const String _WALLETS__PROPERTY = "wallets";
  static const String _NODES__PROPERTY = "nodes";
  static const String _NODES_URL__PROPERTY = "nodeUrl";
  static const String _AUTOLOCK__PROPERTY = "autoLock";

  _DataSet(
    this._encryptionKey,
    this._keypairBundles,
    this._nodes,
    this._nodeUrl,
    this._autoLock,
  ) : super._();
}

class _Account extends DataAccount {
  KeypairBundle? _parentKeypairBundle;

  @override
  KeypairBundle get parentKeypairBundle {
    assert(this._parentKeypairBundle != null);
    return this._parentKeypairBundle!;
  }

  factory _Account.fromJson(
    final Map<String, dynamic> rawJson,
  ) {
    final String? smartContractId =
        rawJson[_Account._SMART_CONTRACT_ID__PROPERTY];
    final String? blockchainAddress =
        rawJson[_Account.__BLOCKCHAIN_ADDRESS__PROPERTY];
    final AccountType? accountType = rawJson[_Account.__ACCOUNT_TYPE__PROPERTY];
    final String? balance = rawJson[_Account.__BALANCE__PROPERTY];

    if (smartContractId == null) {
      throw SerializationException(
          "A field '${_Account._SMART_CONTRACT_ID__PROPERTY}' is null");
    }
    if (blockchainAddress == null) {
      throw SerializationException(
          "A field '${_Account.__BLOCKCHAIN_ADDRESS__PROPERTY}' is null");
    }
    if (accountType == null) {
      throw SerializationException(
          "A field '${_Account.__ACCOUNT_TYPE__PROPERTY}' is null");
    }
    if (balance == null) {
      throw SerializationException(
          "A field '${_Account.__BALANCE__PROPERTY}' is null");
    }

    return _Account._(
      blockchainAddress,
      smartContractId,
      accountType,
      TonDecimal.parseNanoHex(balance),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> rawJson = <String, dynamic>{
      _Account._SMART_CONTRACT_ID__PROPERTY:
          this.smartContractFullQualifiedName,
      _Account.__BLOCKCHAIN_ADDRESS__PROPERTY: this.blockchainAddress,
      _Account.__ACCOUNT_TYPE__PROPERTY: this.accountType,
      _Account.__BALANCE__PROPERTY: this.balance.nanoHex,
    };

    return rawJson;
  }

  static const String _SMART_CONTRACT_ID__PROPERTY = "smartContractId";
  static const String __BLOCKCHAIN_ADDRESS__PROPERTY = "blockchainAddress";
  static const String __ACCOUNT_TYPE__PROPERTY = "accountType";
  static const String __BALANCE__PROPERTY = "balance";

  _Account._(
    String blockchainAddress,
    String smartContractId,
    AccountType accountType,
    TonDecimal balance,
  ) : super._(
          blockchainAddress,
          smartContractId,
          accountType,
          balance,
        );
}
