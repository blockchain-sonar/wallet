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

import "dart:async" show Completer, Future;
import "dart:html"
    show MessageEvent, ServiceWorker, ServiceWorkerRegistration, window;

abstract class DataSetStoreService {
  Future<void> deleteValue(String name);

  Future<String> getValue(String name);

  Future<void> setValue(String name, String value);

  Future<bool> hasValue(String name);
}

class DataSetServiceWorkerStore extends DataSetStoreService {
  static final DataSetServiceWorkerStore? _instanse =
      DataSetServiceWorkerStore._();

  bool _isInit;
  ServiceWorkerRegistration? __swInstance;
  Map<int, Completer<dynamic>> _completers;

  DataSetServiceWorkerStore._()
      : this._completers = <int, Completer<dynamic>>{},
        this._isInit = false;

  factory DataSetServiceWorkerStore() => DataSetServiceWorkerStore._instanse!;

  ServiceWorker get _serviceWorker {
    if (this.__swInstance == null) {
      throw StateError("Service worker didn't init");
    }
    if (this.__swInstance!.active == null) {
      throw StateError("Service worker don't active");
    }
    return this.__swInstance!.active!;
  }

  Future<void> init() async {
    if (this._isInit) {
      throw StateError("Can not init 'DataSetSW' class twice");
    }
    this._isInit = true;
    if (window.navigator.serviceWorker == null) {
      throw UnsupportedError("Your browser dont support Service worker");
    }
    await window.navigator.serviceWorker!.register("sw.js");
    this.__swInstance = await window.navigator.serviceWorker!.ready;
    window.navigator.serviceWorker!.onMessage.listen(this._onMessageHandler);
  }

  dynamic _onMessageHandler(MessageEvent event) {
    if (event.data["id"] == null) {
      return;
    }
    if (event.data["result"] == null) {
      return;
    }
    if (event.data["result"]["value"] == null) {
      return;
    }

    int completerId = event.data["id"];
    final Completer<dynamic>? completer = this._completers[completerId];
    if (completer == null) {
      return;
    }
    this._completers.remove(completerId);
    completer.complete(event.data["result"]["value"]);
  }

  @override
  Future<void> deleteValue(String name) async {
    DeleteDataSetValue param = DeleteDataSetValue(name);
    this._serviceWorker.postMessage(param.jsonRaw);
  }

  @override
  Future<String> getValue(String name) {
    final Completer<String> completer = Completer<String>();
    GetDataSetValue param = GetDataSetValue(name);
    this._serviceWorker.postMessage(param.jsonRaw);
    this._completers[param.id] = completer;
    return completer.future;
  }

  @override
  Future<bool> hasValue(String name) {
    final Completer<bool> completer = Completer<bool>();
    HasDataSetValue param = HasDataSetValue(name);
    this._serviceWorker.postMessage(param.jsonRaw);
    this._completers[param.id] = completer;
    return completer.future;
  }

  @override
  Future<void> setValue(String name, String value) async {
    SetDataSetValue param = SetDataSetValue(name, value);
    this._serviceWorker.postMessage(param.jsonRaw);
  }
}

class OutputDataSetSWMessage {
  final String paramName;
  final int id;

  OutputDataSetSWMessage(this.paramName)
      : this.id = DateTime.now().millisecondsSinceEpoch;

  Map<String, dynamic> get jsonRaw => throw UnimplementedError();
}

class SetDataSetValue extends OutputDataSetSWMessage {
  final String paramValue;

  SetDataSetValue(String paramName, this.paramValue) : super(paramName);

  @override
  Map<String, dynamic> get jsonRaw => <String, dynamic>{
        "method": "set",
        "params": <String, String>{
          "name": this.paramName,
          "value": this.paramValue,
        },
        "id": this.id,
      };
}

class GetDataSetValue extends OutputDataSetSWMessage {
  GetDataSetValue(String paramName) : super(paramName);

  @override
  Map<String, dynamic> get jsonRaw => <String, dynamic>{
        "method": "get",
        "params": <String, String>{"name": this.paramName},
        "id": this.id,
      };
}

class HasDataSetValue extends OutputDataSetSWMessage {
  HasDataSetValue(String paramName) : super(paramName);

  @override
  Map<String, dynamic> get jsonRaw => <String, dynamic>{
        "method": "has",
        "params": <String, String>{"name": this.paramName},
        "id": this.id,
      };
}

class DeleteDataSetValue extends OutputDataSetSWMessage {
  DeleteDataSetValue(String paramName) : super(paramName);

  @override
  Map<String, dynamic> get jsonRaw => <String, dynamic>{
        "method": "delete",
        "params": <String, String>{"name": this.paramName},
        "id": this.id,
      };
}
