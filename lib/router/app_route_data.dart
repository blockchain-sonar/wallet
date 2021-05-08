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

abstract class AppRouteData {
  factory AppRouteData.fromUrl(Uri routeUri) {
    print("AppRouteData.fromUrl routeUri: $routeUri, routeUri.path: ${routeUri.path}");
    switch (routeUri.path) {
      case AppRouteDataSplash.PATH:
        return AppRouteDataSplash();
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

class AppRouterDataMain extends AppRouteData {
  static const String PATH = "/main";

  @override
  String get location => PATH;
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

class AppRouteDataSplash extends AppRouteData {
  static const String PATH = "/";

  @override
  String get location => PATH;
}

class AppRouterDataUnknown extends AppRouteData {
  static const String PATH = "/404";

  @override
  String get location => PATH;
}
