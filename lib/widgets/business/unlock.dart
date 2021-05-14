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
        Colors,
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
        FontWeight,
        Icon,
        Key,
        Padding,
        State,
        StatefulWidget,
        StatelessWidget,
        Text,
        TextEditingController,
        TextStyle,
        Widget;
import 'package:freemework/freemework.dart';

import "package:freemework_cancellation/freemework_cancellation.dart"
    show CancellationTokenSource;

import "../reusable/button_widget.dart" show FWCancelFloatingActionButton;
import "../reusable/logo_widget.dart" show FWLogo128Widget;
import "../toolchain/dialog_widget.dart"
    show DialogActionContentWidget, DialogCallback, DialogHostCallback, DialogWidget;

class UnlockContext {
  final String password;

  UnlockContext(this.password);
}

class UnlockWidget extends StatelessWidget {
  final DialogHostCallback<UnlockContext> _onComplete;

  UnlockWidget({
    required DialogHostCallback<UnlockContext> onComplete,
  }) : this._onComplete = onComplete;

  @override
  Widget build(BuildContext context) {
    return DialogWidget<UnlockContext>(
      onComplete: this._onComplete,
      child: _UnlockWidget(),
    );
  }
}

class _UnlockWidget extends DialogActionContentWidget<UnlockContext> {
  @override
  Widget buildActive(
    BuildContext context, {
    required DialogCallback<UnlockContext> onComplete,
  }) =>
      _UnlockActiveWidget(onComplete);

  @override
  Widget buildBusy(
    BuildContext context, {
    required CancellationTokenSource cancellationTokenSource,
    Widget? feedbackInfoWidget,
  }) {
    return _buildContainer(
        Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: CircularProgressIndicator(
                semanticsLabel: "Circular progress indicator",
              ),
            ),
            if (feedbackInfoWidget != null)
              Expanded(
                child: feedbackInfoWidget,
              )
          ],
        ),
        floatingActionButton: FWCancelFloatingActionButton(
          onPressed: cancellationTokenSource.cancel,
        ));
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
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                "Welcome back",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: Colors.blueGrey,
                ),
              ),
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

class _UnlockActiveWidget extends StatefulWidget {
  final DialogCallback<UnlockContext> onComplete;
  _UnlockActiveWidget(
    this.onComplete, {
    Key? key,
  }) : super(key: key);

  @override
  _UnlockActiveWidgetState createState() => _UnlockActiveWidgetState();
}

class _UnlockActiveWidgetState extends State<_UnlockActiveWidget> {
  final TextEditingController _passwordTextEditingController =
      TextEditingController();
  String? _errorMessage;

  @override
  void initState() {
    final UnlockContext? dataContextInit =
        DialogWidget.of<UnlockContext>(this.context).dataContextInit;
    if (dataContextInit != null) {
      this._passwordTextEditingController.text = dataContextInit.password;
    }
    this._errorMessage = null;
    super.initState();
  }

  @override
  void dispose() {
    this._passwordTextEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final UnlockContext? dataContextInit =
        DialogWidget.of<UnlockContext>(this.context).dataContextInit;
    if (dataContextInit != null) {
      this._passwordTextEditingController.text = dataContextInit.password;
    }

    return _UnlockWidget._buildContainer(
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: <Widget>[
              if (this._errorMessage != null) Text(this._errorMessage!),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextField(
                  controller: _passwordTextEditingController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Master Password",
                  ),
                  obscureText: true,
                ),
              ),
              // Padding(
              //   padding: const EdgeInsets.symmetric(vertical: 8.0),
              //   child: SizedBox(
              //     width: double.infinity,
              //     child: FWButton(
              //       "Continue",
              //       onPressed: () {
              //         widget.onComplete(UnlockContext(
              //             this._passwordTextEditingController.text));
              //       },
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            try {
              widget.onComplete(
                  UnlockContext(this._passwordTextEditingController.text));
            } catch (e) {
              String msg;
              if (e is FreemeworkException) {
                msg = e.message ?? "Unknown error";
              } else {
                msg = "Unknown error";
              }
              setState(() {
                this._errorMessage = msg;
              });
            }
          },
          tooltip: "Continue",
          child: Icon(Icons.login),
        ));
  }
}
