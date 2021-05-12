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
        BorderRadius,
        Card,
        CircularProgressIndicator,
        FloatingActionButton,
        GridTile,
        Icons,
        RoundedRectangleBorder,
        Scaffold;

import "package:flutter/widgets.dart"
    show
        BuildContext,
        Center,
        Column,
        EdgeInsets,
        Expanded,
        FontWeight,
        GridView,
        Icon,
        Key,
        MainAxisAlignment,
        MediaQuery,
        Padding,
        SliverGridDelegateWithFixedCrossAxisCount,
        State,
        StatefulWidget,
        StatelessWidget,
        Text,
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

class ShowMnemonicContext {
  final List<String> mnemonicPhraseWords;

  ShowMnemonicContext(this.mnemonicPhraseWords);
}

class ShowMnemonicWidget extends StatelessWidget {
  final ShowMnemonicContext _dataContextInit;
  final DialogHostCallback<ShowMnemonicContext> _onComplete;

  ShowMnemonicWidget({
    required DialogHostCallback<ShowMnemonicContext> onComplete,
    required ShowMnemonicContext dataContextInit,
  })  : this._onComplete = onComplete,
        this._dataContextInit = dataContextInit;

  @override
  Widget build(BuildContext context) {
    return DialogWidget<ShowMnemonicContext>(
      onComplete: this._onComplete,
      dataContextInit: this._dataContextInit,
      child: _ShowMnemonicWidget(),
    );
  }
}

class _ShowMnemonicWidget
    extends DialogActionContentWidget<ShowMnemonicContext> {
  @override
  Widget buildActive(
    BuildContext context, {
    required DialogCallback<ShowMnemonicContext> onComplete,
  }) =>
      _ShowMnemonicActiveWidget(onComplete);

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
            "Create",
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

class _ShowMnemonicActiveWidget extends StatefulWidget {
  final DialogCallback<ShowMnemonicContext> onComplete;
  _ShowMnemonicActiveWidget(
    this.onComplete, {
    Key? key,
  }) : super(key: key);

  @override
  _ShowMnemonicActiveWidgetState createState() =>
      _ShowMnemonicActiveWidgetState();
}

class _ShowMnemonicActiveWidgetState extends State<_ShowMnemonicActiveWidget> {
  @override
  Widget build(BuildContext context) {
    final ShowMnemonicContext? dataContextInit =
        DialogWidget.of<ShowMnemonicContext>(this.context).dataContextInit;

    if (dataContextInit == null) {
      throw StateError("Bad usage. To use this please pass correct context.");
    }

    return _ShowMnemonicWidget._buildContainer(
        Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                  "Please copy down the mnemonic for your new account below. You will have to confirm the mnemonic on the next screen"),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: GridView.builder(
                  itemBuilder: (BuildContext context, int index) {
                    final String word =
                        dataContextInit.mnemonicPhraseWords[index];
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: GridTile(
                        child: Center(child: Text(word)),
                      ),
                    );
                  },
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: MediaQuery.of(context).size.width /
                          (MediaQuery.of(context).size.height / 4)),
                  itemCount: dataContextInit.mnemonicPhraseWords.length,
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
