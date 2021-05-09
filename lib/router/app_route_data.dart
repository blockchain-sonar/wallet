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

import "../widgets/business/main_tab.dart" show MainTab;

abstract class AppRouteData {
  factory AppRouteData.fromUrl(Uri routeUri) {
    print(
        "AppRouteData.fromUrl routeUri: $routeUri, routeUri.path: ${routeUri.path}");

    AppRouteData? testResult = AppRouteDataMain.test(routeUri);
    if (testResult != null) {
      return testResult;
    }

    switch (routeUri.path) {
      case AppRouteDataCrash.PATH:
        return AppRouteDataCrash();
      case AppRouteDataNewbeWizzard.PATH:
        return AppRouteDataNewbeWizzard();
      case AppRouterDataSignin.PATH:
        return AppRouterDataSignin();
      default:
        return AppRouterDataUnknown();
    }
  }

  String get location;
  String? get state => null;

  AppRouteData();
}

class AppRouteDataCrash extends AppRouteData {
  static const String PATH = "/crash";

  @override
  String get location => PATH;
}

class AppRouteDataMain extends AppRouteData {
  static const String PATH = "/";

  static AppRouteDataMain? test(Uri routeUri) {
    print("testing: ${routeUri.path}");
    print("testing: ${routeUri.toString()}");
    if (routeUri.path == "/") {
      return AppRouteDataMain._(MainTab.HOME);
    } else if (routeUri.path == "/wallets") {
      return AppRouteDataMain._(MainTab.WALLETS);
    } else if (routeUri.path == "/settings") {
      return AppRouteDataMain._(MainTab.SETTINGS);
    }
    return null;
  }

  final MainTab selectedTab;

  factory AppRouteDataMain.home() => AppRouteDataMain._(MainTab.HOME);
  factory AppRouteDataMain.wallets() => AppRouteDataMain._(MainTab.WALLETS);
  factory AppRouteDataMain.settings() => AppRouteDataMain._(MainTab.SETTINGS);

  AppRouteDataMain._(this.selectedTab);

  @override
  String get location {
    switch (this.selectedTab) {
      case MainTab.HOME:
        return "/";
      case MainTab.WALLETS:
        return "/wallets";
      case MainTab.SETTINGS:
        return "/settings";
      default:
        throw UnsupportedError("Cannot resolve location.");
    }
  }
}

class AppRouteDataNewbeWizzard extends AppRouteData {
  static const String PATH = "/wizzard/newbe";

  @override
  String get location => PATH;
}

class AppRouterDataSignin extends AppRouteData {
  static const String PATH = "/signin";

  @override
  String get location => PATH;
}

class AppRouterDataUnknown extends AppRouteData {
  static const String PATH = "/404";

  @override
  String get location => PATH;
}
