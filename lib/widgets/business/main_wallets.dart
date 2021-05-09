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

import 'package:flutter/material.dart';
import "package:flutter/widgets.dart";
import 'package:freeton_wallet/services/encrypted_db_service.dart';

import "../../states/app_state.dart" show AppState;

class MainWalletsWidget extends StatefulWidget {
  final AppState _appState;

  MainWalletsWidget(this._appState, {Key? key}) : super(key: key);

  @override
  _MainWalletsState createState() => _MainWalletsState();
}

class _MainWalletsState extends State<MainWalletsWidget> {
  final List<_WalletViewModel> _wallets;

  _MainWalletsState() : this._wallets = <_WalletViewModel>[];

  @override
  void initState() {
    super.initState();

    this._wallets.addAll(this
        .widget
        ._appState
        .wallets
        .map((WalletData walletData) => _WalletViewModel(walletData)));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: _buildPanel(),
      ),
    );
  }

  Widget _buildPanel() {
    return ExpansionPanelList(
      expansionCallback: (int index, bool isExpanded) {
        setState(() {
          _wallets[index].isExpanded = !isExpanded;
        });
      },
      children: _wallets.map<ExpansionPanel>((_WalletViewModel item) {
        return ExpansionPanel(
          headerBuilder: (BuildContext context, bool isExpanded) {
            return ListTile(
              title: Row(
                children: <Widget>[
                  const Icon(Icons.vpn_key),
                  SizedBox(width: 10),
                  Text(item.walletData.walletName),
                ],
              ),
            );
          },
          body: ListTile(
              title: Text(item.walletData.keyPublic),
              subtitle:
                  const Text('To delete this panel, tap the trash can icon'),
              trailing: const Icon(Icons.delete),
              onTap: () {
                setState(() {
                  _wallets.removeWhere(
                      (_WalletViewModel currentItem) => item == currentItem);
                });
              }),
          isExpanded: item.isExpanded,
        );
      }).toList(),
    );
  }
}

// stores ExpansionPanel state information
class _WalletViewModel {
  final WalletData _walletData;

  _WalletViewModel(this._walletData) : this.isExpanded = false;

  WalletData get walletData => this._walletData;

  bool isExpanded;
}
