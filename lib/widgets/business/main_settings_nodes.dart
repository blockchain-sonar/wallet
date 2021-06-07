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

import "dart:ui" show FontWeight, TextAlign;
import "package:flutter/material.dart"
    show
        Border,
        BorderRadius,
        BoxDecoration,
        BoxShadow,
        BuildContext,
        Color,
        Colors,
        Column,
        Container,
        ElevatedButton,
        Expanded,
        ExpansionTile,
        Icon,
        IconButton,
        Icons,
        InkWell,
        InputDecoration,
        ListTile,
        ListView,
        Offset,
        Radius,
        State,
        StatefulWidget,
        StatelessWidget,
        Text,
        TextFormField,
        UnderlineInputBorder,
        Widget;
import "package:flutter/src/widgets/basic.dart"
    show
        Column,
        CrossAxisAlignment,
        EdgeInsets,
        Expanded,
        FontWeight,
        MainAxisAlignment,
        Padding,
        Row,
        TextAlign,
        TextStyle;
import "../../viewmodel/app_view_model.dart" show AppViewModel;
import "../../viewmodel/node_view_model.dart" show NodeViewModel;
import "../reusable/change_detector.dart" show ChangeDetector;
import "../layout/my_scaffold.dart" show MyScaffold;

class SettingsNodesWidget extends StatelessWidget {
  final AppViewModel _appViewModel;
  SettingsNodesWidget(
    this._appViewModel,
  );

  @override
  Widget build(BuildContext context) {
    return NodesManagerSettings(this._appViewModel);
  }
}

class NodesManagerSettings extends StatefulWidget {
  final AppViewModel _appViewModel;

  NodesManagerSettings(
    this._appViewModel,
  );

  @override
  _NodesManagerSettingsState createState() => _NodesManagerSettingsState();
}

class _NodesManagerSettingsState extends State<NodesManagerSettings> {
  _StateSettingsNode _stateNode;
  _NodesManagerSettingsState() : this._stateNode = _StateSettingsNode.EMPTY();

  bool get newNodeDataIsEntered {
    final _StateSettingsNode? stateNode = this._stateNode;
    if (stateNode == null) {
      return false;
    }
    return this
            .widget
            ._appViewModel
            .nodes
            .where((NodeViewModel node) =>
                node.nodeId == stateNode.nodeName.toLowerCase())
            .isEmpty &&
        stateNode.isDataEntered;
  }

  void _addNode() {
    final _StateSettingsNode stateNode = this._stateNode;
    this.widget._appViewModel.addNode(
          stateNode.nodeName,
          stateNode.nodeUrl,
          stateNode.nodeColor,
        );
  }

  void _setActiveNode(NodeViewModel node) {
    this.widget._appViewModel.selectNode(node.nodeId);
  }

  void _deleteNode(NodeViewModel node) {
    this.widget._appViewModel.deleteNode(node.nodeId);
  }

  bool _canDelete(NodeViewModel node) =>
      !<String>["mainnet", "testnet"].contains(node.nodeId);

  Widget _buildNodeTileWidget(NodeViewModel node) {
    return ListTile(
      onTap: () => this._setActiveNode(node),
      title: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: _buildNodeColorWidget(node.color,
                      this.widget._appViewModel.selectedNode == node),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        node.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        node.servers.join(", "),
                        style: TextStyle(
                          fontSize: 12,
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
            if (this._canDelete(node))
              IconButton(
                splashRadius: 20,
                icon: Icon(
                  Icons.delete,
                  color: Colors.red[900],
                ),
                onPressed: () => this._deleteNode(node),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      appBarTitle: "Nodes",
      body: Column(
        children: <Widget>[
          Expanded(
            child: ChangeDetector(
              this.widget._appViewModel,
              builder: (_) {
                return ListView(
                    children:
                        ListTile.divideTiles(context: context, tiles: <Widget>[
                  ...this
                      .widget
                      ._appViewModel
                      .nodes
                      .map((NodeViewModel node) => _buildNodeTileWidget(node)),
                ]).toList());
              },
            ),
          ),
          ExpansionTile(
            title: Text(
              "Add node",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 50,
                ),
                child: TextFormField(
                  onChanged: (String val) {
                    setState(() {
                      final _StateSettingsNode stateNode = this._stateNode;
                      stateNode.nodeName = val;
                    });
                  },
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: "Node name",
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 50,
                ),
                child: TextFormField(
                  onChanged: (String val) {
                    setState(() {
                      final _StateSettingsNode stateNode = this._stateNode;
                      stateNode.nodeUrl = val;
                    });
                  },
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: "Node url",
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 60,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      ...<Color>[
                        Colors.redAccent,
                        Colors.cyanAccent,
                        Colors.greenAccent,
                        Colors.yellowAccent,
                        Colors.orangeAccent,
                        Colors.indigoAccent,
                      ].map(
                        (Color color) {
                          final _StateSettingsNode stateNode = this._stateNode;
                          final bool isChecked = stateNode.nodeColor == color;

                          return InkWell(
                            borderRadius: BorderRadius.all(
                              Radius.circular(40),
                            ),
                            onTap: () {
                              setState(() {
                                stateNode.nodeColor = color;
                              });
                            },
                            child: _buildNodeColorWidget(
                              color,
                              isChecked,
                            ),
                          );
                        },
                      ).toList()
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                ),
                child: ChangeDetector(
                  this.widget._appViewModel,
                  builder: (_) {
                    return ElevatedButton(
                      onPressed:
                          this.newNodeDataIsEntered ? this._addNode : null,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        child: Text("Add"),
                      ),
                    );
                  },
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildNodeColorWidget(Color color, bool isCheck) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
          color: color,
          border: Border.all(color: color),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 2,
              offset: Offset(1, 1), // changes position of shadow
            ),
          ],
          borderRadius: BorderRadius.all(Radius.circular(40))),
      child: Icon(
        isCheck ? Icons.check : null,
        color: Colors.grey[800],
      ),
    );
  }
}

class _StateSettingsNode {
  String nodeName;
  String nodeUrl;
  Color nodeColor;

  factory _StateSettingsNode.EMPTY() {
    return _StateSettingsNode("", "", nodeColor: Colors.white);
  }

  bool get isDataEntered => this.nodeName.isNotEmpty && this.nodeUrl.isNotEmpty;

  _StateSettingsNode(this.nodeName, this.nodeUrl, {required this.nodeColor});
}
