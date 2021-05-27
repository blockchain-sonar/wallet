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
    show CircularProgressIndicator, Colors, Icons;
import "package:flutter/widgets.dart"
    show
        BorderRadius,
        BoxDecoration,
        BuildContext,
        Center,
        Column,
        Container,
        EdgeInsets,
        Expanded,
        FontWeight,
        Icon,
        IconData,
        MainAxisAlignment,
        Padding,
        Radius,
        StatelessWidget,
        Text,
        TextStyle,
        Widget;
import "package:freemework_cancellation/freemework_cancellation.dart"
    show CancellationTokenSource;
import 'package:freeton_wallet/widgets/layout/my_scaffold.dart';

import "../reusable/button_widget.dart"
    show FWButton, FWCancelFloatingActionButton;
import "../toolchain/dialog_widget.dart"
    show
        DialogActionContentWidget,
        DialogCallback,
        DialogHostCallback,
        DialogWidget;

enum RestoreMode { MNEMONIC, PRIVATE_KEY }

class RestoreModeSelectorContext {
  final RestoreMode mode;

  RestoreModeSelectorContext(this.mode);
}

class RestoreModeSelectorWidget extends StatelessWidget {
  final DialogHostCallback<RestoreModeSelectorContext> _onComplete;

  RestoreModeSelectorWidget({
    required DialogHostCallback<RestoreModeSelectorContext> onComplete,
  }) : this._onComplete = onComplete;

  @override
  Widget build(BuildContext context) {
    return DialogWidget<RestoreModeSelectorContext>(
      onComplete: this._onComplete,
      child: _RestoreModeSelectorWidget(),
    );
  }
}

class _RestoreModeSelectorWidget
    extends DialogActionContentWidget<RestoreModeSelectorContext> {
  @override
  Widget buildActive(
    BuildContext context, {
    required DialogCallback<RestoreModeSelectorContext> onComplete,
  }) {
    return Container(
      child: MyScaffold(
        body: Column(
          children: <Widget>[
            this._buildItem(
              Icons.add_rounded,
              "Restore By Mnemonic Passphrase",
              "Restore By Mnemonic Passphrase",
              RestoreMode.MNEMONIC,
              onComplete,
            ),
            this._buildItem(
              Icons.archive_outlined,
              "Restore By Private Key",
              "Restore By Private Key",
              RestoreMode.PRIVATE_KEY,
              onComplete,
            ),
          ],
        ),
      ),
    );
  }

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

  Widget _buildItem(
    IconData icon,
    String buttonText,
    String description,
    RestoreMode mode,
    DialogCallback<RestoreModeSelectorContext> onComplete,
  ) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(
              const Radius.circular(5.0),
            ),
          ),
          // color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Icon(icon, size: 64),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: FWButton(
                      buttonText,
                      onPressed: () {
                        onComplete(RestoreModeSelectorContext(mode));
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      description,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Colors.blueGrey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
