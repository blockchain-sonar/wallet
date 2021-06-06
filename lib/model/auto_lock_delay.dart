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

abstract class AutoLockDelay {
  static const AutoLockDelay HalfMinute = _HalfMinute();

  static void _initMap() {
    _map.addAll(
      Map<String, AutoLockDelay>.fromIterable(<AutoLockDelay>[
        HalfMinute,
      ], key: (dynamic currency) => currency._name),
    );
  }

  static AutoLockDelay parse(final String autoLockDelayName) {
    if (_map.length == 0) {
      _initMap();
    }
    if (_map.containsKey(autoLockDelayName)) {
      return _map[autoLockDelayName]!;
    }
    throw ArgumentError.value(
      autoLockDelayName,
      "autoLockDelayName",
      "Cannot parse value",
    );
  }

  Duration get duration => this._duration;

  String toJson() {
    return this._name;
  }

  @override
  String toString() => this._name;

  static final Map<String, AutoLockDelay> _map = Map<String, AutoLockDelay>();
  final String _name;
  final Duration _duration;
  const AutoLockDelay._(this._name, this._duration);
}

class _HalfMinute extends AutoLockDelay {
  const _HalfMinute()
      : super._(
          "HalfMinute",
          const Duration(seconds: 30),
        );
}
