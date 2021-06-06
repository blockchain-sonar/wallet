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

import 'dart:collection';

import "package:flutter/widgets.dart" show ChangeNotifier;
import 'package:freeton_wallet/model/account_model.dart';
import 'package:freeton_wallet/model/key_pair_model.dart';
import 'package:freeton_wallet/model/seed_model.dart';
import 'package:freeton_wallet/services/blockchain/blockchain_service.dart';
import 'package:freeton_wallet/viewmodel/account_view_mode.dart';
import 'package:freeton_wallet/viewmodel/app_view_model.dart';

import 'key_pair_view_model.dart';

class SeedViewModel extends ChangeNotifier {
  final AppViewModel appViewModel;
  final BlockchainService _blockchainService;
  final SeedModel _seedModel;
  final List<KeyPairViewModel> _keyPairs;

  SeedViewModel(
    this._blockchainService,
    this._seedModel,
    this.appViewModel,
  ) : this._keyPairs = <KeyPairViewModel>[] {
    //
    this._keyPairs.addAll(_seedModel.keyPairs
        .map((KeyPairModel accountModel) =>
            KeyPairViewModel(this._blockchainService, accountModel, this))
        .toList(growable: false));
  }

  int get seedId => this._seedModel.seedId;

  UnmodifiableListView<KeyPairViewModel> get keyPairs =>
      UnmodifiableListView<KeyPairViewModel>(this._keyPairs);
}
