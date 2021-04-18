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

import "package:flutter/material.dart"
    show
        FloatingActionButton,
        Icons,
        InputDecoration,
        CircularProgressIndicator,
        OutlineInputBorder,
        Scaffold,
        TextField;

import "package:flutter/widgets.dart"
    show
        BuildContext,
        Center,
        Column,
        EdgeInsets,
        Expanded,
        Icon,
        Key,
        MainAxisAlignment,
        Padding,
        State,
        StatefulWidget,
        Text,
        TextEditingController,
        Widget;

import "package:freemework_cancellation/freemework_cancellation.dart"
    show CancellationTokenSource;

import "../reusable/button_widget.dart" show FWCancelFloatingActionButton;
import "../reusable/logo_widget.dart" show FWLogo128Widget;
import "../toolchain/dialog_widget.dart"
    show DialogCallback, DialogWidget, DialogActionContentWidget;

class EnterWalletNameContext {
  final String walletName;

  EnterWalletNameContext(this.walletName);
}

class EnterWalletNameWidget
    extends DialogActionContentWidget<EnterWalletNameContext> {
  @override
  Widget buildActive(
    BuildContext context, {
    required DialogCallback<EnterWalletNameContext> onComplete,
  }) =>
      _EnterWalletNameWidget(onComplete);

  @override
  Widget buildBusy(
    BuildContext context, {
    required CancellationTokenSource cancellationTokenSource,
    Widget? feedbackInfoWidget,
  }) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CircularProgressIndicator(
              semanticsLabel: "Circular progress indicator",
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text("Please wait..."),
            )
          ],
        ),
      ),
      floatingActionButton: FWCancelFloatingActionButton(
        onPressed: cancellationTokenSource.cancel,
      ),
    );
  }

  static Widget _buildContainer(
    Widget body, {
    required FloatingActionButton floatingActionButton,
  }) {
    return Scaffold(
      body: Center(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: FWLogo128Widget(),
            ),
            Expanded(
              child: body,
            )
          ],
        ),
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}

class _EnterWalletNameWidget extends StatefulWidget {
  final DialogCallback<EnterWalletNameContext> onComplete;
  _EnterWalletNameWidget(
    this.onComplete, {
    Key? key,
  }) : super(key: key);

  @override
  _EnterWalletNameWidgetState createState() => _EnterWalletNameWidgetState();
}

class _EnterWalletNameWidgetState extends State<_EnterWalletNameWidget> {
  final TextEditingController _actionTextEditingController =
      TextEditingController();

  @override
  void initState() {
    final EnterWalletNameContext? dataContextInit =
        DialogWidget.of<EnterWalletNameContext>(this.context).dataContextInit;
    if (dataContextInit != null) {
      this._actionTextEditingController.text = dataContextInit.walletName;
    }
    super.initState();
  }

  @override
  void dispose() {
    this._actionTextEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final EnterWalletNameContext? dataContextInit =
        DialogWidget.of<EnterWalletNameContext>(this.context).dataContextInit;
    if (dataContextInit != null) {
      this._actionTextEditingController.text = dataContextInit.walletName;
    }

    return EnterWalletNameWidget._buildContainer(
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextField(
                  controller: _actionTextEditingController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Enter wallet name",
                  ),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            widget.onComplete(
                EnterWalletNameContext(this._actionTextEditingController.text));
          },
          tooltip: "Continue",
          child: Icon(Icons.login),
        ));
  }
}
