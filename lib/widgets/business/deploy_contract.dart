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
    show BuildContext, Container, State, StatefulWidget, Widget;
import "package:freemework/freemework.dart" show FreemeworkException;

import "../../services/blockchain/blockchain.dart";
import "../../services/encrypted_db_service.dart" show DataAccount;

import "../layout/my_scaffold.dart" show MyScaffold;
import "../reusable/smart_contact.dart" show SmartContractWidget;

abstract class DeployContractWidgetApi
    implements _AccountLoader, _BlockchainApi {}

abstract class _AccountLoader {
  Future<DataAccount> get account;
}

abstract class _BlockchainApi implements _DeployerApi {
  Future<String> calculateDeploymentFee();
}

abstract class _DeployerApi {
  Future<void> deploy();
}

class DeployContractWidget extends StatelessWidget {
  final DeployContractWidgetApi api;

  DeployContractWidget(this.api);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DataAccount>(
      initialData: null,
      future: this.api.account,
      builder: this._buildSnapshotRouter,
    );
  }

  Widget _buildSnapshotRouter(
    final BuildContext context,
    final AsyncSnapshot<DataAccount> snapshot,
  ) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return _buildLoadingProgress(context);
    } else if (snapshot.hasError) {
      return _buildFailure(context, snapshot.error);
    }
    assert(snapshot.data != null);
    final DataAccount account = snapshot.data!;

    return _DeployContractWidget(this.api, account);
  }

  Widget _buildLoadingProgress(
    final BuildContext context,
  ) {
    return MyScaffold(
      appBarTitle: "Deploy Contract",
      body: Column(
        children: <Widget>[
          LinearProgressIndicator(
            semanticsLabel: "Linear progress indicator",
          ),
          Text("Checking account..."),
        ],
      ),
    );
  }

  Widget _buildFailure(final BuildContext context, final Object? error) {
    print(error);
    return MyScaffold(
      body: Text("Cannot load account information..."),
    );
  }
}

class _DeployContractWidget extends StatefulWidget {
  final _BlockchainApi api;
  final DataAccount account;

  _DeployContractWidget(this.api, this.account);

  @override
  _DeployContractState createState() => _DeployContractState();
}

class _StateData {}

class _StateDataDeployFeeCalculated extends _StateData {
  final String deploymentFeeAmount;
  _StateDataDeployFeeCalculated(this.deploymentFeeAmount);
}

class _StateDataDeployFeeCalculationFailure extends _StateData {
  final FreemeworkException ex;
  _StateDataDeployFeeCalculationFailure(this.ex);
}

class _StateDataDeploying extends _StateData {}

class _StateDataDeployed extends _StateData {}

class _StateDataDeploymentFailure extends _StateData {
  final FreemeworkException ex;
  _StateDataDeploymentFailure(this.ex);
}

class _DeployContractState extends State<_DeployContractWidget> {
  _StateData? _stateData;
  String? test;

  _DeployContractState() : this._stateData = null;

  @override
  void initState() {
    super.initState();

    this.widget.api.calculateDeploymentFee().then((String deploymentFee) {
      this.setState(() {
        this._stateData = _StateDataDeployFeeCalculated(deploymentFee);
      });
    }).catchError((Object? error) {
      //
      print(error);
      this.setState(() {
        this._stateData = _StateDataDeployFeeCalculationFailure(
            FreemeworkException.wrapIfNeeded(error));
      });
    });
  }

  void testt(String data) {
    this.setState(() {
      this.test = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    final _StateData? stateData = this._stateData;
    final SmartContractBlob smartContractBlob = SmartContractKeeper.instance
        .getByFullQualifiedName(
            this.widget.account.smartContractFullQualifiedName);

    return MyScaffold(
      appBarTitle: "Deploy Contract",
      body: Container(
        color: Colors.amber,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(this.test ?? ""),
            SafeMultisigSmartContractDeploy((String text) {
              testt(text);
            }),
            if (stateData == null) ...<Widget>[
              LinearProgressIndicator(
                semanticsLabel: "Linear progress indicator",
              ),
              Text("Calculating deployment fee..."),
            ],
            if (stateData != null &&
                stateData is _StateDataDeployFeeCalculated) ...<Widget>[
              Row(
                children: <Widget>[
                  Text("Deployment Fee:"),
                  Text(stateData.deploymentFeeAmount),
                ],
              ),
              ElevatedButton.icon(
                onPressed: this._onDeployClick,
                icon: Icon(Icons.all_inclusive_sharp),
                label: Text("Deploy"),
              ),
            ],
            if (stateData != null &&
                stateData is _StateDataDeployFeeCalculationFailure) ...<Widget>[
              Text("Something went wrong..."),
              Text(stateData.ex.toString()),
            ],
            if (stateData != null &&
                stateData is _StateDataDeploying) ...<Widget>[
              LinearProgressIndicator(
                semanticsLabel: "Linear progress indicator",
              ),
              Text("Deploying smart contact into blockchain..."),
            ],
            if (stateData != null &&
                stateData is _StateDataDeployed) ...<Widget>[
              Text("The Smart Contact was deployed successfully!"),
            ],
            if (stateData != null &&
                stateData is _StateDataDeploymentFailure) ...<Widget>[
              Text("Something went wrong..."),
              Text(stateData.ex.toString()),
            ],
            Padding(
              padding: const EdgeInsets.all(8.0),
            ),
            Text("Contract Information"),
            Center(child: SmartContractWidget(smartContractBlob))
          ],
        ),
      ),
    );
  }

  void _onDeployClick() async {
    this.setState(() {
      this._stateData = _StateDataDeploying();
    });

    try {
      await this.widget.api.deploy();

      this.setState(() {
        this._stateData = _StateDataDeployed();
      });
    } catch (e) {
      this.setState(() {
        this._stateData =
            _StateDataDeploymentFailure(FreemeworkException.wrapIfNeeded(e));
      });
    }
  }
}

class SafeMultisigSmartContractDeploy extends StatelessWidget {
  final Function onChange;
  SafeMultisigSmartContractDeploy(this.onChange);
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        TextField(
          decoration: InputDecoration(
            border: OutlineInputBorder(),
          ),
          onChanged: (String text) => this.onChange(text),
        )
      ],
    );
  }
}

class SmartContractDeployData {}

class SafeMultisigSmartContractDeployData {
  final List<String> owners;
  final int reqConfirms;

  SafeMultisigSmartContractDeployData(this.owners, this.reqConfirms);
}
