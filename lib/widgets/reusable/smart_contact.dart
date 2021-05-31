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
        EdgeInsets,
        Padding,
        StatelessWidget,
        Text,
        Widget;
import "package:flutter_markdown/flutter_markdown.dart" show Markdown;
import "package:url_launcher/url_launcher.dart" show canLaunch, launch;
import "../../services/blockchain/blockchain.dart" show SmartContractBlob;

class SmartContractWidget extends StatelessWidget {
  final SmartContractBlob smartContractBlob;

  SmartContractWidget(this.smartContractBlob);

  void _launchURL(String url) async =>
      await canLaunch(url) ? await launch(url) : throw "Could not launch $url";

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 5,
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
      ],
    );
  }
}
