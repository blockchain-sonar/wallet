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
    show BuildContext, StatelessWidget, Text, Widget;

import "../../services/blockchain/smart_contract.dart" show SmartContract;

typedef _CompleteCallback = Future<void> Function(
    SmartContract? selectedContract);

class SelectSmartContractWidget extends StatelessWidget {
  final List<SmartContract> smartContracts;
  final _CompleteCallback onComplete;

  SelectSmartContractWidget(
    this.smartContracts, {
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Text(this.smartContracts.map((e) => e.name).join(", "));
  }
}
