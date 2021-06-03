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

import "../layout/my_scaffold.dart" show MyScaffold;
import "../reusable/button_widget.dart" show FWCancelFloatingActionButton;
import "../toolchain/dialog_widget.dart"
    show
        DialogActionContentWidget,
        DialogCallback,
        DialogHostCallback,
        DialogWidget;

class RestoreByMnemonicPhraseContext {
  final List<String> mnemonicPhraseWords;
  final String? errorMessage;

  RestoreByMnemonicPhraseContext(this.mnemonicPhraseWords, this.errorMessage);
}

class RestoreByMnemonicPhraseWidget extends StatelessWidget {
  final RestoreByMnemonicPhraseContext? _dataContextInit;
  final DialogHostCallback<RestoreByMnemonicPhraseContext> _onComplete;

  RestoreByMnemonicPhraseWidget({
    required DialogHostCallback<RestoreByMnemonicPhraseContext> onComplete,
    RestoreByMnemonicPhraseContext? dataContextInit,
  })  : this._onComplete = onComplete,
        this._dataContextInit = dataContextInit;

  @override
  Widget build(BuildContext context) {
    return DialogWidget<RestoreByMnemonicPhraseContext>(
      onComplete: this._onComplete,
      dataContextInit: this._dataContextInit,
      child: _RestoreByMnemonicPhraseWidget(),
    );
  }
}

class _RestoreByMnemonicPhraseWidget
    extends DialogActionContentWidget<RestoreByMnemonicPhraseContext> {
  @override
  Widget buildActive(
    BuildContext context, {
    required DialogCallback<RestoreByMnemonicPhraseContext> onComplete,
  }) =>
      _RestoreByMnemonicPhraseActiveWidget(onComplete);

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
  final DialogCallback<RestoreByMnemonicPhraseContext> onComplete;
  _RestoreByMnemonicPhraseActiveWidget(
    this.onComplete, {
    Key? key,
  }) : super(key: key);

  @override
  _RestoreByMnemonicPhraseActiveWidgetState createState() =>
      _RestoreByMnemonicPhraseActiveWidgetState();
}

class _RestoreByMnemonicPhraseActiveWidgetState
    extends State<_RestoreByMnemonicPhraseActiveWidget> {
  final TextEditingController _actionTextEditingController =
      TextEditingController();
  String? _errorMessage;

  @override
  void initState() {
    final RestoreByMnemonicPhraseContext? dataContextInit =
        DialogWidget.of<RestoreByMnemonicPhraseContext>(this.context)
            .dataContextInit;
    if (dataContextInit != null) {
      this._actionTextEditingController.text =
          dataContextInit.mnemonicPhraseWords.join(" ");
      this._errorMessage = dataContextInit.errorMessage;
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
    final String? errorMessage = this._errorMessage;

    return _RestoreByMnemonicPhraseWidget._buildContainer(
        Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                  "Please enter your mnemonic phrase below. This will either be 12 words in length (separated by spaces)"),
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
                      hintText: "Mnemonic phrase",
                    ),
                  ),
                ),
              ),
            ),
            if (errorMessage != null)
              Text(
                errorMessage,
                style: TextStyle(color: Colors.red),
              )
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            widget.onComplete(RestoreByMnemonicPhraseContext(
              this._actionTextEditingController.text.split(" "),
              null,
            ));
          },
          tooltip: "Continue",
          child: Icon(Icons.login),
        ));
  }
}
