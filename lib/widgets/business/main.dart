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

import 'dart:async';

import "package:flutter/material.dart";
import "package:flutter/widgets.dart";
import 'package:freeton_wallet/misc/void_callback_host.dart';
import 'package:freeton_wallet/widgets/business/main_wallets.dart';

import "../../services/encrypted_db_service.dart" show EncryptedDbService;
import "../../states/app_state.dart" show AppState;
import "main_tab.dart" show MainTab;

class MainWidget extends StatelessWidget {
  static const TextStyle _tabOptionStyle = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.bold,
  );
  static List<_OptionTuple> _tabOptions = <_OptionTuple>[
    _OptionTuple(
      MainTab.HOME,
      "Home",
      (BuildContext context) => Text(
        'Index 0: Home',
        style: _tabOptionStyle,
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.home),
        label: 'Home',
      ),
    ),
    _OptionTuple(
      MainTab.WALLETS,
      "Wallets",
      (BuildContext context) => Text(
        'Index 1: Wallets',
        style: _tabOptionStyle,
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.account_balance_wallet),
        label: "Wallets",
      ),
    ),
    _OptionTuple(
      MainTab.SETTINGS,
      "Settings",
      (BuildContext context) => Text(
        'Index 2: Settings',
        style: _tabOptionStyle,
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.settings),
        label: 'Settings',
      ),
    ),
  ];

  final AppState _appState;
  final EncryptedDbService _encryptedDbService;
  final int _selectedIndex;
  final void Function() _onSelectHome;
  final void Function() _onSelectWallets;
  final void Function() _onSelectSettings;
  final void Function() _onWalletNew;

  MainWidget(
    this._appState,
    this._encryptedDbService,
    MainTab selectedTab, {
    required void Function() onSelectHome,
    required void Function() onSelectWallets,
    required void Function() onSelectSettings,
    required void Function() onWalletNew,
  })   : this._selectedIndex = _tabOptions
            .indexWhere((_OptionTuple tuple) => tuple.tab == selectedTab),
        this._onSelectHome = onSelectHome,
        this._onSelectWallets = onSelectWallets,
        this._onSelectSettings = onSelectSettings,
        this._onWalletNew = onWalletNew;

  @override
  Widget build(BuildContext context) {
    final String appTitle = _tabOptions.elementAt(_selectedIndex).appTitle;
    final List<BottomNavigationBarItem> barItems =
        _tabOptions.map((_OptionTuple tuple) => tuple.barItem).toList();

    final BottomNavigationBar bottomNavigationBar = BottomNavigationBar(
      items: barItems,
      currentIndex: _selectedIndex,
      selectedItemColor: Colors.amber[800],
      onTap: _onItemTapped,
    );

    final _OptionTuple selectedTuple = _tabOptions.elementAt(_selectedIndex);
    switch (selectedTuple.tab) {
      case MainTab.WALLETS:
        return MainWalletsWidget(
          this._appState,
          bottomNavigationBar,
          onWalletNew: this._onWalletNew,
        );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(appTitle),
      ),
      body: Container(
        alignment: Alignment.topCenter,
        child: Builder(builder: this._buildContent),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: barItems,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
      // floatingActionButton: FloatingActionButton(
      //   child: Icon(Icons.add),
      //   onPressed: this._onWalletNew,
      // ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final _OptionTuple selectedTuple = _tabOptions.elementAt(_selectedIndex);
    switch (selectedTuple.tab) {
      case MainTab.HOME:
        return selectedTuple.optionWidgetBuilder(context);
      case MainTab.WALLETS:
        return selectedTuple.optionWidgetBuilder(context);
      case MainTab.SETTINGS:
        return selectedTuple.optionWidgetBuilder(context);
    }
  }

  void _onItemTapped(int index) {
    final _OptionTuple tapTuple = _tabOptions[index];
    switch (tapTuple.tab) {
      case MainTab.HOME:
        this._onSelectHome();
        break;
      case MainTab.WALLETS:
        this._onSelectWallets();
        break;
      case MainTab.SETTINGS:
        this._onSelectSettings();
        break;
    }
  }
}

class _OptionTuple {
  final MainTab tab;
  final String appTitle;
  final WidgetBuilder optionWidgetBuilder;
  final BottomNavigationBarItem barItem;

  const _OptionTuple(
      this.tab, this.appTitle, this.optionWidgetBuilder, this.barItem);
}