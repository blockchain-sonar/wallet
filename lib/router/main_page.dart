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

import "package:flutter/animation.dart" show Animation;
import "package:flutter/widgets.dart"
    show BuildContext, Page, PageRouteBuilder, Route, ValueKey;

import "../widgets/business/main_tab.dart" show MainTab;
import "../widgets/business/main.dart" show MainWidget, MainWidgetApi;
import "../widgets/reusable/change_detector.dart";
import "app_route_data.dart" show AppRouteDataMain;

class MainPage extends Page<AppRouteDataMain> {
  final MainWidgetApi _mainWidgetApi;
  final AppRouteDataMain _routeDataMain;

  MainPage(this._routeDataMain, this._mainWidgetApi)
      : super(
          key: ValueKey<MainTab>(_routeDataMain.selectedTab),
        );

  @override
  Route<AppRouteDataMain> createRoute(BuildContext context) {
    return PageRouteBuilder<AppRouteDataMain>(
      settings: this,
      pageBuilder: (BuildContext context, Animation<double> animation,
          Animation<double> animation2) {
        return ChangeDetector(
          this._mainWidgetApi.appViewModel,
          builder: (BuildContext context) => MainWidget(
            this._mainWidgetApi,
            this._routeDataMain.selectedTab,
          ),
        );
      },
    );
  }
}
