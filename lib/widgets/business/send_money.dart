//
// Copyright 2021 Free TON Wallet Team
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// 	http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import "package:flutter/material.dart";
import "package:flutter/services.dart" show Clipboard, ClipboardData;
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
import "package:freemework/freemework.dart"
    show ExecutionContext, FreemeworkException;
import "package:url_launcher/url_launcher.dart" show launch;

import "../../misc/ton_decimal.dart" show TonDecimal;
import "../layout/my_scaffold.dart" show MyScaffold;

///
/// API usage flow:
/// 1. Call [createTransaction] to create transaction message. . Obtain `transactionToken` as result.
/// 2. Call [submitTransaction] to push transation into TON Node. Obtain `submitToken` as result.
/// 3. (Optionally) Call [waitForAcceptTransaction] to wait blockchain transaction. Obtain `transactionId` as result.
///
abstract class SendMoneyWidgetApi {
  /// Create(Prepare) Transation message and returns `transactionToken` that may used for [submitTransaction] method.
  Future<String> createTransaction(
    ExecutionContext ectx,
    String destinationAddress,
    TonDecimal amount,
    String comment,
  );

  /// Submit transaction to the TON Node and returns `submitToken` that may used for [waitForAcceptTransaction]
  Future<String> submitTransaction(
    ExecutionContext ectx,
    String transactionToken,
  );

  /// Wait while transation puts into blockchain and returns `transactionId`
  Future<String> waitForAcceptTransaction(
    ExecutionContext ectx,
    String transactionToken,
    String submitToken,
  );
}

class SendMoneyWidget extends StatefulWidget {
  final SendMoneyWidgetApi api;

  SendMoneyWidget(this.api);

  @override
  _SendMoneyWidgetState createState() => _SendMoneyWidgetState();
}

class _StateData {}

class _StateDataAskUser extends _StateData {}

class _StateDataDoubleCheck extends _StateData
    with _StateDataMixinUserDataEntered {
  @override
  final String destinationAddress;

  @override
  final TonDecimal amount;

  @override
  final String comment;

  _StateDataDoubleCheck(this.destinationAddress, this.amount, this.comment);
}

class _StateDataProcessingObtainTransactionToken extends _StateData
    with _StateDataMixinTransactionOngoing, _StateDataMixinUserDataEntered {
  @override
  final String destinationAddress;

  @override
  final TonDecimal amount;

  @override
  final String comment;

  _StateDataProcessingObtainTransactionToken(
      this.destinationAddress, this.amount, this.comment);
}

class _StateDataProcessingObtainTransactionTokenProgress
    extends _StateDataProcessingObtainTransactionToken
    with _StateDataMixinProgressBar {
  _StateDataProcessingObtainTransactionTokenProgress(
    final String destinationAddress,
    final TonDecimal amount,
    final String comment,
  ) : super(
          destinationAddress,
          amount,
          comment,
        );
}

class _StateDataProcessingObtainTransactionTokenFailure
    extends _StateDataProcessingObtainTransactionToken {
  final FreemeworkException ex;
  _StateDataProcessingObtainTransactionTokenFailure(
    final String destinationAddress,
    final TonDecimal amount,
    final String comment,
    this.ex,
  ) : super(
          destinationAddress,
          amount,
          comment,
        );
}

class _StateDataProcessingObtainSubmitToken extends _StateData
    with
        _StateDataMixinTransactionOngoing,
        _StateDataMixinTransactionCreated,
        _StateDataMixinUserDataEntered {
  @override
  final String destinationAddress;

  @override
  final TonDecimal amount;

  @override
  final String comment;

  @override
  final String transactionToken;

  _StateDataProcessingObtainSubmitToken(
    this.destinationAddress,
    this.amount,
    this.comment,
    this.transactionToken,
  );
}

class _StateDataProcessingObtainSubmitTokenProcess
    extends _StateDataProcessingObtainSubmitToken
    with _StateDataMixinProgressBar {
  _StateDataProcessingObtainSubmitTokenProcess(
    final String destinationAddress,
    final TonDecimal amount,
    final String comment,
    String transactionToken,
  ) : super(destinationAddress, amount, comment, transactionToken);
}

class _StateDataProcessingObtainSubmitTokenFailure
    extends _StateDataProcessingObtainSubmitToken {
  final FreemeworkException ex;

  _StateDataProcessingObtainSubmitTokenFailure(
    final String destinationAddress,
    final TonDecimal amount,
    final String comment,
    final String transactionToken,
    this.ex,
  ) : super(destinationAddress, amount, comment, transactionToken);
}

class _StateDataProcessingWaitTransactionOnBlockchain extends _StateData
    with
        _StateDataMixinTransactionOngoing,
        _StateDataMixinTransactionCreated,
        _StateDataMixinTransactionSent,
        _StateDataMixinUserDataEntered {
  @override
  final String destinationAddress;

  @override
  final TonDecimal amount;

  @override
  final String comment;

  @override
  final String transactionToken;
  @override
  final String submitToken;

  _StateDataProcessingWaitTransactionOnBlockchain(
    this.destinationAddress,
    this.amount,
    this.comment,
    this.transactionToken,
    this.submitToken,
  );
}

class _StateDataProcessingWaitTransactionOnBlockchainProcess
    extends _StateDataProcessingWaitTransactionOnBlockchain
    with _StateDataMixinProgressBar {
  _StateDataProcessingWaitTransactionOnBlockchainProcess(
    final String destinationAddress,
    final TonDecimal amount,
    final String comment,
    final String transactionToken,
    final String submitToken,
  ) : super(
          destinationAddress,
          amount,
          comment,
          transactionToken,
          submitToken,
        );
}

class _StateDataProcessingWaitTransactionOnBlockchainFailure
    extends _StateDataProcessingWaitTransactionOnBlockchain {
  final FreemeworkException ex;

  _StateDataProcessingWaitTransactionOnBlockchainFailure(
    final String destinationAddress,
    final TonDecimal amount,
    final String comment,
    final String transactionToken,
    final String submitToken,
    this.ex,
  ) : super(
          destinationAddress,
          amount,
          comment,
          transactionToken,
          submitToken,
        );
}

class _StateDataCompleted extends _StateData
    with
        _StateDataMixinTransactionOngoing,
        _StateDataMixinTransactionCreated,
        _StateDataMixinTransactionSent,
        _StateDataMixinTransactionInBlockchain {
  @override
  final String transactionToken;
  @override
  final String submitToken;
  @override
  final String transactionId;

  _StateDataCompleted(
      this.transactionToken, this.submitToken, this.transactionId);
}

// class _StateDataSendFailure extends _StateData {
//   final FreemeworkException ex;
//   _StateDataSendFailure(this.ex);
// }

mixin _StateDataMixinProgressBar on _StateData {}
mixin _StateDataMixinUserDataEntered on _StateData {
  String get destinationAddress;
  TonDecimal get amount;
  String get comment;
}
mixin _StateDataMixinTransactionOngoing on _StateData {}
mixin _StateDataMixinTransactionCreated on _StateDataMixinTransactionOngoing {
  String get transactionToken;
}
mixin _StateDataMixinTransactionSent on _StateDataMixinTransactionCreated {
  String get submitToken;
}
mixin _StateDataMixinTransactionInBlockchain on _StateDataMixinTransactionSent {
  String get transactionId;
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
  Widget build(BuildContext context) {
    final _StateData stateData = this._stateData;

    return MyScaffold(
      appBarTitle: "Send Money",
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (stateData is _StateDataMixinProgressBar) ...<Widget>[
              LinearProgressIndicator(
                semanticsLabel: "Linear progress indicator",
              ),
            ],
            if (stateData is _StateDataAskUser)
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
                            final String amountStr =
                                this._amountController.text;

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
                      // Padding(
                      //   padding: const EdgeInsets.symmetric(vertical: 8.0),
                      //   child: TextFormField(
                      //     enabled: this._stateData is _StateDataAskUser,
                      //     decoration: InputDecoration(
                      //       border: OutlineInputBorder(),
                      //       hintText: "Comment",
                      //     ),
                      //     controller: _commentController,
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),
            if (stateData is _StateDataMixinUserDataEntered) ...<Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("Please double check your inputs..."),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Table(
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  columnWidths: <int, TableColumnWidth>{
                    0: FlexColumnWidth(1),
                    1: FlexColumnWidth(3),
                  },
                  children: <TableRow>[
                    TableRow(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "Destination Address:",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Text(stateData.destinationAddress),
                      ],
                    ),
                    TableRow(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "Amount:",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Text(stateData.amount.value),
                      ],
                    ),
                    // TableRow(
                    //   children: <Widget>[
                    //     Padding(
                    //       padding: const EdgeInsets.only(right: 8.0),
                    //       child: Text(
                    //         "Comment:",
                    //         style: TextStyle(fontWeight: FontWeight.bold),
                    //       ),
                    //     ),
                    //     Text(stateData.comment),
                    //   ],
                    // ),
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
            if (stateData is _StateDataMixinTransactionOngoing) ...<Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: <Widget>[
                    stateData is _StateDataMixinTransactionCreated ||
                            stateData
                                is _StateDataProcessingObtainTransactionTokenFailure
                        ? Icon(
                            Icons.check_circle_outlined,
                            color: stateData
                                    is _StateDataProcessingObtainTransactionTokenFailure
                                ? Colors.red
                                : Colors.green,
                          )
                        : Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: SizedBox(
                              child: CircularProgressIndicator(),
                              height: 12.0,
                              width: 12.0,
                            ),
                          ),
                    Text("Transaction message created")
                  ],
                ),
              )
            ],
            if (stateData is _StateDataMixinTransactionOngoing) ...<Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: <Widget>[
                    stateData is _StateDataMixinTransactionSent ||
                            stateData
                                is _StateDataProcessingObtainSubmitTokenFailure
                        ? Icon(
                            Icons.check_circle_outlined,
                            color: stateData
                                    is _StateDataProcessingObtainSubmitTokenFailure
                                ? Colors.red
                                : Colors.green,
                          )
                        : Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: SizedBox(
                              child: CircularProgressIndicator(),
                              height: 12.0,
                              width: 12.0,
                            ),
                          ),
                    Text("Transaction has been sent to the TON Node")
                  ],
                ),
              )
            ],
            if (stateData is _StateDataMixinTransactionOngoing) ...<Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: <Widget>[
                    stateData is _StateDataMixinTransactionInBlockchain ||
                            stateData
                                is _StateDataProcessingWaitTransactionOnBlockchainFailure
                        ? Icon(
                            Icons.check_circle_outlined,
                            color: stateData
                                    is _StateDataProcessingWaitTransactionOnBlockchainFailure
                                ? Colors.red
                                : Colors.green,
                          )
                        : Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: SizedBox(
                              child: CircularProgressIndicator(),
                              height: 12.0,
                              width: 12.0,
                            ),
                          ),
                    Text("Transaction seen in blockchain")
                  ],
                ),
              ),
              if (stateData is _StateDataMixinTransactionInBlockchain)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: InkWell(
                      child: Text(
                        stateData.transactionId,
                        style: TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      onTap: () {
                        final Uri baseUrl = Uri.parse(
                          "https://net.ton.live/transactions/transactionDetails",
                        );

                        final Uri accountDetailsUrl = baseUrl.replace(
                            queryParameters: <String, String>{
                              "id": stateData.transactionId
                            });

                        launch(
                            accountDetailsUrl.toString()); // TODO missing await
                      },
                    ),
                  ),
                ),
              if (stateData is _StateDataMixinTransactionInBlockchain)
                Center(
                  child: InkWell(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 2.0),
                      child: Icon(Icons.content_copy),
                    ),
                    onTap: () {
                      Clipboard.setData(
                        ClipboardData(text: stateData.transactionId),
                      ); // TODO missing await
                    },
                  ),
                ),
            ],
            if (stateData
                is _StateDataProcessingObtainTransactionTokenFailure) ...<Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                    "Cannot create transaction message. You may repeat last operation by click Send button again..."),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(stateData.ex.toString()),
              ),
            ],
            if (stateData
                is _StateDataProcessingObtainSubmitTokenFailure) ...<Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                    "Cannot send transaction message to a TON Node. You may repeat last operation by click Send button again..."),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(stateData.ex.toString()),
              ),
            ],
            if (stateData
                is _StateDataProcessingWaitTransactionOnBlockchainFailure) ...<Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                    "Cannot obtain blockchain transaction. You may repeat last operation by click Send button again..."),
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
            if (stateData is _StateDataDoubleCheck)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: FloatingActionButton(
                  onPressed: this._onStartTransactionFlow,
                  child: Icon(Icons.send),
                ),
              ),
            if (stateData
                    is _StateDataProcessingObtainTransactionTokenFailure ||
                stateData is _StateDataProcessingObtainSubmitTokenFailure ||
                stateData
                    is _StateDataProcessingWaitTransactionOnBlockchainFailure)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: FloatingActionButton(
                  onPressed: this._onStartTransactionFlow,
                  child: Icon(Icons.send),
                ),
              ),
            if (stateData is _StateDataDoubleCheck ||
                stateData
                    is _StateDataProcessingObtainTransactionTokenFailure ||
                stateData is _StateDataProcessingObtainSubmitTokenFailure ||
                stateData
                    is _StateDataProcessingWaitTransactionOnBlockchainFailure)
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
            if (stateData is _StateDataAskUser)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: FloatingActionButton(
                  onPressed: _onDoubleCheckInput,
                  child: Icon(Icons.check),
                ),
              )
          ],
        ),
      ),
    );
  }

  void _onDoubleCheckInput() {
    assert(this._formKey.currentState != null);
    if (!this._formKey.currentState!.validate()) {
      return;
    }

    final _StateData stateData = this._stateData;

    if (stateData is _StateDataAskUser) {
      final String destinationAddress = this._destinationAddressController.text;
      final TonDecimal amount = TonDecimal.parse(this._amountController.text);
      final String comment = this._commentController.text;

      this.setState(() {
        this._stateData =
            _StateDataDoubleCheck(destinationAddress, amount, comment);
      });
      return;
    } else {
      assert(false, "Bad state for _onDoubleCheckInput");
      return;
    }
  }

  void _onStartTransactionFlow() {
    final _StateData stateData = this._stateData;

    if (stateData is _StateDataDoubleCheck) {
      this.setState(() {
        this._stateData = _StateDataProcessingObtainTransactionTokenProgress(
          stateData.destinationAddress,
          stateData.amount,
          stateData.comment,
        );
      });
      this._safeTransactionFlow(); // NO await!!!
      return;
    } else if (stateData is _StateDataProcessingObtainTransactionTokenFailure) {
      this.setState(() {
        this._stateData = _StateDataProcessingObtainTransactionTokenProgress(
          stateData.destinationAddress,
          stateData.amount,
          stateData.comment,
        );
      });
      this._safeTransactionFlow(); // NO await!!!
      return;
    } else if (stateData is _StateDataProcessingObtainSubmitTokenFailure) {
      this.setState(() {
        this._stateData = _StateDataProcessingObtainSubmitTokenProcess(
          stateData.destinationAddress,
          stateData.amount,
          stateData.comment,
          stateData.transactionToken,
        );
      });
      this._safeTransactionFlow(); // NO await!!!
      return;
    } else if (stateData
        is _StateDataProcessingWaitTransactionOnBlockchainFailure) {
      this.setState(() {
        this._stateData =
            _StateDataProcessingWaitTransactionOnBlockchainProcess(
          stateData.destinationAddress,
          stateData.amount,
          stateData.comment,
          stateData.transactionToken,
          stateData.submitToken,
        );
      });
      this._safeTransactionFlow(); // NO await!!!
      return;
    } else {
      assert(false, "Bad state for _onForwardAction");
      return;
    }
  }

  Future<void> _safeTransactionFlow() async {
    final _StateData stateData = this._stateData;
    final ExecutionContext ectx = ExecutionContext.EMPTY;

    if (stateData is _StateDataProcessingObtainTransactionToken) {
      final String destinationAddress = stateData.destinationAddress;
      final TonDecimal amount = stateData.amount;
      final String comment = stateData.comment;

      try {
        final String transationToken = await this.widget.api.createTransaction(
              ectx,
              destinationAddress,
              amount,
              comment,
            );

        this.setState(() {
          this._stateData = _StateDataProcessingObtainSubmitTokenProcess(
              stateData.destinationAddress,
              stateData.amount,
              stateData.comment,
              transationToken);
        });

        return _safeTransactionFlow(); // NO await!!!
      } catch (e) {
        this.setState(() {
          this._stateData = _StateDataProcessingObtainTransactionTokenFailure(
            destinationAddress,
            amount,
            comment,
            _logTraceException(FreemeworkException.wrapIfNeeded(e)),
          );
        });
      }
    } else if (stateData is _StateDataProcessingObtainSubmitToken) {
      final String transationToken = stateData.transactionToken;

      try {
        final String submitToken = await this.widget.api.submitTransaction(
              ectx,
              transationToken,
            );

        this.setState(() {
          this._stateData =
              _StateDataProcessingWaitTransactionOnBlockchainProcess(
            stateData.destinationAddress,
            stateData.amount,
            stateData.comment,
            transationToken,
            submitToken,
          );
        });

        return _safeTransactionFlow(); // NO await!!!
      } catch (e) {
        this.setState(() {
          this._stateData = _StateDataProcessingObtainSubmitTokenFailure(
            stateData.destinationAddress,
            stateData.amount,
            stateData.comment,
            transationToken,
            _logTraceException(FreemeworkException.wrapIfNeeded(e)),
          );
        });
      }
    } else if (stateData is _StateDataProcessingWaitTransactionOnBlockchain) {
      final String transationToken = stateData.transactionToken;
      final String submitToken = stateData.submitToken;

      try {
        final String transactionId =
            await this.widget.api.waitForAcceptTransaction(
                  ectx,
                  transationToken,
                  submitToken,
                );

        this.setState(() {
          this._stateData =
              _StateDataCompleted(transationToken, submitToken, transactionId);
        });

        return;
      } catch (e) {
        this.setState(() {
          this._stateData =
              _StateDataProcessingWaitTransactionOnBlockchainFailure(
            stateData.destinationAddress,
            stateData.amount,
            stateData.comment,
            transationToken,
            submitToken,
            _logTraceException(FreemeworkException.wrapIfNeeded(e)),
          );
        });
      }
    } else {
      assert(false, "Bad state for _transactionFlow");
    }
  }

  static FreemeworkException _logTraceException(final FreemeworkException ex) {
    final String? message = ex.message;
    if (message != null) {
      print(message);
    } else {
      print(ex.runtimeType);
    }
    final FreemeworkException? innerException = ex.innerException;
    if (innerException != null) {
      _logTraceException(innerException);
    }
    return ex;
  }
}
