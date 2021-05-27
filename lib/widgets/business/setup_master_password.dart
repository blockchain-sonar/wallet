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
        TextFormField;
import "package:flutter/widgets.dart"
    show
        BuildContext,
        Center,
        Column,
        EdgeInsets,
        Expanded,
        FontWeight,
        Form,
        FormState,
        GlobalKey,
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

import "package:freemework_cancellation/freemework_cancellation.dart"
    show CancellationTokenSource;
import 'package:freeton_wallet/widgets/layout/my_scaffold.dart';

import '../reusable/button_widget.dart' show FWCancelFloatingActionButton;
import '../reusable/logo_widget.dart' show FWLogo128Widget;
import '../toolchain/dialog_widget.dart'
    show
        DialogActionContentWidget,
        DialogCallback,
        DialogHostCallback,
        DialogWidget;

class SetupMasterPasswordContext {
  final String password;

  SetupMasterPasswordContext(this.password);
}

class SetupMasterPasswordWidget extends StatelessWidget {
  final DialogHostCallback<SetupMasterPasswordContext> _onComplete;

  SetupMasterPasswordWidget({
    required DialogHostCallback<SetupMasterPasswordContext> onComplete,
  }) : this._onComplete = onComplete;

  @override
  Widget build(BuildContext context) {
    return DialogWidget<SetupMasterPasswordContext>(
      onComplete: this._onComplete,
      child: _SetupMasterPasswordWidget(),
    );
  }
}

class _SetupMasterPasswordWidget
    extends DialogActionContentWidget<SetupMasterPasswordContext> {
  @override
  Widget buildActive(
    BuildContext context, {
    required DialogCallback<SetupMasterPasswordContext> onComplete,
  }) =>
      _SetupMasterPasswordActiveWidget(onComplete);

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
    return MyScaffold(
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
                "Hi",
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

class _SetupMasterPasswordActiveWidget extends StatefulWidget {
  final DialogCallback<SetupMasterPasswordContext> onComplete;
  _SetupMasterPasswordActiveWidget(
    this.onComplete, {
    Key? key,
  }) : super(key: key);

  @override
  _SetupMasterPasswordActiveWidgetState createState() =>
      _SetupMasterPasswordActiveWidgetState();
}

class _SetupMasterPasswordActiveWidgetState
    extends State<_SetupMasterPasswordActiveWidget> {
  final TextEditingController _passwordTextEditingController =
      TextEditingController();
  final TextEditingController _retryPasswordTextEditingController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    final SetupMasterPasswordContext? dataContextInit =
        DialogWidget.of<SetupMasterPasswordContext>(this.context)
            .dataContextInit;
    if (dataContextInit != null) {
      this._passwordTextEditingController.text = dataContextInit.password;
    }
    super.initState();
  }

  @override
  void dispose() {
    this._passwordTextEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final SetupMasterPasswordContext? dataContextInit =
        DialogWidget.of<SetupMasterPasswordContext>(this.context)
            .dataContextInit;
    if (dataContextInit != null) {
      this._passwordTextEditingController.text = dataContextInit.password;
    }

    return _SetupMasterPasswordWidget._buildContainer(
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Form(
            key: this._formKey,
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextFormField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Create Master Password",
                    ),
                    obscureText: true,
                    validator: (String? value) {
                      final String password =
                          this._passwordTextEditingController.text;
                      final String retrypassword =
                          this._retryPasswordTextEditingController.text;
                      if (password == retrypassword) {
                        return null;
                      }
                      return "Password mismatch";
                    },
                    controller: _passwordTextEditingController,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextFormField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Retry Master Password",
                    ),
                    obscureText: true,
                    validator: (String? value) {
                      final String password =
                          this._passwordTextEditingController.text;
                      final String retrypassword =
                          this._retryPasswordTextEditingController.text;
                      if (password == retrypassword) {
                        return null;
                      }
                      return "Password mismatch";
                    },
                    controller: _retryPasswordTextEditingController,
                  ),
                ),
                // Padding(
                //   padding: const EdgeInsets.symmetric(vertical: 8.0),
                //   child: SizedBox(
                //     width: double.infinity,
                //     child: FWButton(
                //       "Continue",
                //       onPressed: () {
                //         widget.onComplete(SetupMasterPasswordContext(
                //             this._passwordTextEditingController.text));
                //       },
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              widget.onComplete(SetupMasterPasswordContext(
                  this._retryPasswordTextEditingController.text));
            }
          },
          tooltip: "Continue",
          child: Icon(Icons.login),
        ));
  }
}
