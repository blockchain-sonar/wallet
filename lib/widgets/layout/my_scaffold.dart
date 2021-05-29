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

import "package:flutter/material.dart" show AppBar, Colors, Scaffold;
import 'package:flutter/src/widgets/basic.dart';
import "package:flutter/widgets.dart"
    show
        Alignment,
        BoxConstraints,
        BuildContext,
        Container,
        StatelessWidget,
        Text,
        Widget;

class MyScaffold extends StatelessWidget {
  final Widget body;
  final String? appBarTitle;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;

  MyScaffold({
    required this.body,
    this.appBarTitle,
    this.bottomNavigationBar,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Container(
          constraints: BoxConstraints(
            minWidth: 320,
            maxWidth: 480,
            minHeight: 480,
            maxHeight: 640,
          ),
          child: MyScaffold1(
            body: body,
            appBarTitle: appBarTitle,
            bottomNavigationBar: bottomNavigationBar,
            floatingActionButton: floatingActionButton,
          ),
        ),
      ),
    );
  }
}

class MyScaffold1 extends Scaffold {
  factory MyScaffold1({
    required Widget body,
    String? appBarTitle,
    Widget? bottomNavigationBar,
    Widget? floatingActionButton,
  }) {
    return MyScaffold1._(
      body: body,
      appBarTitle: appBarTitle,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
    );
  }

  MyScaffold1._({
    required Widget body,
    String? appBarTitle,
    Widget? bottomNavigationBar,
    Widget? floatingActionButton,
  }) : super(
          appBar: (appBarTitle != null)
              ? AppBar(
                  title: Text(appBarTitle),
                )
              : null,
          body: Container(
            alignment: Alignment.topCenter,
            child: body,
          ),
          bottomNavigationBar: bottomNavigationBar,
          floatingActionButton: floatingActionButton,
        );
}
