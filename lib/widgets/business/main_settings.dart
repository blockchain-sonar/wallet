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

import "dart:typed_data" show Uint8List;

import "package:flutter/material.dart";
import "package:flutter/widgets.dart"
    show
        BuildContext,
        EdgeInsets,
        Icon,
        ListView,
        MainAxisAlignment,
        Padding,
        Row,
        State,
        StatefulWidget,
        StatelessWidget,
        Text,
        Widget;

import "../../viewmodel/app_view_model.dart" show AppViewModel;
import "package:url_launcher/url_launcher.dart" show canLaunch, launch;
import "../layout/my_scaffold.dart" show MyScaffold;

class SettingsWidget extends StatelessWidget {
  final AppViewModel _appViewModel;
  final BottomNavigationBar _bottomNavigationBar;

  SettingsWidget(
    this._appViewModel,
    this._bottomNavigationBar,
  );

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      appBarTitle: "Settings",
      body: Container(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: _SettingsOptionsWidget(this._appViewModel),
        ),
      ),
      bottomNavigationBar: this._bottomNavigationBar,
    );
  }
}

// class _DataSetLoaderWidget extends StatefulWidget {
//   final SelectSettingsNodesCallback onSelectSettingsNodes;
//   final EncryptedDbService _encryptedDbService;
//   final Uint8List _encryptionKey;

//   _DataSetLoaderWidget(
//     this._encryptedDbService,
//     this._encryptionKey, {
//     required this.onSelectSettingsNodes,
//   });

//   @override
//   _DataSetLoaderWidgetState createState() => _DataSetLoaderWidgetState();
// }

// class _DataSetLoaderWidgetState extends State<_DataSetLoaderWidget> {
//   DataSet? _dataSet;

//   _DataSetLoaderWidgetState() : this._dataSet = null;

//   @override
//   void initState() {
//     super.initState();
//     this._safeLoadDataset();
//   }

//   void _safeLoadDataset() async {
//     final DataSet dataSet =
//         await this.widget._encryptedDbService.read(this.widget._encryptionKey);
//     setState(() {
//       this._dataSet = dataSet;
//     });
//   }

//   DataSet get dataSet {
//     assert(this._dataSet != null);
//     return this._dataSet!;
//   }

//   void switchAutoSave(bool value) {
//     this.dataSet.switchAutoLock(value);
//     this.widget._encryptedDbService.write(this.dataSet);
//     this._safeLoadDataset();
//   }

//   Widget _buildDataSetLoader(BuildContext context) {
//     return Text("Loading");
//   }

//   Widget _buildDataSetWorker(BuildContext context) {
//     return _SettingsOptionsWidget(
//       this.dataSet.autoLock,
//       this.switchAutoSave,
//       onSelectSettingsNodes: this.widget.onSelectSettingsNodes,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (this._dataSet == null) {
//       return this._buildDataSetLoader(context);
//     } else {
//       return this._buildDataSetWorker(context);
//     }
//   }
// }

class _SettingsOptionsWidget extends StatefulWidget {
  final AppViewModel _appViewModel;

  _SettingsOptionsWidget(this._appViewModel);

  @override
  _SettingsOptionsWidgetState createState() => _SettingsOptionsWidgetState();
}

class _SettingsOptionsWidgetState extends State<_SettingsOptionsWidget> {
  bool _autoLock;

  _SettingsOptionsWidgetState() : this._autoLock = false;

  void _switchAutoLock(bool value) {
    //this.widget._switchAutoLock(value);
    this.setState(() {
      this._autoLock = value;
    });
  }

  @override
  void initState() {
    super.initState();
    this.setState(() {
      this._autoLock = false;
    });
  }

  void _launchURL(String url) async =>
      await canLaunch(url) ? await launch(url) : throw "Could not launch $url";

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: ListTile.divideTiles(context: context, tiles: <ListTile>[
        ListTile(
          leading: Icon(
            Icons.list_alt,
          ),
          //onTap: this.widget._appViewModel.selectNode(nodeId),
          title: Text(
            "Nodes",
          ),
        ),
        ListTile(
          leading: Icon(
            Icons.account_balance_wallet,
          ),
          title: Text(
            "Wallet Manager",
          ),
        ),
        ListTile(
          leading: Icon(
            Icons.lock_clock,
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                "Auto Lock",
              ),
              Switch(
                value: this._autoLock,
                onChanged: (bool value) {
                  this._switchAutoLock(value);
                },
              )
            ],
          ),
        ),
        ListTile(
          leading: Icon(
            Icons.supervised_user_circle,
          ),
          onTap: () => this._launchURL("https://www.freeton-wallet.org/"),
          title: Text(
            "About us",
          ),
        ),
        ListTile(
          leading: Icon(Icons.logout),
          title: Text(
            "Log out",
          ),
        ),
      ]).toList(),
    );
  }
}
