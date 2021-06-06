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

import "package:flutter/material.dart"
    show
        BuildContext,
        Colors,
        Column,
        CrossAxisAlignment,
        FontWeight,
        Icon,
        IconButton,
        Icons,
        ListTile,
        ListView,
        MainAxisAlignment,
        Row,
        StatelessWidget,
        Text,
        TextStyle,
        Widget;
import "package:flutter/widgets.dart"
    show BuildContext, Column, StatelessWidget, Text, Widget;
import "../reusable/change_detector.dart" show ChangeDetector;
import "../../viewmodel/account_view_mode.dart" show AccountViewModel;
import "../../viewmodel/key_pair_view_model.dart" show KeyPairViewModel;

import "../../viewmodel/app_view_model.dart" show AppViewModel;
import "../../viewmodel/seed_view_model.dart" show SeedViewModel;

import "../layout/my_scaffold.dart" show MyScaffold;

class SettingsWalletManagerWidget extends StatelessWidget {
  final AppViewModel _appViewModel;

  SettingsWalletManagerWidget(
    this._appViewModel,
  );

  void _changeKeyPairHiddenState(KeyPairViewModel keyPair) {
    this._appViewModel.setKeyPairHidden(
          keyPair.parentSeed.seedId,
          keyPair.keyPairId,
          !keyPair.isHidden,
        );
  }

  void _changeAccountHiddenState(AccountViewModel account) {
    this._appViewModel.setAccountHidden(
          account.parentKeyPair.parentSeed.seedId,
          account.parentKeyPair.keyPairId,
          account.blockchainAddress,
          !account.isHidden,
        );
  }

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      appBarTitle: "Wallet Manager",
      body: ListView(
        children: ListTile.divideTiles(
            context: context,
            tiles: this
                ._appViewModel
                .seeds
                .map((SeedViewModel seed) => this.seedWidget(seed))).toList(),
      ),
    );
  }

  Widget seedWidget(SeedViewModel seed) {
    return ChangeDetector(this._appViewModel, builder: (_) {
      return Column(
        children: <Widget>[
          ListTile(
            title: Text(
              "Seed #${seed.seedId.toString()}",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...seed.keyPairs.map((KeyPairViewModel kp) => this.keyPairWidget(kp))
        ],
      );
    });
  }

  Widget keyPairWidget(KeyPairViewModel keyPair) {
    return Column(
      children: <Widget>[
        ListTile(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text("Key pair #${keyPair.name}"),
              IconButton(
                onPressed: () => this._changeKeyPairHiddenState(keyPair),
                splashRadius: 20,
                icon: Icon(
                  Icons.visibility,
                  color: keyPair.isHidden ? Colors.grey : Colors.blue,
                ),
              ),
            ],
          ),
        ),
        ...keyPair.accounts
            .map((AccountViewModel account) => this.accountWidget(account))
      ],
    );
  }

  Widget accountWidget(AccountViewModel account) {
    return Column(
      children: <Widget>[
        ListTile(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text("Contract ${account.smartContractFullQualifiedName}"),
                  Text(
                    "${account.blockchainAddress}",
                    style: TextStyle(
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: () => this._changeAccountHiddenState(account),
                splashRadius: 20,
                icon: Icon(
                  Icons.visibility,
                  color: account.isHidden ? Colors.grey : Colors.blue,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
