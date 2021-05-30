import "dart:typed_data" show Uint8List;
import "package:flutter/material.dart"
    show
        BuildContext,
        Icon,
        Icons,
        ListTile,
        ListView,
        MainAxisAlignment,
        Row,
        State,
        StatefulWidget,
        Switch,
        Text,
        Widget;
import "../../services/encrypted_db_service.dart"
    show DataSet, EncryptedDbService;
import "../layout/my_scaffold.dart" show MyScaffold;
import "package:url_launcher/url_launcher.dart" show canLaunch, launch;

class SettingsWidget extends StatefulWidget {
  final EncryptedDbService _encryptedDbService;
  final Uint8List _encryptionKey;

  SettingsWidget(this._encryptedDbService, this._encryptionKey);

  @override
  _SettingsWidgetState createState() => _SettingsWidgetState();
}

class _SettingsWidgetState extends State<SettingsWidget> {
  DataSet? _dataSet;

  _SettingsWidgetState() : this._dataSet = null;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    this._safeLoadDataset(); // No await
  }

  void _safeLoadDataset() async {
    final DataSet dataSet =
        await this.widget._encryptedDbService.read(this.widget._encryptionKey);
    setState(() {
      this._dataSet = dataSet;
    });
  }

  DataSet get dataSet {
    assert(this._dataSet != null);
    return this._dataSet!;
  }

  void switchAutoSave(bool value) {
    this.dataSet.switchAutoLock(value);
    this.widget._encryptedDbService.write(this.dataSet);
    this._safeLoadDataset();
  }

  Widget _buildDataSetLoader(BuildContext context) {
    return Text("Loading");
  }

  Widget _buildDataSetWorker(BuildContext context) {
    return KeysMenagerSettings(
      this.dataSet.autoLock,
      this.switchAutoSave,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (this._dataSet == null) {
      return this._buildDataSetLoader(context);
    } else {
      return this._buildDataSetWorker(context);
    }
  }
}

class KeysMenagerSettings extends StatefulWidget {
  final bool _autoLock;
  final Function _switchAutoLock;

  KeysMenagerSettings(
    this._autoLock,
    this._switchAutoLock,
  );

  @override
  _KeysMenagerSettingsState createState() => _KeysMenagerSettingsState();
}

class _KeysMenagerSettingsState extends State<KeysMenagerSettings> {
  bool _autoLock;

  _KeysMenagerSettingsState() : this._autoLock = false;

  void _switchAutoLock(bool value) {
    this.widget._switchAutoLock(value);
    this.setState(() {
      this._autoLock = value;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    this.setState(() {
      this._autoLock = this.widget._autoLock;
    });
  }

  void _launchURL(String url) async =>
      await canLaunch(url) ? await launch(url) : throw "Could not launch $url";

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      appBarTitle: "Settings",
      body: ListView(
        children: ListTile.divideTiles(context: context, tiles: <ListTile>[
          ListTile(
            leading: Icon(
              Icons.access_alarm,
            ),
            title: Text(
              "Node",
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.account_balance_wallet,
            ),
            title: Text(
              "Wallet manager",
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
                  "Autolock",
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
            onTap: () => this._launchURL("http://google.com"),
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
      ),
    );
  }
}
