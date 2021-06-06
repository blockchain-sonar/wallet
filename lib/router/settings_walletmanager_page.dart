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


import "package:flutter/src/animation/animation.dart" show Animation;
import "package:flutter/widgets.dart"
    show BuildContext, ObjectKey, Page, PageRouteBuilder, Route;

import "../viewmodel/app_view_model.dart" show AppViewModel;
import "../widgets/business/main_settings_wallet_manager.dart" show SettingsWalletManagerWidget;

import "app_route_data.dart" show AppRouteDataMainSettingsWalletManager;

class SettingsWalletManagerPage
    extends Page<AppRouteDataMainSettingsWalletManager> {
  final AppViewModel _appViewModel;

  SettingsWalletManagerPage(this._appViewModel)
      : super(
          key: ObjectKey(SettingsWalletManagerPage),
        );

  @override
  Route<AppRouteDataMainSettingsWalletManager> createRoute(
      BuildContext context) {
    return PageRouteBuilder<AppRouteDataMainSettingsWalletManager>(
      settings: this,
      pageBuilder: (BuildContext context, Animation<double> animation,
          Animation<double> animation2) {
        return SettingsWalletManagerWidget(this._appViewModel);
      },
    );
  }
}
