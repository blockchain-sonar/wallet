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

import 'package:freeton_wallet/services/blockchain/blockchain.dart';

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
  static const String _PATH_WALLET = "/wallet";
  static const String _PATH_WALLET_DEPLOY = "/wallet/deploy";
  static const String _PATH_WALLET_SENDMONEY = "/wallet/send";
  static const String _PATH_WALLET_NEW = "/wallet/new";

  static AppRouteDataMain? test(Uri routeUri) {
    if (routeUri.path == PATH) {
      return AppRouteDataMain._(MainTab.HOME);
    } else if (routeUri.path == _PATH_WALLET) {
      return AppRouteDataMainWallets();
    } else if (routeUri.path == _PATH_WALLET_NEW) {
      return AppRouteDataMainWalletsNew();
    } else if (routeUri.path == "/setting") {
      return AppRouteDataMain._(MainTab.SETTINGS);
    } else if (routeUri.path.startsWith(_PATH_WALLET_DEPLOY) &&
        routeUri.pathSegments.length == 3) {
      final String accountAddress = routeUri.pathSegments[2];
      return AppRouteDataMainWalletsDeployContract(accountAddress);
    } else if (routeUri.path.startsWith(_PATH_WALLET_SENDMONEY) &&
        routeUri.pathSegments.length == 3) {
      final String accountAddress = routeUri.pathSegments[2];
      return AppRouteDataMainWalletsSendMoney(accountAddress);
    }
    return null;
  }

  final MainTab selectedTab;

  factory AppRouteDataMain.home() => AppRouteDataMain._(MainTab.HOME);
  factory AppRouteDataMain.settings() => AppRouteDataMain._(MainTab.SETTINGS);

  AppRouteDataMain._(this.selectedTab);

  @override
  String get location {
    switch (this.selectedTab) {
      case MainTab.HOME:
        return "/";
      case MainTab.WALLETS:
        final AppRouteDataMain _this = this;
        if (_this is AppRouteDataMainWalletsDeployContract) {
          final String? accountAddress = _this.accountAddress;
          if (accountAddress != null) {
            return "${_PATH_WALLET_DEPLOY}/${accountAddress}";
          }
        } else if (_this is AppRouteDataMainWalletsSendMoney) {
          final String? accountAddress = _this.accountAddress;
          if (accountAddress != null) {
            return "${_PATH_WALLET_DEPLOY}/${accountAddress}";
          }
        }
        return _PATH_WALLET;
      case MainTab.SETTINGS:
        return "/settings";
      default:
        throw UnsupportedError("Cannot resolve location.");
    }
  }
}

class AppRouteDataMainWallets extends AppRouteDataMain {
  AppRouteDataMainWallets() : super._(MainTab.WALLETS);

  // @override
  // String get location => AppRouteDataMain._PATH_WALLET;
}

class AppRouteDataMainWalletsDeployContract extends AppRouteDataMain {
  final String accountAddress;

  AppRouteDataMainWalletsDeployContract(
    this.accountAddress,
  ) : super._(MainTab.WALLETS);

  // @override
  // String get location => AppRouteDataMain._PATH_WALLET;
}

class AppRouteDataMainWalletsSendMoney extends AppRouteDataMain {
  final String accountAddress;

  AppRouteDataMainWalletsSendMoney(
    this.accountAddress,
  ) : super._(MainTab.WALLETS);

  // @override
  // String get location => AppRouteDataMain._PATH_WALLET;
}

class AppRouteDataMainWalletsNew extends AppRouteDataMainWallets {
  AppRouteDataMainWalletsNew() : super();

  @override
  String get location => AppRouteDataMain._PATH_WALLET_NEW;
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
