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

import "package:flutter/material.dart";
import "package:flutter/widgets.dart"
    show
        BuildContext,
        Column,
        Container,
        EdgeInsets,
        Form,
        FormState,
        GlobalKey,
        Padding,
        State,
        StatefulWidget,
        Text,
        TextEditingController,
        Widget;
import 'package:freemework/freemework.dart';

import "../layout/my_scaffold.dart" show MyScaffold;

abstract class SendMoneyWidgetApi {
  Future<void> sendMoney(
      String destinationAmount, String amount, String comment);
}

class SendMoneyWidget extends StatefulWidget {
  final SendMoneyWidgetApi api;

  SendMoneyWidget(this.api);

  @override
  _SendMoneyWidgetState createState() => _SendMoneyWidgetState();
}

class _StateData {}

class _StateDataAskUser extends _StateData {}

class _StateDataDoubleCheck extends _StateData {}

class _StateDataSending extends _StateData {}

class _StateDataSent extends _StateData {}

class _StateDataSendFailure extends _StateData {
  final FreemeworkException ex;
  _StateDataSendFailure(this.ex);
}

class _SendMoneyWidgetState extends State<SendMoneyWidget> {
  final TextEditingController _destinationAddressController =
      TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  _StateData _stateData;

  _SendMoneyWidgetState() : this._stateData = _StateDataAskUser();

  @override
  void initState() {
    super.initState();

    this._destinationAddressController.text =
        "0:8776013e6d2d9f93cfc4b9cd93e54002c6129051fd15bdbdb59c150ebf9168e2";
    this._amountController.text = "0.1";
    this._commentController.text = "test";
  }

  @override
  Widget build(BuildContext context) {
    final _StateData stateData = this._stateData;

    return MyScaffold(
      appBarTitle: "Send Money",
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (this._stateData is _StateDataSending) ...<Widget>[
              LinearProgressIndicator(
                semanticsLabel: "Linear progress indicator",
              ),
            ],
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                key: this._formKey,
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: TextFormField(
                        enabled: this._stateData is _StateDataAskUser,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: "Destination Address",
                        ),
                        validator: (String? value) {
                          final String destinationAddress =
                              this._destinationAddressController.text;

                          final String pattern = r"^0:[0-9a-f]{64}$";
                          final RegExp regExp = RegExp(pattern);
                          if (regExp.hasMatch(destinationAddress)) {
                            return null;
                          }
                          return "Malformed destination address.";
                        },
                        controller: _destinationAddressController,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: TextFormField(
                        enabled: this._stateData is _StateDataAskUser,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: "Transfer Amount",
                        ),
                        validator: (String? value) {
                          final String amountStr = this._amountController.text;

                          final String pattern =
                              r"^(0|[1-9][0-9]*)(\.[0-9]+)?$";
                          final RegExp regExp = RegExp(pattern);
                          if (regExp.hasMatch(amountStr)) {
                            return null;
                          }

                          return "Wrong amount value.";
                        },
                        controller: _amountController,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: TextFormField(
                        enabled: this._stateData is _StateDataAskUser,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: "Comment",
                        ),
                        controller: _commentController,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (!(this._stateData is _StateDataAskUser)) ...<Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("Please double check your inputs..."),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Table(
                  columnWidths: {
                    0: FlexColumnWidth(1),
                    1: FlexColumnWidth(3),
                  },
                  children: <TableRow>[
                    TableRow(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Text(
                            "Destination Address:",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Text(this._destinationAddressController.text),
                      ],
                    ),
                    TableRow(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Text(
                            "Amount:",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Text(this._amountController.text),
                      ],
                    ),
                    TableRow(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Text(
                            "Comment:",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Text(this._commentController.text),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Note: This operation is not revertable in blockchain.",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
            if (stateData is _StateDataSendFailure) ...<Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("Something went wrong..."),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(stateData.ex.toString()),
              ),
            ],
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            if (this._stateData is _StateDataDoubleCheck)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: FloatingActionButton(
                  onPressed: _onForwardAction,
                  child: Icon(Icons.send),
                ),
              ),
            if (this._stateData is _StateDataDoubleCheck)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: FloatingActionButton(
                  backgroundColor: Colors.red,
                  onPressed: () {
                    this.setState(() {
                      this._stateData = _StateDataAskUser();
                    });
                  },
                  child: Icon(Icons.cancel),
                ),
              ),
            if (this._stateData is _StateDataAskUser)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: FloatingActionButton(
                  onPressed: _onForwardAction,
                  child: Icon(Icons.check),
                ),
              )
          ],
        ),
      ),
    );
  }

  void _onForwardAction() {
    assert(this._formKey.currentState != null);
    if (!this._formKey.currentState!.validate()) {
      return;
    }

    _StateData nextStateData;

    print(this._stateData);

    if (this._stateData is _StateDataAskUser) {
      nextStateData = _StateDataDoubleCheck();
    } else if (this._stateData is _StateDataDoubleCheck) {
      nextStateData = _StateDataSending();

      final String destinationAmount = this._destinationAddressController.text;
      final String amount = this._amountController.text;
      final String comment = this._commentController.text;
      this
          .widget
          .api
          .sendMoney(destinationAmount, amount, comment)
          .then((value) {
        this.setState(() {
          nextStateData = _StateDataSent();
        });
      }).catchError((Object? error) {
        //
        print(error);
        this.setState(() {
          this._stateData =
              _StateDataSendFailure(FreemeworkException.wrapIfNeeded(error));
        });
      });
    } else {
      assert(false);
      return;
    }

    this.setState(() {
      this._stateData = nextStateData;
    });
  }
}
