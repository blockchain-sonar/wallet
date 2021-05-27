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

import 'package:flutter/material.dart';
import "package:flutter/widgets.dart"
    show
        BuildContext,
        Column,
        FontWeight,
        SizedBox,
        StatelessWidget,
        Text,
        TextStyle,
        Widget;
import 'package:flutter_markdown/flutter_markdown.dart';

import "../../services/blockchain/smart_contract.dart"
    show SmartContract, SmartContractBlob;

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
    return Scaffold(
        body: Column(
      children: <Widget>[
        SizedBox(
          height: 20,
        ),
        Text(
          this.smartContractBlob.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blue,
            fontSize: 24,
          ),
        ),
        Expanded(
          flex: 1,
          child: Markdown(
            data: this.smartContractBlob.abi.descriptionLongMarkdown,
          ),
        ),
        Expanded(
          flex: 4,
          child: Markdown(
            data: this.smartContractBlob.descriptionLongMarkdown,
          ),
        ),
        Container(
          child: this.opts == null
              ? null
              : ElevatedButton(
                  onPressed: () {
                    this.opts?.onComplete();
                  },
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Text(this.opts?.completeButtonText ?? "Ok"),
                  ),
                ),
        ),
        SizedBox(
          height: 20,
        ),
      ],
    ));
  }
}
