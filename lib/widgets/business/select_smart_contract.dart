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
        AppBar,
        BuildContext,
        Card,
        Center,
        Colors,
        Column,
        CrossAxisAlignment,
        EdgeInsets,
        ElevatedButton,
        FontWeight,
        InkWell,
        Padding,
        SizedBox,
        StatelessWidget,
        Text,
        TextStyle,
        Widget;
import "package:flutter/widgets.dart"
    show BuildContext, Column, StatelessWidget, Text, Widget;
import 'package:freeton_wallet/widgets/layout/my_scaffold.dart';
import "package:url_launcher/url_launcher.dart" show launch;

import "../../services/blockchain/smart_contract.dart" show SmartContractBlob;

typedef _CompleteCallback = void Function(SmartContractBlob? selectedContract);

class SelectSmartContractWidget extends StatelessWidget {
  final List<SmartContractBlob> smartContracts;
  final _CompleteCallback onComplete;

  SelectSmartContractWidget(
    this.smartContracts, {
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      appBarTitle: "Smart contracts",
      body: Column(
        children: <Widget>[
          ...this.smartContracts.map(
                (SmartContractBlob smartContract) => Center(
                  child: Card(
                    child: InkWell(
                      splashColor: Colors.blue.withAlpha(30),
                      onTap: () {
                        this.onComplete(smartContract);
                      },
                      child: SizedBox(
                        width: double.infinity,
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              Center(
                                child: Text(
                                  smartContract.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                  top: 10,
                                ),
                                child: ElevatedButton(
                                  onPressed: () => launch(
                                      smartContract.referenceUri.toString()),
                                  child: Text("More..."),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
        ],
      ),

      // Markdown(data: this.smartContracts.first.descriptionMarkdown),
      // Column(children: <Widget>[

      //   ...this.smartContracts.map(
      //         (SmartContract e) => Container(
      //           child: Column(
      //             children: <Widget>[
      //               Text(e.name),
      //             ],
      //           ),
      //         ),
      //       ),
      // ]),
    );
  }
}
