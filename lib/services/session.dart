//
// Copyright 2021 Free TON Wallet Team
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import "dart:async" show Completer, Future, Timer;
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

  static const int _DELAY_TIMEOUT = 3;

  bool _isInit;
  ServiceWorkerRegistration? _serviceWorkerRegistration;
  Map<int, _CompleterEntry> _completers;

  WorkerSessionService._()
      : this._completers = <int, _CompleterEntry>{},
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

  void close() {
    final ServiceWorkerRegistration? serviceWorkerRegistration =
        this._serviceWorkerRegistration;
    if (serviceWorkerRegistration == null) {
      throw StateError(
          "Service worker didn't init. Try to call init() before use this.");
    }
    serviceWorkerRegistration.unregister();
  }

  Future<void> init() async {
    print("SW Init!");
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
    final ServiceWorkerRegistration serviceWorkerRegistration2 =
        await serviceWorkerContainer.ready;
    this._serviceWorkerRegistration = serviceWorkerRegistration2;

    print(serviceWorkerRegistration == serviceWorkerRegistration2);
    serviceWorkerContainer.onMessage.listen(this._onMessageHandler);
  }

  dynamic _onMessageHandler(MessageEvent event) {
    int? completerId = event.data["id"];
    if (completerId == null) {
      return;
    }
    final _CompleterEntry? completerEnrty = this._completers[completerId];
    if (completerEnrty == null) {
      return;
    }

    if (event.data["result"] == null) {
      completerEnrty.completer.completeError("Error, no result in response");
    }
    if (event.data["result"]["value"] == null) {
      completerEnrty.completer
          .completeError("Error, no result value in response");
    }
    completerEnrty.timer.cancel();
    this._completers.remove(completerId);
    completerEnrty.completer.complete(event.data["result"]["value"]);
  }

  Timer _setCompleterTimeout(Completer<dynamic> completer) {
    return Timer(Duration(seconds: WorkerSessionService._DELAY_TIMEOUT), () {
      this._completers.removeWhere((_, _CompleterEntry completerEntry) =>
          completerEntry.completer == completer);
      completer.completeError("Completer timeout");
    });
  }

  @override
  Future<void> deleteValue(String key) async {
    final Completer<void> completer = Completer<void>();
    Timer timer = this._setCompleterTimeout(completer);
    _DeleteDataSetValue param = _DeleteDataSetValue(key);
    this._serviceWorker.postMessage(param.toJson());
    this._completers[param.id] = _CompleterEntry(completer, timer);
    return completer.future;
  }

  @override
  Future<String> getValue(String key) {
    final Completer<String> completer = Completer<String>();
    Timer timer = this._setCompleterTimeout(completer);
    _GetDataSetValue param = _GetDataSetValue(key);
    this._serviceWorker.postMessage(param.toJson());
    this._completers[param.id] = _CompleterEntry(completer, timer);
    return completer.future;
  }

  @override
  Future<bool> hasValue(String key) {
    final Completer<bool> completer = Completer<bool>();
    Timer timer = this._setCompleterTimeout(completer);
    _HasDataSetValue param = _HasDataSetValue(key);
    this._serviceWorker.postMessage(param.toJson());
    this._completers[param.id] = _CompleterEntry(completer, timer);
    return completer.future;
  }

  @override
  Future<void> setValue(String key, String value) async {
    // print("setValue to worker: $key = $value");
    final Completer<void> completer = Completer<void>();
    Timer timer = this._setCompleterTimeout(completer);
    _SetDataSetValue param = _SetDataSetValue(key, value);
    this._serviceWorker.postMessage(param.toJson());
    this._completers[param.id] = _CompleterEntry(completer, timer);
    return completer.future;
  }
}

class LocalStorageSessionService extends SessionService {
  int _timeout = 900;
  static const String _PREFIX = "LOCAL_DATASET";

  void _refreshExpTimestaml(String key, _LocalStorageSessionEntity entity) {
    this.setValue(key, entity.value);
  }

  @override
  Future<void> deleteValue(String key) async {
    window.localStorage.remove("${LocalStorageSessionService._PREFIX}:${key}");
  }

  @override
  Future<String> getValue(String key) async {
    final String? valueRaw =
        window.localStorage["${LocalStorageSessionService._PREFIX}:${key}"];
    if (valueRaw == null) {
      throw StateError(
          "No value for key: ${LocalStorageSessionService._PREFIX}:${key}");
    }
    try {
      _LocalStorageSessionEntity localEntity =
          _LocalStorageSessionEntity.parse(valueRaw);
      this._refreshExpTimestaml(key, localEntity);
      return localEntity.value;
    } catch (e) {
      this.deleteValue(key);
      throw e;
    }
  }

  @override
  Future<bool> hasValue(String key) async {
    if (!window.localStorage.containsKey(key)) {
      return false;
    }
    final String? valueRaw =
        window.localStorage["${LocalStorageSessionService._PREFIX}:${key}"];
    if (valueRaw == null) {
      throw StateError(
          "No value for key: ${LocalStorageSessionService._PREFIX}:${key}");
    }
    try {
      _LocalStorageSessionEntity localEntity =
          _LocalStorageSessionEntity.parse(valueRaw);
      this._refreshExpTimestaml(key, localEntity);
      return true;
    } catch (e) {
      this.deleteValue(key);
      return false;
    }
  }

  @override
  Future<void> setValue(String key, String value) async {
    // int exp_timestamp =
    //     (DateTime.now().millisecondsSinceEpoch ~/ 1000) + this._timeout;
    // window.localStorage["${LocalStorageSessionService._PREFIX}:${key}"] =
    //     "${value}:${exp_timestamp}";
  }
}

class _LocalStorageSessionEntity {
  final String value;
  final int timestamp;
  _LocalStorageSessionEntity._(this.value, this.timestamp);

  factory _LocalStorageSessionEntity.parse(String valueRaw) {
    RegExp exp = RegExp(r"^(.+):(\d+)$");
    RegExpMatch matches = exp.allMatches(valueRaw).first;
    String? value = matches[1];
    String? timestampRaw = matches[2];
    if (value == null || timestampRaw == null) {
      throw StateError("Wrong raw value");
    }
    int timestamp = int.parse(timestampRaw);
    int currentTimestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    if (currentTimestamp > timestamp) {
      throw StateError("Value time expired");
    }
    return _LocalStorageSessionEntity._(value, timestamp);
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

class _CompleterEntry {
  final Completer<dynamic> completer;
  final Timer timer;
  _CompleterEntry(this.completer, this.timer);
}
