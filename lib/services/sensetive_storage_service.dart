//
// Copyright 2021 Free TON Wallet Team
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// 	http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import "dart:async" show Future;
import "dart:convert" show base64Decode, base64Encode, jsonDecode, jsonEncode;
import "dart:html" show window;
import "dart:typed_data" show Uint8List;

import "package:freemework/freemework.dart"
    show FreemeworkException, InvalidOperationException;

import "../misc/database_exception.dart" show DatabaseCorruptedException, DatabaseException, WrongMasterPasswordException;
import "../model/serialization_exception.dart" show SerializationException;
import "../model/app_sensetive_model.dart" show AppSensetiveModel;
import "../model/seed_sensetive_model.dart" show SeedSensetiveModel;

import "crypto_service.dart" show CryptoService, DerivateResult, Encypter;

abstract class SensetiveStorageService {
  bool get isInitialized;

  /// Resotre an encryption key by salt and iterations saved in DB.
  /// The encryption key is needed to `read` data set.
  Future<Uint8List> derivateEncryptionKey(String masterPassword);

  /// Uncrypt/Read data set.
  Future<AppSensetiveModel> read(Uint8List encryptionKey);

  /// Wipe all data (re-initialize)
  ///
  /// Returns new encryption key
  Future<Uint8List> wipe(String masterPassword);

  Future<void> write(AppSensetiveModel appSensetiveModel);
}

const String _LocalStorageMetaKey =
    "org.freeton-wallet.schema.sensetivedb-meta-v0.0.0";
const String _LocalStorageDataKey =
    "org.freeton-wallet.schema.sensetivedb-data-v0.0.0";

class SensetiveLocalStorageService extends SensetiveStorageService {
  final CryptoService _cryptoService;

  SensetiveLocalStorageService(this._cryptoService);

  @override
  bool get isInitialized =>
      window.localStorage.containsKey(_LocalStorageMetaKey) &&
      window.localStorage.containsKey(_LocalStorageDataKey);

  @override
  Future<Uint8List> derivateEncryptionKey(String masterPassword) async {
    _LocalStorageMeta dbMetaData;
    try {
      final String? dbMetaSerialized =
          window.localStorage[_LocalStorageMetaKey];
      if (dbMetaSerialized == null) {
        throw InvalidOperationException(
            "Database is empty. Did you initialize(wipe) database? ");
      }
      final Map<String, dynamic> dbMetaJson = jsonDecode(dbMetaSerialized);
      dbMetaData = _LocalStorageMeta.fromJson(dbMetaJson);
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
  Future<AppSensetiveModel> read(Uint8List encryptionKey) async {
    String encryptedData;
    try {
      final String? dbDataSerialized =
          window.localStorage[_LocalStorageDataKey];
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
      throw DatabaseException(
        "Cannot create encrypter.",
        FreemeworkException.wrapIfNeeded(e),
      );
    }

    final String dataSerialized;
    try {
      dataSerialized = encrypter.decryptStringFromBas64(encryptedData);
    } catch (e) {
      throw WrongMasterPasswordException(
        "Cannot decrypt data.",
        FreemeworkException.wrapIfNeeded(e),
      );
    }

    try {
      final Map<String, dynamic> dataJson = jsonDecode(dataSerialized);
      final AppSensetiveModel appSensetiveModel = AppSensetiveModel.fromJson(
        dataJson,
      );
      return _AppSensetiveModelWrapper(encryptionKey, appSensetiveModel);
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
      throw DatabaseException(
        "PBKDF2 failure.",
        FreemeworkException.wrapIfNeeded(e),
      );
    }

    final _AppSensetiveModelWrapper emptyAppSensetiveModel = _AppSensetiveModelWrapper(
      derivateResult.derivatedKey,
      AppSensetiveModel(),
    );

    SensetiveLocalStorageService._backupDto();

    final _LocalStorageMeta dbData = _LocalStorageMeta._internal(
      derivateResult.salt,
      derivateResult.iterations,
      derivateResult.digest,
    );
    final String dbMetaSerialized = jsonEncode(dbData);

    window.localStorage[_LocalStorageMetaKey] = dbMetaSerialized;

    await this.write(emptyAppSensetiveModel);

    return derivateResult.derivatedKey;
  }

  @override
  Future<void> write(AppSensetiveModel appSensetiveModel) async {
    if (!(appSensetiveModel is _AppSensetiveModelWrapper)) {
      throw InvalidOperationException(
          "Unsupported app sensetive model. You can write a data set that was constructed by the instance only.");
    }

    final _AppSensetiveModelWrapper friendlyAppSensetiveModel = appSensetiveModel;

    Encypter encrypter;
    try {
      encrypter = this
          ._cryptoService
          .createEncypter(friendlyAppSensetiveModel.encryptionKey);
    } catch (e) {
      throw DatabaseException(
        "Cannot create encrypter.",
        FreemeworkException.wrapIfNeeded(e),
      );
    }

    final Map<String, dynamic> dataSetJson = friendlyAppSensetiveModel.toJson();
    final String dataSetSerialized = jsonEncode(dataSetJson);
    final String dataSetEncryptedBase64 =
        encrypter.encryptStringToBas64(dataSetSerialized);

    //window.localStorage[_LocalStorageDataKey + "__debug"] = dataSetSerialized;

    window.localStorage[_LocalStorageDataKey] = dataSetEncryptedBase64;
  }

  static void _backupDto() {
    final int millisecondsSinceEpoch = DateTime.now().millisecondsSinceEpoch;

    final String? meta = window.localStorage[_LocalStorageMetaKey];
    final String? data = window.localStorage[_LocalStorageDataKey];

    if (meta != null) {
      final String backupMetaKey =
          "${_LocalStorageMetaKey}-bak$millisecondsSinceEpoch";
      window.localStorage[backupMetaKey] = meta;
    }

    if (data != null) {
      final String backupDataKey =
          "${_LocalStorageDataKey}-bak$millisecondsSinceEpoch";
      window.localStorage[backupDataKey] = data;
    }
  }
}

class _LocalStorageMeta {
  final Uint8List salt;
  final int iterations;
  final String digest;

  factory _LocalStorageMeta.fromJson(Map<String, dynamic> rawJson) {
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

    return _LocalStorageMeta._internal(salt, iterations, digest);
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

  _LocalStorageMeta._internal(
    this.salt,
    this.iterations,
    this.digest,
  ) {
    assert(this.salt.length == 32);
  }
}

class _AppSensetiveModelWrapper implements AppSensetiveModel {
  final Uint8List encryptionKey;
  final AppSensetiveModel _wrap;

  _AppSensetiveModelWrapper(this.encryptionKey, this._wrap);

  @override
  List<SeedSensetiveModel> get seeds => this._wrap.seeds;

  @override
  Map<String, dynamic> toJson() => this._wrap.toJson();
}
