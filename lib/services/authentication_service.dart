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

import "package:flutter/widgets.dart" show ChangeNotifier;

abstract class AuthenticationService extends ChangeNotifier {
  bool get isLogged;
  @override
  void dispose();
  Future<void> login(String masterPassword);
  void logout();
}

class AuthenticationServiceLocalStotage extends AuthenticationService {
  bool _isLogged;

  AuthenticationServiceLocalStotage() : this._isLogged = false;

  @override
  bool get isLogged => this._isLogged;

  @override
  void dispose() {
    super.dispose();
    print("AuthenticationServiceLocalStotage has been destroyed.");
  }

  @override
  Future<void> login(String masterPassword) async {
    this._isLogged = true;
    await Future<void>.delayed(Duration(seconds: 3));
    this.notifyListeners();
  }

  @override
  Future<void> logout() async {
    this._isLogged = false;
    await Future<void>.delayed(Duration(seconds: 3));
    this.notifyListeners();
  }
}
