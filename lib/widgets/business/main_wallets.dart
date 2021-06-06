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
    show
        AssetImage,
        BuildContext,
        Column,
        Container,
        CrossAxisAlignment,
        EdgeInsets,
        FlexColumnWidth,
        FontWeight,
        Icon,
        Image,
        Key,
        ObjectKey,
        Padding,
        Row,
        SingleChildScrollView,
        SizedBox,
        Spacer,
        State,
        StatefulWidget,
        StatelessWidget,
        Table,
        TableCellVerticalAlignment,
        TableColumnWidth,
        TableRow,
        Text,
        TextStyle,
        UniqueKey,
        Widget;
import "package:flutter/material.dart"
    show
        BottomNavigationBar,
        Colors,
        ElevatedButton,
        ExpansionPanel,
        ExpansionPanelList,
        FloatingActionButton,
        Icons,
        InkWell,
        ListTile;
import "package:flutter/services.dart" show Clipboard, ClipboardData;
import 'package:flutter/widgets.dart';

import "../../viewmodel/account_view_mode.dart";
import "../../viewmodel/app_view_model.dart";
import "../../viewmodel/key_pair_view_model.dart";
import "../reusable/change_detector.dart";
import "package:url_launcher/url_launcher.dart" show launch;

import "../../misc/ton_decimal.dart" show TonDecimal;
import "../layout/my_scaffold.dart" show MyScaffold;
import "../../services/blockchain/blockchain.dart"
    show SmartContractBlob, SmartContractKeeper;
import "../../services/encrypted_db_service.dart" show AccountType;

typedef DeployContractCallback = void Function(AccountViewModel account);
typedef SendMoneyCallback = void Function(AccountViewModel account);

class MainWalletsWidget extends StatefulWidget {
  final AppViewModel _appState;
  // final JobService jobService;
  final void Function() onAddNewKey;
  final DeployContractCallback onDeployContract;
  final SendMoneyCallback onSendMoney;
  final BottomNavigationBar bottomNavigationBar;

  MainWalletsWidget(
    this._appState,
    this.bottomNavigationBar, {
    // required this.jobService,
    required this.onAddNewKey,
    required this.onDeployContract,
    required this.onSendMoney,
    Key? key,
  }) : super(key: key);

  @override
  _MainWalletsState createState() => _MainWalletsState();
}

class _MainWalletsState extends State<MainWalletsWidget> {
  _MainWalletsState();

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      appBarTitle: "Wallets",
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ChangeDetector(
            this.widget._appState,
            builder: this._buildPanel,
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

  Widget _buildPanel(BuildContext context) {
    final List<KeyPairViewModel> keyPairs = this
        .widget
        ._appState
        .keyPairs
        .skipWhile((KeyPairViewModel keyPair) => keyPair.isHidden)
        .toList();

    return Column(
      children: <Widget>[
        ChangeDetector(
          this.widget._appState,
          builder: (_) => ExpansionPanelList(
            key: UniqueKey(),
            expansionCallback: (int index, bool isCollapsed) {
              this.setState(() {
                keyPairs[index].isCollapsed = isCollapsed;
              });
            },
            children: keyPairs.map<ExpansionPanel>((KeyPairViewModel item) {
              final String keypairName = item.name;
              final String trimmedPublicKey = _trimPublicKey(item.keyPublic);

              return ExpansionPanel(
                headerBuilder: (BuildContext context, bool isExpanded) {
                  return ChangeDetector(
                    item,
                    builder: (_) {
                      final TonDecimal totalAmount = item.accounts.fold(
                          TonDecimal.zero,
                          (TonDecimal previousValue,
                                  AccountViewModel element) =>
                              previousValue +
                              (element.balance ?? TonDecimal.zero));

                      String? assetName = null;
                      switch (this.widget._appState.selectedNode.nodeId) {
                        case "mainnet":
                          assetName = "assets/ton-crystal.png";
                          break;
                        case "testnet":
                          assetName = "assets/ton-rubie.png";
                          break;
                      }

                      return ListTile(
                        title: Row(
                          children: <Widget>[
                            const Icon(Icons.vpn_key),
                            if (item.hasMnemonicPhrase)
                              const Icon(Icons.subtitles),
                            SizedBox(width: 10),
                            Text(keypairName),
                            Spacer(),
                            Text(totalAmount.value),
                            if (assetName != null)
                              Image(
                                image: AssetImage(assetName),
                                fit: BoxFit.scaleDown,
                                height: 24,
                              ),
                          ],
                        ),
                      );
                    },
                  );
                },
                body: ChangeDetector(
                  item,
                  builder: (_) {
                    return Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Table(
                            defaultVerticalAlignment:
                                TableCellVerticalAlignment.middle,
                            columnWidths: <int, TableColumnWidth>{
                              0: FlexColumnWidth(2),
                              1: FlexColumnWidth(5),
                              2: FlexColumnWidth(1),
                            },
                            children: <TableRow>[
                              TableRow(children: <Widget>[
                                Text(
                                  "Key Public:",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(item.keyPublic),
                                InkWell(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0, vertical: 2.0),
                                    child: Icon(Icons.content_copy),
                                  ),
                                  onTap: () {
                                    Clipboard.setData(
                                      ClipboardData(text: item.keyPublic),
                                    ); // TODO missing await
                                  },
                                ),
                              ])
                            ],
                          ),
                        ),
                        _KeyPairContentWidget(
                          item,
                          // jobService: this.widget.jobService,
                          onDeployContract: this.widget.onDeployContract,
                          onSendMoney: this.widget.onSendMoney,
                        ),
                      ],
                    );
                  },
                ),
                isExpanded: !item.isCollapsed,
              );
            }).toList(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 96.0),
        )
      ],
    );
  }
}

class _KeyPairContentWidget extends StatefulWidget {
  final KeyPairViewModel data;
  // final JobService jobService;
  final DeployContractCallback onDeployContract;
  final SendMoneyCallback onSendMoney;

  _KeyPairContentWidget(
    this.data, {
    // required this.jobService,
    required this.onDeployContract,
    required this.onSendMoney,
  });

  @override
  _KeyPairContentWidgetState createState() => _KeyPairContentWidgetState();
}

class _KeyPairContentWidgetState extends State<_KeyPairContentWidget> {
  bool _accountsActivationInProgress;
  String? _accountsActivationFailureMessage;

  _KeyPairContentWidgetState()
      : this._accountsActivationInProgress = false,
        this._accountsActivationFailureMessage = null;

  @override
  void initState() {
    super.initState();

    final KeyPairViewModel keypairBundle = this.widget.data;
    // final JobService jobService = this.widget.jobService;

    // final AccountsActivationJob? accountsActivationJob =
    //     jobService.fetchAccountsActivationJob(keypairBundle);

    // if (accountsActivationJob != null) {
    //   this._accountsActivationInProgress = true;
    //   accountsActivationJob.future.then((_) {
    //     this.setState(() {
    //       this._accountsActivationInProgress = false;
    //     });
    //   }).onError((Object error, StackTrace stackTrace) {
    //     this.setState(() {
    //       this._accountsActivationInProgress = false;
    //       this._accountsActivationFailureMessage =
    //           error is FreemeworkException ? error.message : "$error";
    //     });
    //   });
    // } else {
    //   this._accountsActivationInProgress = false;
    // }
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
        child: ChangeDetector(
          this.widget.data,
          builder: (_) {
            return _AccountsWidget(
              this.widget.data.accounts.toList(growable: false),
              onDeployContract: this.widget.onDeployContract,
              onSendMoney: this.widget.onSendMoney,
            );
          },
        ));
  }
}

class _AccountsWidget extends StatefulWidget {
  final List<AccountViewModel> accounts;
  final DeployContractCallback onDeployContract;
  final SendMoneyCallback onSendMoney;

  _AccountsWidget(
    this.accounts, {
    required this.onDeployContract,
    required this.onSendMoney,
  });

  @override
  _AccountsWidgetState createState() => _AccountsWidgetState();
}

class _AccountsWidgetState extends State<_AccountsWidget> {
  // List<_AccountExpansionPanelViewModel>? _accountViewModels;

  @override
  void initState() {
    super.initState();
    // _accountViewModels = this
    //     .widget
    //     .accounts
    //     .map((AccountViewModel account) =>
    //         _AccountExpansionPanelViewModel(account))
    //     .toList();
  }

  @override
  Widget build(BuildContext context) {
    // assert(this._accountViewModels != null);
    List<AccountViewModel> accountViewModels = this
        .widget
        .accounts
        .skipWhile((AccountViewModel account) => account.isHidden)
        .toList(growable: false);

    return ExpansionPanelList(
      // key: ObjectKey(this),
      expansionCallback: (int index, bool isCollapsed) {
        setState(() {
          accountViewModels[index].isCollapsed = isCollapsed;
        });
      },
      children: accountViewModels
          .map(
            (AccountViewModel item) => ExpansionPanel(
              headerBuilder: (
                BuildContext context,
                bool isExpanded,
              ) {
                final TonDecimal? balance = item.balance;
                return ChangeDetector(
                  item,
                  builder: (_) => ListTile(
                    key: ObjectKey(item),
                    title: Row(
                      children: <Widget>[
                        InkWell(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8.0, vertical: 2.0),
                            child: Icon(Icons.content_copy),
                          ),
                          onTap: () {
                            Clipboard.setData(
                              ClipboardData(text: item.blockchainAddress),
                            ); // TODO missing await
                          },
                        ),
                        Text(_trimAddress(item.blockchainAddress)),
                        Spacer(),
                        if (balance != null) Text(balance.value),
                      ],
                    ),
                  ),
                );
              },
              body: _AccountWidget(
                item,
                key: ObjectKey(item),
                onDeployContract: this.widget.onDeployContract,
                onSendMoney: this.widget.onSendMoney,
              ),
              isExpanded: !item.isCollapsed,
            ),
          )
          .toList(),
    );
  }
}

///
/// stores ExpansionPanel state information
///
// class _AccountExpansionPanelViewModel {
//   final AccountViewModel account;

//   _AccountExpansionPanelViewModel(this.account) : this.isExpanded = false {
//     // if (account.accountType == AccountType.ACTIVE ||
//     //     account.balance != TonDecimal.zero) {
//     //   this.isExpanded = true;
//     // }
//     this.isExpanded = !this.account.isCollapsed;
//   }

//   bool isExpanded;
// }

class _AccountWidget extends StatelessWidget {
  final AccountViewModel account;
  final DeployContractCallback onDeployContract;
  final SendMoneyCallback onSendMoney;

  _AccountWidget(
    this.account, {
    required this.onDeployContract,
    required this.onSendMoney,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final SmartContractBlob smartContractBlob = SmartContractKeeper.instance
        .getByFullQualifiedName(account.smartContractFullQualifiedName);
    // final SmartContractAbi smartContract = blob.abi;

    return Container(
      color: Colors.grey[50],
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ChangeDetector(
          this.account,
          builder: (_) => Column(
            //mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Table(
                  children: <TableRow>[
                    TableRow(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Row(
                            children: <Widget>[
                              Text(
                                "Account Address:",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              InkWell(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0, vertical: 2.0),
                                  child: Icon(Icons.link),
                                ),
                                onTap: () {
                                  final Uri baseUrl = Uri.parse(
                                    "https://net.ton.live/accounts/accountDetails",
                                  );

                                  final Uri accountDetailsUrl = baseUrl.replace(
                                      queryParameters: <String, String>{
                                        "id": account.blockchainAddress
                                      });

                                  launch(accountDetailsUrl
                                      .toString()); // TODO missing await
                                },
                              ),
                            ],
                          ),
                        ),
                        Text(account.blockchainAddress),
                      ],
                    ),
                    TableRow(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Text(
                            "Contract Type:",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Text(smartContractBlob.abi.descriptionShort),
                      ],
                    ),
                    TableRow(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Text(
                            "Contract Implementation:",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Text(smartContractBlob.descriptionShort),
                      ],
                    ),
                    TableRow(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Text(
                            "Account Status:",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Text(account.accountType == AccountType.ACTIVE
                            ? "Active"
                            : "Not deployed yet"),
                      ],
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: <Widget>[
                    if (account.accountType != AccountType.ACTIVE)
                      ElevatedButton.icon(
                        onPressed: account.balance == TonDecimal.zero
                            ? null
                            : this._onDeployContractClick,
                        icon: Icon(Icons.api),
                        label: Text("Deploy Contract"),
                      ),
                    Spacer(),
                    if (account.accountType == AccountType.ACTIVE)
                      ElevatedButton.icon(
                        onPressed: () {
                          this.onSendMoney(account);
                        },
                        icon: Icon(Icons.send),
                        label: Text("Send"),
                      ),
                  ],
                ),
              ),
              if (account.accountType != AccountType.ACTIVE &&
                  account.balance == TonDecimal.zero)
                Text(
                  "Note: Contract deployment include a litte fee. So you need positive balance on the account.",
                  style: TextStyle(color: Colors.red),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _onDeployContractClick() {
    this.onDeployContract(account);
  }
}

String _trimPublicKey(String keyPublic) {
  if (keyPublic.length > 16) {
    final String head = keyPublic.substring(0, 6);
    final String tail = keyPublic.substring(keyPublic.length - 6);
    return "${head}...${tail}";
  }
  return keyPublic;
}

String _trimAddress(String accountAddress) {
  if (accountAddress.length > 10) {
    final String head = accountAddress.substring(0, 6);
    final String tail = accountAddress.substring(accountAddress.length - 4);
    return "${head}...${tail}";
  }
  return accountAddress;
}
