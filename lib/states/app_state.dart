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

import "dart:async" show Timer;
import "dart:collection" show UnmodifiableListView;
import "dart:typed_data" show Uint8List;

import "package:flutter/foundation.dart" show ChangeNotifier;
import "package:freemework/freemework.dart" show InvalidOperationException;
import "../services/encrypted_db_service.dart" show KeyPairBundleData;

class AppState extends ChangeNotifier {
  final List<KeyPairBundleData> _wallets;
  Timer? _autoLogoutTimer;
  Uint8List? _encryptionKey;

  Uint8List get encryptionKey {
    assert(this._encryptionKey != null);
    return this._encryptionKey!;
  }

  bool get isLogged => this._encryptionKey != null;
  UnmodifiableListView<KeyPairBundleData> get wallets =>
      UnmodifiableListView<KeyPairBundleData>(this._wallets);

  AppState()
      : this._autoLogoutTimer = null,
        this._encryptionKey = null,
        this._wallets = <KeyPairBundleData>[];

  void addWallet(KeyPairBundleData walletData) {
    this._wallets.add(walletData);
    this.notifyListeners();
  }

  void prolongAutoLogout() {
    this._verifyLogged();

    this._cancelAutoLogoutTimer();
    this._setupAutoLogoutTimer();
  }

  void setLoginEncryptionKey(Uint8List encryptionKey) {
    this._encryptionKey = encryptionKey;
    this.notifyListeners();
  }

  void _cancelAutoLogoutTimer() {
    final Timer? autoLogoutTimer = this._autoLogoutTimer;
    this._autoLogoutTimer = null;

    if (autoLogoutTimer != null) {
      autoLogoutTimer.cancel();
    }
  }

  void _onAutoLogoutTimer() {
    this._encryptionKey = null;
    this.notifyListeners();
  }

  void _setupAutoLogoutTimer() {
    assert(this._autoLogoutTimer == null);
    this._autoLogoutTimer = Timer(Duration(seconds: 5), () {
      assert(this._autoLogoutTimer != null);
      this._autoLogoutTimer = null;
      this._onAutoLogoutTimer();
    });
  }

  void _verifyLogged() {
    if (!this.isLogged) {
      throw InvalidOperationException(
          "Wrong operation at current state. User is not logged yet.");
    }
  }
}
