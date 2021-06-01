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
import "package:url_launcher/url_launcher.dart" show launch;
import "../../misc/ton_decimal.dart" show TonDecimal;
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
  Future<TonDecimal> calculateDeploymentFee();
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
  final TonDecimal deploymentFeeAmount;
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

    this.widget.api.calculateDeploymentFee().then((TonDecimal deploymentFee) {
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

  @override
  Widget build(BuildContext context) {
    final _StateData? stateData = this._stateData;
    final SmartContractBlob smartContractBlob = SmartContractKeeper.instance
        .getByFullQualifiedName(
            this.widget.account.smartContractFullQualifiedName);

    return MyScaffold(
      appBarTitle: "Deploy Contract",
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            if (stateData == null)
              LinearProgressIndicator(
                semanticsLabel: "Linear progress indicator",
              ),
            InkWell(
              onTap: () => launch(
                smartContractBlob.referenceUri.toString(),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  smartContractBlob.qualifiedName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                    fontSize: 22,
                  ),
                ),
              ),
            ),
            if (stateData == null) ...<Widget>[
              Padding(
                padding: const EdgeInsets.only(
                  top: 20.0,
                ),
                child: Text("Calculating deployment fee..."),
              ),
            ],
            if (stateData != null &&
                stateData is _StateDataDeployFeeCalculated) ...<Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Deployment Fee: ~${stateData.deploymentFeeAmount.value}",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Spacer(),
                    ElevatedButton.icon(
                      onPressed: this._onDeployClick,
                      icon: Icon(
                        Icons.all_inclusive_sharp,
                      ),
                      label: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                        ),
                        child: Text("Deploy"),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (stateData != null &&
                stateData is _StateDataDeployFeeCalculationFailure) ...<Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Text("Something went wrong..."),
              ),
              Text(stateData.ex.toString()),
            ],
            if (stateData != null &&
                stateData is _StateDataDeploying) ...<Widget>[
              LinearProgressIndicator(
                semanticsLabel: "Linear progress indicator",
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Text("Deploying smart contact into blockchain..."),
              ),
            ],
            if (stateData != null &&
                stateData is _StateDataDeployed) ...<Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Text("The Smart Contact was deployed successfully!"),
              ),
            ],
            if (stateData != null &&
                stateData is _StateDataDeploymentFailure) ...<Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Text("Something went wrong..."),
              ),
              Text(stateData.ex.toString()),
            ],
            Padding(
              padding: const EdgeInsets.all(8.0),
            ),
            Expanded(child: SmartContractWidget(smartContractBlob))
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
