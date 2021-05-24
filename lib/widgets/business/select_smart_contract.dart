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

import "package:flutter/material.dart" show AppBar, BuildContext, Card, Center, Colors, Column, CrossAxisAlignment, EdgeInsets, ElevatedButton, FontWeight, InkWell, Padding, Scaffold, SizedBox, StatelessWidget, Text, TextStyle, Widget;
import "package:flutter/widgets.dart"
    show BuildContext, Column, StatelessWidget, Text, Widget;
import "package:url_launcher/url_launcher.dart" show launch;

import "../../services/blockchain/smart_contract.dart" show SmartContract;

typedef _CompleteCallback = void Function(SmartContract? selectedContract);

class SelectSmartContractWidget extends StatelessWidget {
  final List<SmartContract> smartContracts;
  final _CompleteCallback onComplete;

  SelectSmartContractWidget(
    this.smartContracts, {
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Smart contracts"),
      ),
      body: Column(
        children: <Widget>[
          ...this.smartContracts.map(
                (SmartContract e) => Center(
                  child: Card(
                    child: InkWell(
                      splashColor: Colors.blue.withAlpha(30),
                      onTap: () {
                        print("Card tapped.");
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
                                  e.name,
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
                                  onPressed: () =>
                                      launch(e.referenceUri.toString()),
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
