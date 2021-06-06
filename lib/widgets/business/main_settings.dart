//
// Copyright 2021 Free TON Wallet Team
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// 	http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import "package:flutter/material.dart"
    show BottomNavigationBar, Icons, ListTile, Switch;
import "package:flutter/widgets.dart"
    show
        BuildContext,
        Container,
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
        VoidCallback,
        Widget;

import "../../viewmodel/app_view_model.dart" show AppViewModel;
import "package:url_launcher/url_launcher.dart" show canLaunch, launch;
import "../layout/my_scaffold.dart" show MyScaffold;

class SettingsWidgetApi {
  final AppViewModel appViewModel;
  final VoidCallback onOpenSettingsNodes;
  final VoidCallback onOpenSettingsWalletManager;

  SettingsWidgetApi(
    this.appViewModel, {
    required this.onOpenSettingsNodes,
    required this.onOpenSettingsWalletManager,
  });
}

class SettingsWidget extends StatelessWidget {
  final SettingsWidgetApi _settingsWidgetApi;
  final BottomNavigationBar _bottomNavigationBar;

  SettingsWidget(
    this._settingsWidgetApi,
    this._bottomNavigationBar,
  );

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      appBarTitle: "Settings",
      body: Container(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: _SettingsOptionsWidget(
            this._settingsWidgetApi,
          ),
        ),
      ),
      bottomNavigationBar: this._bottomNavigationBar,
    );
  }
}

class _SettingsOptionsWidget extends StatefulWidget {
  final SettingsWidgetApi _settingsWidgetApi;

  _SettingsOptionsWidget(this._settingsWidgetApi);

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
          onTap: this.widget._settingsWidgetApi.onOpenSettingsNodes,
          title: Text(
            "Nodes",
          ),
        ),
        ListTile(
          leading: Icon(
            Icons.account_balance_wallet,
          ),
          onTap: this.widget._settingsWidgetApi.onOpenSettingsWalletManager,
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
