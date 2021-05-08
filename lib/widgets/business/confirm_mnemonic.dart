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
        ListView,
        MainAxisAlignment,
        NeverScrollableScrollPhysics,
        Padding,
        Radius,
        ScrollPhysics,
        SingleChildScrollView,
        State,
        StatefulWidget,
        StatelessWidget,
        Text,
        TextEditingController,
        TextStyle,
        Widget;

import "package:freemework_cancellation/freemework_cancellation.dart"
    show CancellationTokenSource;

import '../reusable/button_widget.dart' show FWCancelFloatingActionButton;
import '../toolchain/dialog_widget.dart'
    show
        DialogActionContentWidget,
        DialogCallback,
        DialogHostCallback,
        DialogWidget;

class ConfirmMnemonicContext {
  final List<String> mnemonicPhraseWords;

  ConfirmMnemonicContext(this.mnemonicPhraseWords);
}

class ConfirmMnemonicWidget extends StatelessWidget {
  final ConfirmMnemonicContext _dataContextInit;
  final DialogHostCallback<ConfirmMnemonicContext> _onComplete;

  ConfirmMnemonicWidget({
    required DialogHostCallback<ConfirmMnemonicContext> onComplete,
    required ConfirmMnemonicContext dataContextInit,
  })  : this._onComplete = onComplete,
        this._dataContextInit = dataContextInit;

  @override
  Widget build(BuildContext context) {
    return DialogWidget<ConfirmMnemonicContext>(
      onComplete: this._onComplete,
      dataContextInit: this._dataContextInit,
      child: _ConfirmMnemonicWidget(),
    );
  }
}

class _ConfirmMnemonicWidget
    extends DialogActionContentWidget<ConfirmMnemonicContext> {
  @override
  Widget buildActive(
    BuildContext context, {
    required DialogCallback<ConfirmMnemonicContext> onComplete,
  }) =>
      _ConfirmMnemonicActiveWidget(onComplete);

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
            "Confirm",
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

class _ConfirmMnemonicActiveWidget extends StatefulWidget {
  final DialogCallback<ConfirmMnemonicContext> onComplete;
  _ConfirmMnemonicActiveWidget(
    this.onComplete, {
    Key? key,
  }) : super(key: key);

  @override
  _ConfirmMnemonicActiveWidgetState createState() =>
      _ConfirmMnemonicActiveWidgetState();
}

class _ConfirmMnemonicActiveWidgetState extends State<_ConfirmMnemonicActiveWidget> {
  @override
  Widget build(BuildContext context) {
    final ConfirmMnemonicContext? dataContextInit =
        DialogWidget.of<ConfirmMnemonicContext>(this.context).dataContextInit;

    if (dataContextInit == null) {
      throw StateError("Bad usage. To use this please pass correct context.");
    }

    return _ConfirmMnemonicWidget._buildContainer(
        Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                  "Please copy down the mnemonic for your new account below. You will have to confirm the mnemonic on the next screen"),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Container(
                  height: 235,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.all(
                      const Radius.circular(5.0),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    child: ListView.builder(
                      itemBuilder: (BuildContext context, int index) {
                        final String word =
                            dataContextInit.mnemonicPhraseWords[index];
                        return Text(word);
                      },
                      itemCount: dataContextInit.mnemonicPhraseWords.length,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            widget.onComplete(
              dataContextInit,
            );
          },
          tooltip: "Continue",
          child: Icon(Icons.login),
        ));
  }
}
