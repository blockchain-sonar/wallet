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

import "package:flutter/src/animation/animation.dart" show Animation;
import "package:flutter/widgets.dart"
    show BuildContext, Page, PageRouteBuilder, Route, ValueKey, Widget;
import "package:provider/provider.dart" show Consumer;

import "../services/encrypted_db_service.dart" show EncryptedDbService;
import "../services/job.dart" show JobService;
import "../states/app_state.dart" show AppState;
import "../widgets/business/main_settings.dart" show SelectSettingsNodesCallback;
import "../widgets/business/main_wallets.dart"
    show DeployContractCallback, SendMoneyCallback;
import "../widgets/business/main_tab.dart" show MainTab;
import "../widgets/business/main.dart" show MainWidget;
import "app_route_data.dart" show AppRouteDataMain;

class MainPage extends Page<AppRouteDataMain> {
  //final AppState _appState;
  final JobService _jobService;
  final EncryptedDbService _encryptedDbService;
  final void Function() _onSelectHome;
  final void Function() _onSelectWallets;
  final void Function() _onSelectSettings;
  final void Function() _onWalletNew;
  final DeployContractCallback onDeployContract;
  final SendMoneyCallback onSendMoney;
  final SelectSettingsNodesCallback onSelectSettingsNodes;
  final AppRouteDataMain _routeDataMain;

  MainPage(
    this._routeDataMain,
    //this._appState,
    this._encryptedDbService, {
    required JobService jobService,
    required void Function() onSelectHome,
    required void Function() onSelectWallets,
    required void Function() onSelectSetting,
    required void Function() onWalletNew,
    required this.onDeployContract,
    required this.onSendMoney,
    required this.onSelectSettingsNodes,
  })  : this._jobService = jobService,
        this._onSelectHome = onSelectHome,
        this._onSelectWallets = onSelectWallets,
        this._onSelectSettings = onSelectSetting,
        this._onWalletNew = onWalletNew,
        super(
          key: ValueKey<MainTab>(_routeDataMain.selectedTab),
        );

  @override
  Route<AppRouteDataMain> createRoute(BuildContext context) {
    return PageRouteBuilder<AppRouteDataMain>(
      settings: this,
      pageBuilder: (BuildContext context, Animation<double> animation,
          Animation<double> animation2) {
        return Consumer<AppState>(
          builder: (BuildContext context, AppState appState, Widget? child) =>
              MainWidget(
            appState,
            this._encryptedDbService,
            this._routeDataMain.selectedTab,
            jobService: this._jobService,
            onSelectHome: this._onSelectHome,
            onSelectSettings: this._onSelectSettings,
            onSelectWallets: this._onSelectWallets,
            onAddNewKey: this._onWalletNew,
            onDeployContract: this.onDeployContract,
            onSendMoney: this.onSendMoney,
            onSelectSettingsNodes: this.onSelectSettingsNodes,
          ),
        );
      },
    );
  }
}
