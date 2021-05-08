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

import "package:flutter/material.dart" show MaterialApp;
import "package:flutter/widgets.dart"
    show
        BuildContext,
        Center,
        State,
        StatefulWidget,
        StatelessWidget,
        Text,
        Widget;
import 'package:freemework_cancellation/freemework_cancellation.dart';

class SplashWidget extends StatefulWidget {
  SplashWidget();

  @override
  State<StatefulWidget> createState() => _SplashState();
}

class _SplashState extends State<SplashWidget> {
  ManualCancellationTokenSource? _cts;

  _SplashState() : this._cts = null;

  @override
  void initState() {
    super.initState();

    final ManualCancellationTokenSource cts = ManualCancellationTokenSource();
    this._cts = cts;

    // this._loadRoutePath().then((String routePath) {
    //   this.widget.onChangeRoute(routePath);
    // }).catchError((dynamic error, dynamic stackTrace) {
    //   this.widget.onChangeRoute(AppRouteDataCrash.PATH);
    // }).whenComplete(() => cts.cancel());
  }

  @override
  void dispose() {
    ManualCancellationTokenSource? cts = this._cts;
    this._cts = null;
    if (cts != null) {
      cts.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("Loading"),
    );
  }

  // Future<String> _loadRoutePath() async {
  //   await Future<void>.delayed(Duration(seconds: 1));
  //   final bool isInitialized = this.widget.encryptedDbService.isInitialized;
  //   if (!isInitialized) {
  //     return AppRouteDataNewbeWizzard.PATH;
  //   } else {
  //     final bool isLogged = this.widget.appState.isLogged;
  //     if (isLogged) {
  //       return AppRouterDataUnknown.PATH;
  //     } else {
  //       return AppRouterDataSignin.PATH;
  //     }
  //   }
  // }
}

class SplashStandalone extends MaterialApp {
  SplashStandalone()
      : super(
          home: SplashWidget(),
        );
}
