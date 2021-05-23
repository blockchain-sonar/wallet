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

import 'package:flutter/src/widgets/basic.dart';
import "package:flutter/widgets.dart"
    show
        Alignment,
        BuildContext,
        Container,
        EdgeInsets,
        Icon,
        Key,
        Padding,
        Row,
        SingleChildScrollView,
        SizedBox,
        State,
        StatefulWidget,
        Text,
        UniqueKey,
        Widget;
import "package:flutter/material.dart"
    show
        AppBar,
        BottomNavigationBar,
        Colors,
        ExpansionPanel,
        ExpansionPanelList,
        FloatingActionButton,
        Icons,
        InkWell,
        ListTile,
        Material,
        Scaffold;

import "../../services/encrypted_db_service.dart" show KeyPairBundleData;
import "../../states/app_state.dart" show AppState;

typedef MainWalletsDeployContractCallback = void Function(String keypairName);

class MainWalletsWidget extends StatefulWidget {
  final AppState _appState;
  final void Function() onAddNewKey;
  final MainWalletsDeployContractCallback onDeployContract;
  final BottomNavigationBar bottomNavigationBar;

  MainWalletsWidget(
    this._appState,
    this.bottomNavigationBar, {
    required this.onAddNewKey,
    required this.onDeployContract,
    Key? key,
  }) : super(key: key);

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
        .map((KeyPairBundleData walletData) => _WalletViewModel(walletData))
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
      bottomNavigationBar: this.widget.bottomNavigationBar,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: this.widget.onAddNewKey,
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
                  Text(item.walletData.keypairName),
                ],
              ),
            );
          },
          body: Column(
            children: <Widget>[
              ListTile(
                  title: Text(item.walletData.keyPublic),
                  subtitle: const Text(
                      "To delete this panel, tap the trash can icon"),
                  trailing: const Icon(Icons.delete),
                  onTap: () {
                    setState(() {
                      _wallets.removeWhere((_WalletViewModel currentItem) =>
                          item == currentItem);
                    });
                  }),
              SizedBox.fromSize(
                size: Size(56, 56), // button width and height
                child: ClipOval(
                  child: Material(
                    color: Colors.orange, // button color
                    child: InkWell(
                      splashColor: Colors.green, // splash color
                      onTap: () {
                        this
                            .widget
                            .onDeployContract(item.walletData.keypairName);
                      }, // button pressed
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(Icons.addchart_rounded), // icon
                          Text("Add Wallet/Contact"), // text
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          isExpanded: item.isExpanded,
        );
      }).toList(),
    );
  }
}

// stores ExpansionPanel state information
class _WalletViewModel {
  final KeyPairBundleData _walletData;

  _WalletViewModel(this._walletData) : this.isExpanded = true;

  KeyPairBundleData get walletData => this._walletData;

  bool get hasMnemonicPhrase => true;

  bool isExpanded;
}
