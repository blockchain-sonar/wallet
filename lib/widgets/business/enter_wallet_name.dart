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
        StatelessWidget,
        Text,
        TextEditingController,
        Widget;

import "package:freemework_cancellation/freemework_cancellation.dart"
    show CancellationTokenSource;
import 'package:freeton_wallet/widgets/layout/my_scaffold.dart';

import "../reusable/button_widget.dart" show FWCancelFloatingActionButton;
import "../reusable/logo_widget.dart" show FWLogo128Widget;
import "../toolchain/dialog_widget.dart"
    show
        DialogActionContentWidget,
        DialogCallback,
        DialogHostCallback,
        DialogWidget;

class EnterWalletNameContext {
  final String keyName;

  EnterWalletNameContext(this.keyName);
}

class EnterWalletNameWidget extends StatelessWidget {
  final DialogHostCallback<EnterWalletNameContext> _onComplete;

  EnterWalletNameWidget({
    required DialogHostCallback<EnterWalletNameContext> onComplete,
  }) : this._onComplete = onComplete;

  @override
  Widget build(BuildContext context) {
    return DialogWidget<EnterWalletNameContext>(
      onComplete: this._onComplete,
      child: _EnterWalletNameWidget(),
    );
  }
}

class _EnterWalletNameWidget
    extends DialogActionContentWidget<EnterWalletNameContext> {
  @override
  Widget buildActive(
    BuildContext context, {
    required DialogCallback<EnterWalletNameContext> onComplete,
  }) =>
      _EnterWalletNameActiveWidget(onComplete);

  @override
  Widget buildBusy(
    BuildContext context, {
    required CancellationTokenSource cancellationTokenSource,
    Widget? feedbackInfoWidget,
  }) {
    return MyScaffold(
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
    return MyScaffold(
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

class _EnterWalletNameActiveWidget extends StatefulWidget {
  final DialogCallback<EnterWalletNameContext> onComplete;
  _EnterWalletNameActiveWidget(
    this.onComplete, {
    Key? key,
  }) : super(key: key);

  @override
  _EnterWalletNameActiveWidgetState createState() =>
      _EnterWalletNameActiveWidgetState();
}

class _EnterWalletNameActiveWidgetState
    extends State<_EnterWalletNameActiveWidget> {
  final TextEditingController _actionTextEditingController =
      TextEditingController();

  @override
  void initState() {
    final EnterWalletNameContext? dataContextInit =
        DialogWidget.of<EnterWalletNameContext>(this.context).dataContextInit;
    if (dataContextInit != null) {
      this._actionTextEditingController.text = dataContextInit.keyName;
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
      this._actionTextEditingController.text = dataContextInit.keyName;
    }

    return _EnterWalletNameWidget._buildContainer(
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
                    hintText: "Enter keypair name",
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
