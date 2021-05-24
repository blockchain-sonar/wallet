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

import 'package:flutter/cupertino.dart';
import 'package:flutter/src/widgets/basic.dart';
import "package:flutter/widgets.dart"
    show
        Alignment,
        BuildContext,
        Container,
        EdgeInsets,
        Icon,
        Key,
        Padding,
        Row,
        SingleChildScrollView,
        SizedBox,
        State,
        StatefulWidget,
        StatelessWidget,
        Text,
        UniqueKey,
        Widget;
import "package:flutter/material.dart"
    show
        AppBar,
        BottomNavigationBar,
        Colors,
        ExpansionPanel,
        ExpansionPanelList,
        FloatingActionButton,
        Icons,
        InkWell,
        ListTile,
        Material,
        Scaffold;
import "package:freemework/freemework.dart";
import 'package:freeton_wallet/services/blockchain/blockchain.dart';

import "../../services/encrypted_db_service.dart"
    show Account, AccountType, KeypairBundle;
import "../../services/job.dart" show AccountsActivationJob, JobService;
import "../../states/app_state.dart" show AppState;

typedef MainWalletsDeployContractCallback = void Function(String keypairName);

class MainWalletsWidget extends StatefulWidget {
  final AppState _appState;
  final JobService jobService;
  final void Function() onAddNewKey;
  final MainWalletsDeployContractCallback onDeployContract;
  final BottomNavigationBar bottomNavigationBar;

  MainWalletsWidget(
    this._appState,
    this.bottomNavigationBar, {
    required this.jobService,
    required this.onAddNewKey,
    required this.onDeployContract,
    Key? key,
  }) : super(key: key);

  @override
  _MainWalletsState createState() => _MainWalletsState();
}

class _MainWalletsState extends State<MainWalletsWidget> {
  List<_KeypairBundleExpansionPanelViewModel>
      _keypairBundleExpansionPanelViewModels;

  _MainWalletsState()
      : this._keypairBundleExpansionPanelViewModels =
            <_KeypairBundleExpansionPanelViewModel>[] {
    print("_MainWalletsState()");
  }

  @override
  void initState() {
    super.initState();
    this._reloadWallets();
    this.widget._appState.addListener(this._onAppStateChanged);
  }

  @override
  void dispose() {
    this.widget._appState.removeListener(this._onAppStateChanged);
    super.dispose();
  }

  void _reloadWallets() {
    this._keypairBundleExpansionPanelViewModels = this
        .widget
        ._appState
        .keypairBundles
        .map((KeypairBundle walletData) =>
            _KeypairBundleExpansionPanelViewModel(walletData))
        .toList();
  }

  void _onAppStateChanged() {
    this.setState(() {
      this._reloadWallets();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Wallets"),
      ),
      body: Container(
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: _buildPanel(),
          ),
        ),
      ),
      bottomNavigationBar: this.widget.bottomNavigationBar,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: this.widget.onAddNewKey,
      ),
    );
  }

  Widget _buildPanel() {
    return ExpansionPanelList(
      key: UniqueKey(),
      expansionCallback: (int index, bool isExpanded) {
        setState(() {
          _keypairBundleExpansionPanelViewModels[index].isExpanded =
              !isExpanded;
        });
      },
      children: _keypairBundleExpansionPanelViewModels
          .map<ExpansionPanel>((_KeypairBundleExpansionPanelViewModel item) {
        final String keypairName = item.keypairBundle.keypairName;
        final String trimmedPublicKey =
            _trimPublicKey(item.keypairBundle.keyPublic);

        return ExpansionPanel(
          headerBuilder: (BuildContext context, bool isExpanded) {
            return ListTile(
              title: Row(
                children: <Widget>[
                  const Icon(Icons.vpn_key),
                  if (item.hasMnemonicPhrase) const Icon(Icons.subtitles),
                  SizedBox(width: 10),
                  Text("${keypairName} ${trimmedPublicKey}"),
                ],
              ),
            );
          },
          body: Column(
            children: <Widget>[
              KeypairBundleContentWidget(
                item.keypairBundle,
                jobService: this.widget.jobService,
              ),
              SizedBox.fromSize(
                size: Size(92, 92), // button width and height
                child: ClipOval(
                  child: Material(
                    color: Colors.orange, // button color
                    child: InkWell(
                      splashColor: Colors.green, // splash color
                      onTap: () {
                        this
                            .widget
                            .onDeployContract(item.keypairBundle.keypairName);
                      }, // button pressed
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(Icons.addchart_rounded), // icon
                          Text("Add Wallet"), // text
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          isExpanded: item.isExpanded,
        );
      }).toList(),
    );
  }

  static String _trimPublicKey(String publicKey) {
    if (publicKey.length > 16) {
      final String head = publicKey.substring(0, 8);
      final String tail = publicKey.substring(publicKey.length - 8);
      return "${head}...${tail}";
    }
    return publicKey;
  }
}

//
/// stores ExpansionPanel state information
///
class _KeypairBundleExpansionPanelViewModel {
  final KeypairBundle _keypairBundle;

  _KeypairBundleExpansionPanelViewModel(this._keypairBundle)
      : this.isExpanded = true;

  KeypairBundle get keypairBundle => this._keypairBundle;

  bool get hasMnemonicPhrase => true;

  bool isExpanded;
}

class KeypairBundleContentWidget extends StatefulWidget {
  final KeypairBundle data;
  final JobService jobService;

  KeypairBundleContentWidget(
    this.data, {
    required this.jobService,
  });

  @override
  _KeypairBundleContentState createState() => _KeypairBundleContentState();
}

class _KeypairBundleContentState extends State<KeypairBundleContentWidget> {
  bool _accountsActivationInProgress;
  String? _accountsActivationFailureMessage;

  _KeypairBundleContentState()
      : this._accountsActivationInProgress = false,
        this._accountsActivationFailureMessage = null;

  @override
  void initState() {
    super.initState();

    final KeypairBundle keypairBundle = this.widget.data;
    final JobService jobService = this.widget.jobService;

    final AccountsActivationJob? accountsActivationJob =
        jobService.fetchAccountsActivationJob(keypairBundle);

    if (accountsActivationJob != null) {
      this._accountsActivationInProgress = true;
      accountsActivationJob.future.then((_) {
        this.setState(() {
          this._accountsActivationInProgress = false;
        });
      }).onError((Object error, StackTrace stackTrace) {
        this.setState(() {
          this._accountsActivationInProgress = false;
          this._accountsActivationFailureMessage =
              error is FreemeworkException ? error.message : "$error";
        });
      });
    } else {
      this._accountsActivationInProgress = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (this._accountsActivationInProgress) {
      return this._buildActivationInProgress(context);
    } else if (this._accountsActivationFailureMessage != null) {
      return this._buildActivationFailure(
          context, this._accountsActivationFailureMessage!);
    } else {
      return this._buildActivationCompleted(context);
    }
  }

  Widget _buildActivationInProgress(BuildContext context) {
    return Container(
      child: Text("ActivationInProgress"),
    );
  }

  Widget _buildActivationFailure(
      BuildContext context, String accountsActivationFailureMessage) {
    return Container(
      child: Text("ActivationFailure: ${accountsActivationFailureMessage}"),
    );
  }

  Widget _buildActivationCompleted(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: AccountsWidget(
          this.widget.data.accounts.values.toList(growable: false)),
    );
  }
}

// class AccountsWidget extends StatelessWidget {
//   final List<Account> _accounts;

//   AccountsWidget(this._accounts);

//   @override
//   Widget build(BuildContext context) {
//     final List<Account> activeAccounts = this._accounts;
//     final List<Account> inactiveAccounts = this._accounts;

//     return Container(
//       alignment: Alignment.centerLeft,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: <Widget>[
//           ...activeAccounts
//               .map((Account account) => Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: ActiveAccountWidget(account),
//                   ))
//               .toList(),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: InactiveAccountsWidget(inactiveAccounts),
//           ),
//         ],
//       ),
//     );
//   }
// }

class AccountsWidget extends StatefulWidget {
  final List<Account> accounts;

  AccountsWidget(this.accounts);

  @override
  _AccountsState createState() => _AccountsState();
}

class _AccountsState extends State<AccountsWidget> {
  List<_AccountExpansionPanelViewModel>? _accountViewModels;

  @override
  void initState() {
    super.initState();
    _accountViewModels = this
        .widget
        .accounts
        .map((Account account) => _AccountExpansionPanelViewModel(account))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    assert(this._accountViewModels != null);
    List<_AccountExpansionPanelViewModel> accountViewModels =
        this._accountViewModels!;

    return ExpansionPanelList(
      key: ObjectKey(this),
      expansionCallback: (int index, bool isExpanded) {
        setState(() {
          accountViewModels[index].isExpanded = !isExpanded;
        });
      },
      children: accountViewModels
          .map(
            (_AccountExpansionPanelViewModel item) => ExpansionPanel(
              headerBuilder: (
                BuildContext context,
                bool isExpanded,
              ) =>
                  ListTile(
                title: Row(
                  children: <Widget>[
                    Text(item.account.blockchainAddress),
                    Spacer(),
                    Text(item.account.balance),
                  ],
                ),
              ),
              body: Text("Test"),
              isExpanded: item.isExpanded,
            ),
          )
          .toList(),
    );
  }
}

//
/// stores ExpansionPanel state information
///
class _AccountExpansionPanelViewModel {
  final Account account;

  _AccountExpansionPanelViewModel(this.account) : this.isExpanded = false {
    if (account.accountType == AccountType.ACTIVE ||
        account.balance != "0.000000000") {
      this.isExpanded = true;
    }
  }

  bool isExpanded;
}

class ActiveAccountWidget extends StatelessWidget {
  final Account account;

  ActiveAccountWidget(this.account);

  @override
  Widget build(BuildContext context) {
    final SmartContract smartContract =
        SmartContract.getById(account.smartContractId);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            smartContract.name,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(account.blockchainAddress),
        ],
      ),
    );
  }
}
