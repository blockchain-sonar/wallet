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

import 'dart:async';
import 'dart:typed_data';

import "package:flutter/material.dart";
import "package:flutter/widgets.dart";
import 'package:freeton_wallet/misc/void_callback_host.dart';
import 'package:freeton_wallet/viewmodel/app_view_model.dart';
import 'package:freeton_wallet/widgets/business/main_settings.dart';
import 'package:freeton_wallet/widgets/layout/my_scaffold.dart';
import "main_wallets.dart"
    show DeployContractCallback, MainWalletsWidget, SendMoneyCallback;

import "main_home.dart" show HomeChartWidget;
import "main_tab.dart" show MainTab;

class MainWidgetApi {
  final AppViewModel appViewModel;

  final VoidCallback onSelectHome;
  final VoidCallback onSelectWallets;
  final VoidCallback onSelectSettings;
  final VoidCallback onAddNewKey;
  final DeployContractCallback onDeployContract;
  final SendMoneyCallback onSendMoney;
  final VoidCallback onOpenSettingsNodes;
  final VoidCallback onOpenSettingsWalletManager;

  MainWidgetApi(
    this.appViewModel, {
    // required this.jobService,
    required this.onSelectHome,
    required this.onSelectWallets,
    required this.onSelectSettings,
    required this.onAddNewKey,
    required this.onDeployContract,
    required this.onSendMoney,
    required this.onOpenSettingsNodes,
    required this.onOpenSettingsWalletManager,
  });
}

class MainWidget extends StatelessWidget {
  // static const TextStyle _tabOptionStyle = TextStyle(
  //   fontSize: 30,
  //   fontWeight: FontWeight.bold,
  // );
  static final List<_OptionTuple> _tabOptions = <_OptionTuple>[
    _OptionTuple(
      MainTab.HOME,
      "Home",
      BottomNavigationBarItem(
        icon: Icon(Icons.home),
        label: "Home",
      ),
    ),
    _OptionTuple(
      MainTab.WALLETS,
      "Wallets",
      BottomNavigationBarItem(
        icon: Icon(Icons.account_balance_wallet),
        label: "Wallets",
      ),
    ),
    _OptionTuple(
      MainTab.SETTINGS,
      "Settings",
      BottomNavigationBarItem(
        icon: Icon(Icons.settings),
        label: "Settings",
      ),
    ),
  ];

  final MainWidgetApi _mainWidgetApi;
  final int _selectedIndex;
  // final JobService jobService;

  MainWidget(
    this._mainWidgetApi,
    MainTab selectedTab,
  ) : this._selectedIndex = _tabOptions
            .indexWhere((_OptionTuple tuple) => tuple.tab == selectedTab);

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
      case MainTab.HOME:
        return HomeChartWidget(
          bottomNavigationBar,
        );
      case MainTab.WALLETS:
        return MainWalletsWidget(
          this._mainWidgetApi.appViewModel,
          bottomNavigationBar,
          // jobService: this.jobService,
          onAddNewKey: this._mainWidgetApi.onAddNewKey,
          onDeployContract: this._mainWidgetApi.onDeployContract,
          onSendMoney: this._mainWidgetApi.onSendMoney,
        );
      case MainTab.SETTINGS:
        return SettingsWidget(
          SettingsWidgetApi(
            this._mainWidgetApi.appViewModel,
            onOpenSettingsNodes: this._mainWidgetApi.onOpenSettingsNodes,
            onOpenSettingsWalletManager:
                this._mainWidgetApi.onOpenSettingsWalletManager,
          ),
          bottomNavigationBar,
        );
      default:
        break;
    }

    return MyScaffold(
        appBarTitle: appTitle,
        body: Container(
          // constraints: BoxConstraints(
          //   minWidth: 320,
          //   maxWidth: 800,
          //   minHeight: 480,
          //   maxHeight: 1080,
          // ),
          alignment: Alignment.topCenter,
          child: Text("Opppssss..."),
        ),
        bottomNavigationBar: bottomNavigationBar);
  }

  // Widget _buildContent(BuildContext context) {
  //   final _OptionTuple selectedTuple = _tabOptions.elementAt(_selectedIndex);
  //   switch (selectedTuple.tab) {
  //     case MainTab.HOME:
  //       return selectedTuple.optionWidgetBuilder(context);
  //     case MainTab.WALLETS:
  //       return selectedTuple.optionWidgetBuilder(context);
  //     case MainTab.SETTINGS:
  //       return selectedTuple.optionWidgetBuilder(context);
  //   }
  // }

  void _onItemTapped(int index) {
    final _OptionTuple tapTuple = _tabOptions[index];
    switch (tapTuple.tab) {
      case MainTab.HOME:
        this._mainWidgetApi.onSelectHome();
        break;
      case MainTab.WALLETS:
        this._mainWidgetApi.onSelectWallets();
        break;
      case MainTab.SETTINGS:
        this._mainWidgetApi.onSelectSettings();
        break;
    }
  }
}

class _OptionTuple {
  final MainTab tab;
  final String appTitle;
  //final WidgetBuilder optionWidgetBuilder;
  final BottomNavigationBarItem barItem;

  const _OptionTuple(
    this.tab,
    this.appTitle,
    //this.optionWidgetBuilder,
    this.barItem,
  );
}
