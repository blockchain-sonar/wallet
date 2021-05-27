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
        Border,
        BuildContext,
        Colors,
        Column,
        Container,
        Decoration,
        EdgeInsets,
        ElevatedButton,
        Expanded,
        FixedColumnWidth,
        FlexColumnWidth,
        FontWeight,
        InkWell,
        IntrinsicColumnWidth,
        Padding,
        SizedBox,
        StatelessWidget,
        Table,
        TableBorder,
        TableColumnWidth,
        TableRow,
        Text,
        TextStyle,
        Widget;
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
import "package:flutter_markdown/flutter_markdown.dart" show Markdown;
import 'package:url_launcher/url_launcher.dart';
import "../layout/my_scaffold.dart" show MyScaffold;

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

  void _launchURL(String url) async =>
      await canLaunch(url) ? await launch(url) : throw "Could not launch $url";

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
        body: Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
          child: Text(
            this.smartContractBlob.name,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue,
              fontSize: 24,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 10,
            horizontal: 15,
          ),
          child: Table(
            border: TableBorder.all(),
            columnWidths: const <int, TableColumnWidth>{
              0: IntrinsicColumnWidth(),
              1: IntrinsicColumnWidth(),
            },
            children: <TableRow>[
              TableRow(children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Namespace",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    this.smartContractBlob.name,
                  ),
                ),
              ]),
              TableRow(children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Version",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    this.smartContractBlob.version,
                  ),
                ),
              ]),
              TableRow(children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Link",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => this._launchURL(
                    this.smartContractBlob.referenceUri.toString(),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      this.smartContractBlob.referenceUri.toString(),
                    ),
                  ),
                ),
              ]),
            ],
          ),
        ),
        Expanded(
          child: Markdown(
              data: "# ABI inforation\n" +
                  this.smartContractBlob.abi.descriptionLongMarkdown +
                  "\n# TVC information\n" +
                  this.smartContractBlob.descriptionLongMarkdown),
        ),
        Container(
          child: this.opts == null
              ? null
              : Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: ElevatedButton(
                    onPressed: () {
                      this.opts?.onComplete();
                    },
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(this.opts?.completeButtonText ?? "Ok"),
                    ),
                  ),
                ),
        ),
      ],
    ));
  }
}
