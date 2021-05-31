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
        FontWeight,
        StatelessWidget,
        Text,
        TextStyle,
        Widget;
import "../reusable/smart_contact.dart" show SmartContractWidget;
import "../layout/my_scaffold.dart" show MyScaffold;
import "../../services/blockchain/smart_contract/smart_contract.dart"
    show SmartContractBlob;

typedef _CompleteCallback = Future<void> Function();

class ReviewSmartContractOpts {
  final String completeButtonText;
  final _CompleteCallback onComplete;

  const ReviewSmartContractOpts(
    this.completeButtonText, {
    required this.onComplete,
  });
}

class ReviewSmartContractWidget extends StatelessWidget {
  final SmartContractBlob smartContractBlob;
  final ReviewSmartContractOpts? opts;

  ReviewSmartContractWidget(
    this.smartContractBlob, {
    this.opts = null,
  });

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      appBarTitle: "Contract Info",
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 15),
            child: Text(
              smartContractBlob.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
                fontSize: 22,
              ),
            ),
          ),
          Expanded(
            child: SmartContractWidget(this.smartContractBlob),
          )
        ],
      ),
    );
  }
}
