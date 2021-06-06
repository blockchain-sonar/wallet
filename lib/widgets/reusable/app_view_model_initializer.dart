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

import "package:flutter/material.dart" show CircularProgressIndicator;
import "package:flutter/widgets.dart"
    show
        BuildContext,
        Key,
        State,
        StatefulWidget,
        VoidCallback,
        Widget,
        WidgetBuilder;
import "package:pedantic/pedantic.dart" show unawaited;

import "../../viewmodel/app_view_model.dart" show AppViewModel;

class AppViewModelInitializer extends StatefulWidget {
  final AppViewModel appViewModel;
  final Uint8List encryptionKey;
  final VoidCallback _onSuccess;
  final WidgetBuilder _failureBuilder;

  const AppViewModelInitializer(
    this.appViewModel,
    this.encryptionKey, {
    required VoidCallback onSuccess,
    required WidgetBuilder failureBuilder,
    Key? key,
  })  : this._onSuccess = onSuccess,
        this._failureBuilder = failureBuilder,
        super(key: key);

  @override
  _AppViewModelInitializerState createState() =>
      _AppViewModelInitializerState();
}

class _AppViewModelInitializerState extends State<AppViewModelInitializer> {
  bool _fauilure = false;

  @override
  void initState() {
    super.initState();
    unawaited(this._initialize());
  }

  Future<void> _initialize() async {
    try {
      await this.widget.appViewModel.initialize(this.widget.encryptionKey);
    } catch (e) {
      //
      setState(() {
        this._fauilure = true;
      });
    }

    this.widget._onSuccess();
  }

  @override
  Widget build(BuildContext context) {
    if (this._fauilure) {
      return this.widget._failureBuilder(context);
    } else {
      return CircularProgressIndicator(
        semanticsLabel: "Circular progress indicator",
      );
    }
  }
}
