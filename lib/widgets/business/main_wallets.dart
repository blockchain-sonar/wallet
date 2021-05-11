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

import '../../misc/void_callback_host.dart';
import '../../services/encrypted_db_service.dart';
import "../../states/app_state.dart" show AppState;

class MainWalletsWidget extends StatefulWidget {
  final AppState _appState;
  final void Function() _onWalletNew;
  final BottomNavigationBar _bottomNavigationBar;

  MainWalletsWidget(
    this._appState,
    this._bottomNavigationBar, {
    required void Function() onWalletNew,
    Key? key,
  })  : this._onWalletNew = onWalletNew,
        super(key: key);

  @override
  _MainWalletsState createState() => _MainWalletsState();
}

class _MainWalletsState extends State<MainWalletsWidget> {
  List<_WalletViewModel> _wallets;

  _MainWalletsState() : this._wallets = <_WalletViewModel>[] {
    print("_MainWalletsState()");
  }

  @override
  void initState() {
    super.initState();
    this._loadWallets();
    this.widget._appState.addListener(this._syncWallets);
  }

  @override
  void dispose() {
    this.widget._appState.removeListener(this._syncWallets);
    super.dispose();
  }

  void _loadWallets() {
    this._wallets = this
        .widget
        ._appState
        .wallets
        .map((WalletData walletData) => _WalletViewModel(walletData))
        .toList();
  }

  void _syncWallets() {
    this.setState(() {
      this._loadWallets();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Wallets"),
      ),
      body: Container(
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: _buildPanel(),
          ),
        ),
      ),
      bottomNavigationBar: this.widget._bottomNavigationBar,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: this.widget._onWalletNew,
      ),
    );
  }

  Widget _buildPanel() {
    return ExpansionPanelList(
      key: UniqueKey(),
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
                  if (item.hasMnemonicPhrase) const Icon(Icons.subtitles),
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

  _WalletViewModel(this._walletData) : this.isExpanded = true;

  WalletData get walletData => this._walletData;

  bool get hasMnemonicPhrase => true;

  bool isExpanded;
}
