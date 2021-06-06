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
import "dart:convert" show jsonDecode, jsonEncode;
import "dart:html" show window;

import "package:freemework/freemework.dart"
    show FreemeworkException, InvalidOperationException;

import "../misc/database_exception.dart" show DatabaseCorruptedException;
import "../model/app_model.dart" show AppModel;

abstract class StorageService {
  bool get isInitialized;

  /// Read AppModel from an underlaying storage.
  Future<AppModel> read();

  /// Wipe all data (re-initialize)
  Future<void> wipe();

  /// Save AppModel to an underlaying storage.
  Future<void> write(AppModel appModel);
}

const String _DataServiceLocalStorageDataKey =
    "org.freeton-wallet.schema.localstoragedb-data-v0.0.0";

class LocalStorageService extends StorageService {
  LocalStorageService();

  @override
  bool get isInitialized =>
      window.localStorage.containsKey(_DataServiceLocalStorageDataKey);

  @override
  Future<AppModel> read() async {
    final String? dataSerialized =
        window.localStorage[_DataServiceLocalStorageDataKey];
    if (dataSerialized == null) {
      throw InvalidOperationException(
          "Database is empty. Did you initialize(wipe) database? ");
    }

    try {
      final Map<String, dynamic> dataJson = jsonDecode(dataSerialized);
      final AppModel dataSet = AppModel.fromJson(
        dataJson,
      );
      return dataSet;
    } catch (e) {
      throw DatabaseCorruptedException(
        "Cannot deserialize data,",
        FreemeworkException.wrapIfNeeded(e),
      );
    }
  }

  @override
  Future<void> wipe() async {
    LocalStorageService._backupDto();

    await this.write(AppModel.EMPTY);
  }

  @override
  Future<void> write(AppModel dataSet) async {
    final Map<String, dynamic> dataSetJson = dataSet.toJson();
    final String dataSetSerialized = jsonEncode(dataSetJson);

    window.localStorage[_DataServiceLocalStorageDataKey] = dataSetSerialized;
  }

  static void _backupDto() {
    final int millisecondsSinceEpoch = DateTime.now().millisecondsSinceEpoch;

    final String? data = window.localStorage[_DataServiceLocalStorageDataKey];

    if (data != null) {
      final String backupDataKey =
          "${_DataServiceLocalStorageDataKey}-bak$millisecondsSinceEpoch";
      window.localStorage[backupDataKey] = data;
    }
  }
}
