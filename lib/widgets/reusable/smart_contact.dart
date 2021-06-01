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

import "package:flutter/widgets.dart"
    show BuildContext, StatelessWidget, Widget;
import "package:flutter_markdown/flutter_markdown.dart" show Markdown;

import "../../services/blockchain/blockchain.dart" show SmartContractBlob;

class SmartContractWidget extends StatelessWidget {
  final SmartContractBlob smartContractBlob;

  SmartContractWidget(this.smartContractBlob);

  @override
  Widget build(BuildContext context) {
    return Markdown(
      data: "# ABI info\n" +
          this.smartContractBlob.abi.descriptionLongMarkdown +
          "\n# Blob info\n" +
          this.smartContractBlob.descriptionLongMarkdown,
    );
  }
}
