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
        CircularProgressIndicator,
        Colors,
        FloatingActionButton,
        Icons,
        InputDecoration,
        OutlineInputBorder,
        Scaffold,
        TextField;

import "package:flutter/widgets.dart"
    show
        Alignment,
        BorderRadius,
        BoxDecoration,
        BuildContext,
        Center,
        Column,
        Container,
        EdgeInsets,
        Expanded,
        Flexible,
        FontWeight,
        Icon,
        IconData,
        Key,
        MainAxisAlignment,
        Padding,
        Radius,
        State,
        StatefulWidget,
        StatelessWidget,
        Text,
        TextEditingController,
        TextStyle,
        Widget;

import "package:freemework_cancellation/freemework_cancellation.dart"
    show CancellationTokenSource;

import "../reusable/button_widget.dart" show FWCancelFloatingActionButton;
import "../toolchain/dialog_widget.dart"
    show
        DialogActionContentWidget,
        DialogCallback,
        DialogHostCallback,
        DialogWidget;

class RestoreByPrivateKeyContext {
  final String privateKey;

  RestoreByPrivateKeyContext(this.privateKey);
}

class RestoreByPrivateKeyWidget extends StatelessWidget {
  final RestoreByPrivateKeyContext? _dataContextInit;
  final DialogHostCallback<RestoreByPrivateKeyContext> _onComplete;

  RestoreByPrivateKeyWidget({
    required DialogHostCallback<RestoreByPrivateKeyContext> onComplete,
    RestoreByPrivateKeyContext? dataContextInit,
  })  : this._onComplete = onComplete,
        this._dataContextInit = dataContextInit;

  @override
  Widget build(BuildContext context) {
    return DialogWidget<RestoreByPrivateKeyContext>(
      onComplete: this._onComplete,
      dataContextInit: this._dataContextInit,
      child: _RestoreByPrivateKeyWidget(),
    );
  }
}

class _RestoreByPrivateKeyWidget
    extends DialogActionContentWidget<RestoreByPrivateKeyContext> {
  @override
  Widget buildActive(
    BuildContext context, {
    required DialogCallback<RestoreByPrivateKeyContext> onComplete,
  }) =>
      _RestoreByPrivateKeyActiveWidget(onComplete);

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
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(5.0),
          ),
          Text(
            "Restore by private key",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
          ),
          Expanded(
            child: body,
          ),
        ],
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}

class _RestoreByPrivateKeyActiveWidget extends StatefulWidget {
  final DialogCallback<RestoreByPrivateKeyContext> onComplete;
  _RestoreByPrivateKeyActiveWidget(
    this.onComplete, {
    Key? key,
  }) : super(key: key);

  @override
  _RestoreByPrivateKeyActiveWidgetState createState() =>
      _RestoreByPrivateKeyActiveWidgetState();
}

class _RestoreByPrivateKeyActiveWidgetState
    extends State<_RestoreByPrivateKeyActiveWidget> {
  final TextEditingController _actionTextEditingController =
      TextEditingController();

  @override
  void initState() {
    final RestoreByPrivateKeyContext? dataContextInit =
        DialogWidget.of<RestoreByPrivateKeyContext>(this.context)
            .dataContextInit;
    if (dataContextInit != null) {
      this._actionTextEditingController.text = dataContextInit.privateKey;
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
    final RestoreByPrivateKeyContext? dataContextInit =
        DialogWidget.of<RestoreByPrivateKeyContext>(this.context)
            .dataContextInit;
    if (dataContextInit != null) {
      this._actionTextEditingController.text = dataContextInit.privateKey;
    }

    return _RestoreByPrivateKeyWidget._buildContainer(
        Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                  "Please enter your private key below. This can only contain hexadecimal characters."),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.all(
                      const Radius.circular(5.0),
                    ),
                  ),
                  child: TextField(
                    maxLines: 10,
                    minLines: 5,
                    controller: this._actionTextEditingController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Private Key",
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            widget.onComplete(RestoreByPrivateKeyContext(
                this._actionTextEditingController.text));
          },
          tooltip: "Continue",
          child: Icon(Icons.login),
        ));
  }
}
