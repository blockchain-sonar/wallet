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

import "dart:async" show Completer, Future;
import "dart:html"
    show
        MessageEvent,
        ServiceWorker,
        ServiceWorkerContainer,
        ServiceWorkerRegistration,
        window;

import "package:freemework/freemework.dart" show FreemeworkException;

abstract class SessionService {
  static const String KEY__ENCRYPTION_KEY = "encryptionKey";

  Future<void> deleteValue(String key);
  Future<bool> hasValue(String key);
  Future<String> getValue(String key);
  Future<void> setValue(String key, String value);
}

//
// TODO
// 0) при перезагрузке страницы клонируюся сервис воркеры (нужно использовать ранее зарегистрированный)
// 1) setValue и deleteValue не убеждаются в доставке сообщения (реально может не доставлено)
// 2) getValue зависает навсегда если нет данных в хранилище
// 3) на всех запросах нет таймаута (потоенциально все методы зависают, если поломать сервис воркер)
//

class WorkerSessionService extends SessionService {
  static final WorkerSessionService? _instanse = WorkerSessionService._();

  bool _isInit;
  ServiceWorkerRegistration? _serviceWorkerRegistration;
  Map<int, Completer<dynamic>> _completers;

  WorkerSessionService._()
      : this._completers = <int, Completer<dynamic>>{},
        this._isInit = false;

  factory WorkerSessionService() => WorkerSessionService._instanse!;

  ServiceWorker get _serviceWorker {
    final ServiceWorkerRegistration? serviceWorkerRegistration =
        this._serviceWorkerRegistration;

    if (serviceWorkerRegistration == null) {
      throw StateError(
          "Service worker didn't init. Try to call init() before use this.");
    }

    final ServiceWorker? serviceWorker = serviceWorkerRegistration.active;
    if (serviceWorker == null) {
      throw StateError("Service worker inactive");
    }
    return serviceWorker;
  }

  Future<void> init() async {
    if (this._isInit) {
      throw StateError(
          "Can not init 'ServiceWorkerKeyValueService' class twice.");
    }

    final ServiceWorkerContainer? serviceWorkerContainer =
        window.navigator.serviceWorker;

    if (serviceWorkerContainer == null) {
      throw UnsupportedError("Your browser dont support Service worker.");
    }

    this._isInit = true;

    final ServiceWorkerRegistration serviceWorkerRegistration =
        await serviceWorkerContainer.register("session_service_worker.js");

    this._serviceWorkerRegistration = serviceWorkerRegistration;

    serviceWorkerContainer.onMessage.listen(this._onMessageHandler);
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
  Future<void> deleteValue(String key) async {
    _DeleteDataSetValue param = _DeleteDataSetValue(key);
    this._serviceWorker.postMessage(param.toJson());
  }

  @override
  Future<String> getValue(String key) {
    return Future<void>.delayed(Duration(seconds: 3)).then(
        (value) => Future.error(FreemeworkException("Not implemented yet")));
    // final Completer<String> completer = Completer<String>();
    // _GetDataSetValue param = _GetDataSetValue(key);
    // this._serviceWorker.postMessage(param.toJson());
    // this._completers[param.id] = completer;
    // return completer.future;
  }

  @override
  Future<bool> hasValue(String key) {
    final Completer<bool> completer = Completer<bool>();
    _HasDataSetValue param = _HasDataSetValue(key);
    this._serviceWorker.postMessage(param.toJson());
    this._completers[param.id] = completer;
    return completer.future;
  }

  @override
  Future<void> setValue(String key, String value) async {
    print("setValue to worker: $key = $value");
    _SetDataSetValue param = _SetDataSetValue(key, value);
    this._serviceWorker.postMessage(param.toJson());
  }
}

abstract class _OutputDataSetSWMessage {
  final String paramName;
  final int id;

  _OutputDataSetSWMessage(this.paramName)
      : this.id = DateTime.now().millisecondsSinceEpoch;

  Map<String, dynamic> toJson();
}

class _SetDataSetValue extends _OutputDataSetSWMessage {
  final String paramValue;

  _SetDataSetValue(String paramName, this.paramValue) : super(paramName);

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        "method": "set",
        "params": <String, String>{
          "key": this.paramName,
          "value": this.paramValue,
        },
        "id": this.id,
      };
}

class _GetDataSetValue extends _OutputDataSetSWMessage {
  _GetDataSetValue(String paramName) : super(paramName);

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        "method": "get",
        "params": <String, String>{"key": this.paramName},
        "id": this.id,
      };
}

class _HasDataSetValue extends _OutputDataSetSWMessage {
  _HasDataSetValue(String paramName) : super(paramName);

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        "method": "has",
        "params": <String, String>{"key": this.paramName},
        "id": this.id,
      };
}

class _DeleteDataSetValue extends _OutputDataSetSWMessage {
  _DeleteDataSetValue(String paramName) : super(paramName);

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        "method": "delete",
        "params": <String, String>{"key": this.paramName},
        "id": this.id,
      };
}
