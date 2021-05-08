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
    show BuildContext, Page, PageRouteBuilder, Route, ValueKey;

import '../widgets/business/crash.dart' show CrashWidget;
import "app_route_data.dart" show AppRouteDataCrash;

class CrashPage extends Page<AppRouteDataCrash> {
  final String? crashMessage;

  CrashPage([
    this.crashMessage,
  ]) : super(key: ValueKey<Object>(CrashPage));

  @override
  Route<AppRouteDataCrash> createRoute(BuildContext context) {
    return PageRouteBuilder<AppRouteDataCrash>(
      settings: this,
      pageBuilder: (BuildContext context, Animation<double> animation,
          Animation<double> animation2) {
        // final tween = Tween(begin: Offset(0.0, 1.0), end: Offset.zero);
        // final curveTween = CurveTween(curve: Curves.easeInOut);
        // return SlideTransition(
        //   position: animation.drive(curveTween).drive(tween),
        //   child: BookDetailsScreen(
        //     key: ValueKey(book),
        //     book: book,
        //   ),
        // );
        return CrashWidget();
      },
    );
  }
}
