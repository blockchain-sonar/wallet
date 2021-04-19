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

import "dart:async" show Future, Timer;
import "dart:convert" show base64Decode, base64Encode, jsonDecode, jsonEncode;
import "dart:html" show window;
import "dart:typed_data" show Uint8List;

import "package:flutter/widgets.dart" show ChangeNotifier;
import "package:freemework/freemework.dart"
    show FreemeworkException, InvalidOperationException;

import "crypto_service.dart" show CryptoService, DerivateResult, Encypter;

abstract class DatabaseService extends ChangeNotifier {
  bool get isLogged;
  bool get hasDatabase;
  List<dynamic> get keys;

  @override
  void dispose();
  Future<void> loginDatabase(String masterPassword);
  void prolongAutoLogout();
  void releaseDatabase();
  Future<void> wipeDatabase(String masterPassword);
}

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

class SerializationException extends DatabaseServiceException {
  SerializationException(String message, [FreemeworkException? innerException])
      : super(message, innerException);
}

class WrongMasterPasswordException extends DatabaseServiceException {
  WrongMasterPasswordException(String message,
      [FreemeworkException? innerException])
      : super(message, innerException);
}

const String _DataServiceLocalStorageDataKey =
    "org.freeton-wallet.schema.db-data-v0.0.0";
const String _DataServiceLocalStorageMetaKey =
    "org.freeton-wallet.schema.db-meta-v0.0.0";

class DatabaseServiceLocalStorage extends DatabaseService {
  final CryptoService _cryptoService;
  _DataServiceLocalStorageData? _data;
  _DataServiceLocalStorageMeta? _meta;
  Encypter? _encrypter;
  Timer? _autoLogoutTimer;

  DatabaseServiceLocalStorage(this._cryptoService)
      : this._data = null,
        this._meta = null,
        this._encrypter = null,
        this._autoLogoutTimer = null;

  @override
  bool get hasDatabase =>
      window.localStorage.containsKey(_DataServiceLocalStorageDataKey) &&
      window.localStorage.containsKey(_DataServiceLocalStorageMetaKey);

  @override
  List<dynamic> get keys => [];

  @override
  bool get isLogged => this._data != null;

  @override
  void dispose() {
    super.dispose();
    print("DatabaseServiceLocalStorage has been destroyed.");
  }

  @override
  Future<void> wipeDatabase(String masterPassword) async {
    final DerivateResult derivateResult =
        await this._cryptoService.derivate(masterPassword);

    final Uint8List salt = derivateResult.salt;
    final int iterations = derivateResult.iterations;
    final String digestAlgo = derivateResult.digestAlgo;

    this._encrypter =
        this._cryptoService.createEncypter(derivateResult.derivatedKey);

    DatabaseServiceLocalStorage._backupDto();
    this._meta =
        _DataServiceLocalStorageMeta._internal(salt, iterations, digestAlgo);
    this._data = _DataServiceLocalStorageData._internal();
    this._persist();
    this.notifyListeners();
  }

  @override
  Future<void> loginDatabase(String masterPassword) async {
    this._verifyNonNewbe();

    _DataServiceLocalStorageMeta meta;
    _DataServiceLocalStorageData data;

    try {
      final String? metaSerialized =
          window.localStorage[_DataServiceLocalStorageMetaKey];
      if (metaSerialized == null) {
        throw WrongMasterPasswordException("Database is empty.");
      }
      final Map<String, dynamic> rawMeta = jsonDecode(metaSerialized);
      meta = _DataServiceLocalStorageMeta.fromJson(rawMeta);
    } catch (e) {
      throw DatabaseCorruptedException(
          "Cannot deserialize meta.", FreemeworkException.wrapIfNeeded(e));
    }

    print(meta);

    Encypter encrypter;
    try {
      final Uint8List salt = meta.salt;
      final int iterations = meta.iterations;
      final String digestAlgo = meta.digestAlgo;

      final DerivateResult derivateResult = await this._cryptoService.derivate(
            masterPassword,
            salt: salt,
            iterations: iterations,
            digestAlgo: digestAlgo,
          );

      encrypter =
          this._cryptoService.createEncypter(derivateResult.derivatedKey);
    } catch (e) {
      throw WrongMasterPasswordException(
        "Database decrypt failure.",
        FreemeworkException.wrapIfNeeded(e),
      );
    }

    try {
      final String? encryptedDataSerializedBase64 =
          window.localStorage[_DataServiceLocalStorageDataKey];
      if (encryptedDataSerializedBase64 == null) {
        throw WrongMasterPasswordException("Database is empty.");
      }

      final String dataSerialized =
          encrypter.decryptStringFromBas64(encryptedDataSerializedBase64);
      final Map<String, dynamic> rawDto = jsonDecode(dataSerialized);
      data = _DataServiceLocalStorageData.fromJson(rawDto);
    } catch (e) {
      throw DatabaseCorruptedException(
        "Cannot deserialize data.",
        FreemeworkException.wrapIfNeeded(e),
      );
    }

    this._meta = meta;
    this._data = data;
    this._encrypter = encrypter;

    this.notifyListeners();
    this._setupAutoLogoutTimer();
  }

  @override
  void releaseDatabase() {
    this._verifyLogged();

    this.notifyListeners();
    this._cancelAutoLogoutTimer();
  }

  @override
  void prolongAutoLogout() {
    this._verifyLogged();

    this._cancelAutoLogoutTimer();
    this._setupAutoLogoutTimer();
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

  void _cancelAutoLogoutTimer() {
    if (this._autoLogoutTimer != null) {
      this._autoLogoutTimer!.cancel();
    }
  }

  void _persist() {
    Encypter? encrypter = this._encrypter;
    if (encrypter == null) {
      throw InvalidOperationException(
          "Wrong operation at current state. Cannot persit database when no available encrypter.");
    }

    final String metaSerialized = jsonEncode(this._meta);
    final String dataSerialized = jsonEncode(this._data);

    final String dataSerializedBase64 =
        encrypter.encryptStringToBas64(dataSerialized);

    window.localStorage[_DataServiceLocalStorageMetaKey] = metaSerialized;
    window.localStorage[_DataServiceLocalStorageDataKey] = dataSerializedBase64;
  }

  void _setupAutoLogoutTimer() {
    assert(this._autoLogoutTimer == null);
    this._autoLogoutTimer = Timer(Duration(seconds: 5), () {
      assert(this._autoLogoutTimer != null);
      this._autoLogoutTimer = null;
      this.releaseDatabase();
    });
  }

  void _verifyLogged() {
    if (!this.isLogged) {
      throw InvalidOperationException(
          "Wrong operation at current state. User is not logged yet.");
    }
    this._verifyNonNewbe();
  }

  void _verifyNonNewbe() {
    if (!this.hasDatabase) {
      throw InvalidOperationException(
          "Wrong operation at current state. Database is not prepared yet.");
    }
  }
}

class _DataServiceLocalStorageMeta {
  final Uint8List salt;
  final int iterations;
  final String digestAlgo;

  factory _DataServiceLocalStorageMeta.fromJson(Map<String, dynamic> rawMeta) {
    final String? saltBase64 = rawMeta["salt"];
    final int? iterations = rawMeta["iterations"];
    final String? digestAlgo = rawMeta["digest"];

    if (saltBase64 == null) {
      throw SerializationException("A field 'salt' is null");
    }
    if (iterations == null) {
      throw SerializationException("A field 'iterations' is null");
    }
    if (digestAlgo == null) {
      throw SerializationException("A field 'digest' is null");
    }

    final Uint8List salt = base64Decode(saltBase64);
    if (salt.length != 32) {
      throw SerializationException(
          "A field 'salt' has bad value length: ${salt.length} (expected 32 bytes).");
    }

    return _DataServiceLocalStorageMeta._internal(salt, iterations, digestAlgo);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> rawMeta = <String, dynamic>{
      "salt": base64Encode(this.salt),
      "iterations": this.iterations,
      "digest": this.digestAlgo
    };

    return rawMeta;
  }

  _DataServiceLocalStorageMeta._internal(
    this.salt,
    this.iterations,
    this.digestAlgo,
  ) {
    assert(this.salt.length == 32);
  }
}

class _DataServiceLocalStorageData {
  factory _DataServiceLocalStorageData.fromJson(Map<String, dynamic> rawDto) {
    return _DataServiceLocalStorageData._internal();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> rawDto = {};

    return rawDto;
  }

  _DataServiceLocalStorageData._internal();
}
