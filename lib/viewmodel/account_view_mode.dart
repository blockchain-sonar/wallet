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

import "package:flutter/widgets.dart" show ChangeNotifier;

import "../misc/ton_decimal.dart" show TonDecimal;
import "../services/encrypted_db_service.dart" show AccountType;
import "key_pair_view_model.dart" show KeyPairViewModel;
import "../model/account_model.dart" show AccountModel;

class AccountViewModel extends ChangeNotifier {
  final KeyPairViewModel parentKeyPair;
  final AccountModel _accountModel;
  TonDecimal? _balance;
  AccountType? _accountType;

  AccountViewModel(final AccountModel accountModel, this.parentKeyPair)
      : this._accountModel = accountModel,
        this._balance = null,
        this._accountType = null {}

  String get blockchainAddress => this._accountModel.address;
  String get smartContractFullQualifiedName =>
      this._accountModel.contractQualifiedName;
  bool get isCollapsed => this._accountModel.isCollapsed;
  void set isCollapsed(bool value) {
    if (this._accountModel.isCollapsed != value) {
      this._accountModel.isCollapsed = value;
      this.parentKeyPair.parentSeed.appViewModel.scheduleSaveUiData();
      this.notifyListeners();
    }
  }

  bool get isHidden => this._accountModel.isHidden;
  void set isHidden(bool value) {
    if (this._accountModel.isHidden != value) {
      this._accountModel.isHidden = value;
      this.parentKeyPair.parentSeed.appViewModel.scheduleSaveUiData();
      this.notifyListeners();
    }
  }

  AccountType? get accountType => this._accountType;
  set accountType(AccountType? value) {
    this._accountType = value;
    this.notifyListeners();
  }

  TonDecimal? get balance => this._balance;
  set balance(TonDecimal? value) {
    this._balance = value;
    this.notifyListeners();
  }
}
