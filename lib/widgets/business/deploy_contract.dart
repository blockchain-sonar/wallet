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
    show BuildContext, Container, State, StatefulWidget, Widget;
import 'package:freeton_wallet/services/blockchain/blockchain.dart';
import 'package:freeton_wallet/widgets/reusable/smart_contact.dart';

import "../../services//encrypted_db_service.dart" show Account;

abstract class DeployContractApi {
  Future<void> calculateDeploymentFee();
}

class DeployContractWidget extends StatefulWidget {
  final DeployContractApi api;
  final Account account;

  DeployContractWidget(this.api, this.account);

  @override
  _DeployContractState createState() => _DeployContractState();
}

class _DeployContractState extends State<DeployContractWidget> {
  String? _deploymentFeeAmount = null;

  @override
  void initState() {
    super.initState();

    this.widget.api.calculateDeploymentFee().then((_) {
      setState(() {
        this._deploymentFeeAmount = "0.0";
      });
      //
    }).catchError(() {
      //
    });
  }

  @override
  Widget build(BuildContext context) {
    final String? deploymentFeeAmount = this._deploymentFeeAmount;
    final SmartContractBlob smartContractBlob = SmartContractKeeper.instance
        .getByFullQualifiedName(
            this.widget.account.smartContractFullQualifiedName);

    return Container(
      child: Column(
        children: [
          Text("Deployment Fee"),
          if (deploymentFeeAmount != null) Text(deploymentFeeAmount),
          if (deploymentFeeAmount != null)
            ElevatedButton.icon(
              onPressed: this._onDeployClick,
              icon: Icon(Icons.all_inclusive_sharp),
              label: Text("Deploy Contract"),
            ),
          if (deploymentFeeAmount == null)
            LinearProgressIndicator(
              semanticsLabel: "Linear progress indicator",
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
          ),
          SmartContractWidget(smartContractBlob)
        ],
      ),
    );
  }

  void _onDeployClick() {}
}
