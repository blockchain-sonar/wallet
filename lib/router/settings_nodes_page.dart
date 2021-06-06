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

import "dart:typed_data" show Uint8List;

import "package:flutter/src/animation/animation.dart" show Animation;
import "package:flutter/widgets.dart"
    show BuildContext, ObjectKey, Page, PageRouteBuilder, Route, Widget;
import 'package:freeton_wallet/viewmodel/app_view_model.dart';
import "package:provider/provider.dart" show Consumer;

import "../services/encrypted_db_service.dart" show EncryptedDbService;
import "../widgets/business/main_settings_nodes.dart" show SettingsNodesWidget;
import "app_route_data.dart" show AppRouteDataMainSettingsNodes;

class SettingsNodesPage extends Page<AppRouteDataMainSettingsNodes> {
  final AppViewModel _appViewModel;

  SettingsNodesPage(this._appViewModel)
      : super(
          key: ObjectKey(SettingsNodesPage),
        );

  @override
  Route<AppRouteDataMainSettingsNodes> createRoute(BuildContext context) {
    return PageRouteBuilder<AppRouteDataMainSettingsNodes>(
      settings: this,
      pageBuilder: (BuildContext context, Animation<double> animation,
          Animation<double> animation2) {
        return SettingsNodesWidget(this._appViewModel);
      },
    );
  }
}
