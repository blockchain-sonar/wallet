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

import "package:flutter/foundation.dart" show Key, listEquals;
import "package:flutter/material.dart"
    show
        Card,
        CircularProgressIndicator,
        Colors,
        Divider,
        FloatingActionButton,
        GridTile,
        GridView,
        Icons,
        InkWell,
        MediaQuery,
        RoundedRectangleBorder,
        Scaffold,
        SliverGridDelegateWithFixedCrossAxisCount;

import "package:flutter/widgets.dart"
    show
        BorderRadius,
        BuildContext,
        Center,
        Column,
        EdgeInsets,
        Expanded,
        FontWeight,
        Icon,
        Key,
        MainAxisAlignment,
        Padding,
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

class ConfirmMnemonicWidget extends StatelessWidget {
  final List<String> _mnemonicPhraseWords;
  final DialogHostCallback<void> _onComplete;

  ConfirmMnemonicWidget(
    this._mnemonicPhraseWords, {
    required DialogHostCallback<void> onComplete,
  }) : this._onComplete = onComplete;

  @override
  Widget build(BuildContext context) {
    return DialogWidget<void>(
      onComplete: this._onComplete,
      child: _ConfirmMnemonicWidget(this._mnemonicPhraseWords),
    );
  }
}

class _ConfirmMnemonicWidget extends DialogActionContentWidget<void> {
  final List<String> _mnemonicPhraseWords;

  _ConfirmMnemonicWidget(this._mnemonicPhraseWords);

  @override
  Widget buildActive(
    BuildContext context, {
    required DialogCallback<void> onComplete,
  }) =>
      _ConfirmMnemonicActiveWidget(this._mnemonicPhraseWords, onComplete);

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
  final List<String> _mnemonicPhraseWords;
  final List<String> _shuffledMnemonicsWords;

  final DialogCallback<void> onComplete;
  _ConfirmMnemonicActiveWidget(
      List<String> mnemonicPhraseWords, this.onComplete,
      {Key? key})
      : this._mnemonicPhraseWords = mnemonicPhraseWords,
        this._shuffledMnemonicsWords = <String>[...mnemonicPhraseWords]
          ..shuffle(),
        super(key: key);

  @override
  _ConfirmMnemonicActiveWidgetState createState() =>
      _ConfirmMnemonicActiveWidgetState();
}

class _ConfirmMnemonicActiveWidgetState
    extends State<_ConfirmMnemonicActiveWidget> {
  final List<int?> _confirmedWords;

  _ConfirmMnemonicActiveWidgetState() : this._confirmedWords = <int?>[];

  @override
  void initState() {
    super.initState();
    this._confirmedWords.addAll(
        List<int?>.filled(this.widget._mnemonicPhraseWords.length, null));
  }

  @override
  Widget build(BuildContext context) {
    return _ConfirmMnemonicWidget._buildContainer(
        Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child:
                  Text("Please confirm the mnemonic for your account below."),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                child: GridView.builder(
                  itemBuilder: (BuildContext context, int index) {
                    final int? shuffleMenumonicWordIndex =
                        this._confirmedWords[index];
                    final String? word = shuffleMenumonicWordIndex != null
                        ? this
                            .widget
                            ._shuffledMnemonicsWords[shuffleMenumonicWordIndex]
                        : null;
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: InkWell(
                        onTap: () => this._removeConfirmedWord(index),
                        child: GridTile(
                          child: Center(child: Text(word ?? "")),
                        ),
                      ),
                    );
                  },
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: MediaQuery.of(context).size.width /
                          (MediaQuery.of(context).size.height / 4)),
                  itemCount: this._confirmedWords.length,
                ),
              ),
            ),
            const Divider(
              height: 10,
              thickness: 1,
              indent: 20,
              endIndent: 20,
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                child: GridView.builder(
                  itemBuilder: (BuildContext context, int index) {
                    final String word =
                        this.widget._shuffledMnemonicsWords[index];
                    final bool isConfirmedWord =
                        this._confirmedWords.contains(index);
                    return Card(
                      color: isConfirmedWord ? Colors.grey[300] : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: isConfirmedWord
                          ? GridTile(
                              child: Center(child: Text(word)),
                            )
                          : InkWell(
                              onTap: () => this._addConfirmedWord(index),
                              child: GridTile(
                                child: Center(child: Text(word)),
                              ),
                            ),
                    );
                  },
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: MediaQuery.of(context).size.width /
                          (MediaQuery.of(context).size.height / 4)),
                  itemCount: this.widget._shuffledMnemonicsWords.length,
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            List<String?> confirmedWordsList = this
                ._confirmedWords
                .map((int? index) => index != null
                    ? this.widget._shuffledMnemonicsWords[index]
                    : null)
                .toList();
            if (listEquals(
              confirmedWordsList,
              this.widget._mnemonicPhraseWords,
            )) {
              widget.onComplete(null);
            }
          },
          tooltip: "Continue",
          child: Icon(Icons.login),
        ));
  }

  void _addConfirmedWord(int shuffleMnemonicWordIndex) {
    this.setState(() {
      int firstNullIndex = this._confirmedWords.indexOf(null);
      if (firstNullIndex != -1) {
        this._confirmedWords[firstNullIndex] = shuffleMnemonicWordIndex;
      }
    });
  }

  void _removeConfirmedWord(int index) {
    this.setState(() {
      this._confirmedWords
        ..remove(this._confirmedWords[index])
        ..add(null);
    });
  }
}
