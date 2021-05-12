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
        FontWeight,
        Icon,
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

class RestoreByMnemonicPhraseWidget extends StatelessWidget {
  final String _mnemonicPhrase;
  final DialogHostCallback<void> _onComplete;

  RestoreByMnemonicPhraseWidget(
    String mnemonicPhrase, {
    required DialogHostCallback<void> onComplete,
  })   : this._onComplete = onComplete,
        this._mnemonicPhrase = mnemonicPhrase;

  @override
  Widget build(BuildContext context) {
    return DialogWidget<void>(
      onComplete: this._onComplete,
      child: _RestoreByMnemonicPhraseWidget(this._mnemonicPhrase),
    );
  }
}

class _RestoreByMnemonicPhraseWidget extends DialogActionContentWidget<void> {
  final String _mnemonicPhrase;

  _RestoreByMnemonicPhraseWidget(String mnemonicPhrase)
      : this._mnemonicPhrase = mnemonicPhrase;
  @override
  Widget buildActive(
    BuildContext context, {
    required DialogCallback<void> onComplete,
  }) =>
      _RestoreByMnemonicPhraseActiveWidget(this._mnemonicPhrase, onComplete);

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
            "Restore by mnemonic phrase",
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

class _RestoreByMnemonicPhraseActiveWidget extends StatefulWidget {
  final DialogCallback<void> onComplete;

  final String _mnemonicPhrase;

  _RestoreByMnemonicPhraseActiveWidget(
    String mnemonicPhrase,
    this.onComplete, {
    Key? key,
  })  : this._mnemonicPhrase = mnemonicPhrase,
        super(key: key);

  @override
  _RestoreByMnemonicPhraseActiveWidgetState createState() =>
      _RestoreByMnemonicPhraseActiveWidgetState();
}

class _RestoreByMnemonicPhraseActiveWidgetState
    extends State<_RestoreByMnemonicPhraseActiveWidget> {
  final TextEditingController _actionTextEditingController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return _RestoreByMnemonicPhraseWidget._buildContainer(
        Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                  "Please enter your mnemonic phrase below. This will either be 12 or 24 words in length (separated by spaces)"),
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
            if (this.widget._mnemonicPhrase ==
                this._actionTextEditingController.text) {
              widget.onComplete(null);
            }
          },
          tooltip: "Continue",
          child: Icon(Icons.login),
        ));
  }
}
