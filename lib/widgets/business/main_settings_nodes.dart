import "dart:typed_data" show Uint8List;
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
        SizedBox,
        State,
        StatefulWidget,
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
import "../layout/my_scaffold.dart" show MyScaffold;
import "../../services/encrypted_db_service.dart"
    show DataSet, EncryptedDbService, NodeBundle;

class SettingsNodesWidget extends StatefulWidget {
  final EncryptedDbService _encryptedDbService;
  final Uint8List _encryptionKey;

  SettingsNodesWidget(
    this._encryptedDbService,
    this._encryptionKey,
  );

  @override
  _SettingsNodesWidgetState createState() => _SettingsNodesWidgetState();
}

class _SettingsNodesWidgetState extends State<SettingsNodesWidget> {
  DataSet? _dataSet;

  _SettingsNodesWidgetState() : this._dataSet = null;

  DataSet get dataSet {
    assert(this._dataSet != null);
    return this._dataSet!;
  }

  @override
  void initState() {
    super.initState();
    this._safeLoadDataset();
  }

  void _safeLoadDataset() async {
    final DataSet dataSet =
        await this.widget._encryptedDbService.read(this.widget._encryptionKey);
    setState(() {
      this._dataSet = dataSet;
    });
  }

  void addNode(NodeBundle nodeBundle) {
    this.dataSet.addNode(nodeBundle);
    this.widget._encryptedDbService.write(this.dataSet);
    this._safeLoadDataset();
  }

  void deleteNode(String nodeUrl) {
    this.dataSet.deleteNodeByUrl(nodeUrl);
    this.widget._encryptedDbService.write(this.dataSet);
    this._safeLoadDataset();
  }

  void setActiveNode(NodeBundle nodeBundle) {
    this.dataSet.setActiveNode(nodeBundle);
    this.widget._encryptedDbService.write(this.dataSet);
    this._safeLoadDataset();
  }

  Widget _buildDataSetLoader(BuildContext context) {
    return Text("Loading");
  }

  Widget _buildDataSetWorker(BuildContext context) {
    return NodesManagerSettings(
      this.dataSet.nodes,
      this.dataSet.activeNodeUrl,
      this.addNode,
      this.deleteNode,
      this.setActiveNode,
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

class NodesManagerSettings extends StatefulWidget {
  final List<NodeBundle> _nodes;
  final String _activeNode;
  final Function _addNode;
  final Function _deleteNode;
  final Function _setActiveNode;

  NodesManagerSettings(
    this._nodes,
    this._activeNode,
    this._addNode,
    this._deleteNode,
    this._setActiveNode,
  );

  @override
  _NodesManagerSettingsState createState() => _NodesManagerSettingsState();
}

class _NodesManagerSettingsState extends State<NodesManagerSettings> {
  _StateSettingsNode _stateNode;
  _NodesManagerSettingsState() : this._stateNode = _StateSettingsNode("", "");

  bool get newNodeDataIsEntered =>
      this
          .widget
          ._nodes
          .where((NodeBundle node) => node.url == this._stateNode.nodeUrl)
          .isEmpty &&
      this._stateNode.isDataEntered;

  void _addNode() {
    NodeBundle node = NodeBundle(
      this._stateNode.nodeName,
      this._stateNode.nodeUrl,
      this._stateNode.nodeColor?.value,
    );
    this.widget._addNode(node);
  }

  Widget tileWidget(NodeBundle node, {bool canDelete = true}) {
    return ListTile(
      tileColor: node.color == null ? Colors.white : Color(node.color!),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                node.name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                node.url,
                style: TextStyle(
                  fontSize: 12,
                ),
              )
            ],
          ),
          Row(
            children: <Widget>[
              IconButton(
                splashRadius: 20,
                icon: Icon(
                  Icons.star,
                  color: this.widget._activeNode == node.url
                      ? Colors.blue
                      : Colors.grey,
                ),
                onPressed: () => this.widget._setActiveNode(node),
              ),
              if (canDelete)
                IconButton(
                  splashRadius: 20,
                  icon: Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                  onPressed: () => this.widget._deleteNode(node.url),
                ),
              if (!canDelete)
                SizedBox(
                  width: 40,
                ),
            ],
          )
        ],
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
            child: this.widget._nodes.isNotEmpty
                ? ListView(
                    children:
                        ListTile.divideTiles(context: context, tiles: <Widget>[
                    this.tileWidget(
                        NodeBundle(
                          "Main TON",
                          "main.ton.dev",
                          null,
                        ),
                        canDelete: false),
                    this.tileWidget(
                        NodeBundle(
                          "Net TON",
                          "net.ton.dev",
                          null,
                        ),
                        canDelete: false),
                    ...this.widget._nodes.map((NodeBundle e) => tileWidget(e)),
                  ]).toList())
                : Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      "No active nodes",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
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
                      this._stateNode.nodeName = val;
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
                      this._stateNode.nodeUrl = val;
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
                        Colors.deepPurpleAccent,
                        Colors.blueAccent,
                        Colors.cyanAccent,
                        Colors.lightGreenAccent,
                        Colors.yellowAccent,
                        Colors.orangeAccent,
                        Colors.deepOrangeAccent,
                      ]
                          .map(
                            (Color color) => InkWell(
                              borderRadius: BorderRadius.all(
                                Radius.circular(40),
                              ),
                              onTap: () {
                                setState(() {
                                  this._stateNode.nodeColor = color;
                                });
                              },
                              child: Container(
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
                                        offset: Offset(
                                            1, 1), // changes position of shadow
                                      ),
                                    ],
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(40))),
                                child: Icon(
                                  this._stateNode.nodeColor == color
                                      ? Icons.check
                                      : null,
                                  color: Colors.grey[800],
                                ),
                              ),
                            ),
                          )
                          .toList()
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                ),
                child: ElevatedButton(
                  onPressed: this.newNodeDataIsEntered ? this._addNode : null,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    child: Text("Add"),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class _StateSettingsNode {
  String nodeName;
  String nodeUrl;
  Color? nodeColor;

  bool get isDataEntered => this.nodeName.isNotEmpty && this.nodeUrl.isNotEmpty;

  _StateSettingsNode(this.nodeName, this.nodeUrl, {this.nodeColor});
}