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

import 'package:flutter/material.dart';
import "package:flutter/widgets.dart" show Color, IconData;

import "serialization_exception.dart" show SerializationException;

class NodeModel {
  static const IconData COIN_ICON__LIVE__TON_CRYSTAL =
      IconData(0xe037, fontFamily: "MaterialIcons");
  static const IconData COIN_ICON__TEST__RUBIE =
      IconData(0xf525, fontFamily: "MaterialIcons");
  static const IconData COIN_ICON__UNKNOWN =
      IconData(0xe759, fontFamily: "MaterialIcons");
  static const List<IconData> COIN_ICONS = <IconData>[
    COIN_ICON__LIVE__TON_CRYSTAL,
    COIN_ICON__TEST__RUBIE,
    COIN_ICON__UNKNOWN
  ];
  static const Map<String, IconData> _coinIconMap = <String, IconData>{
    "live_ton_crystal": COIN_ICON__LIVE__TON_CRYSTAL,
    "test_rubie": COIN_ICON__TEST__RUBIE,
    "unknown": COIN_ICON__UNKNOWN,
  };

  static const String NODE_MAINNET_NODEID = "mainnet";

  static const NodeModel NODE_MAINNET = NodeModel._(
    NODE_MAINNET_NODEID,
    "Mainnet",
    <String>["main.ton.dev"],
    Colors.blue,
    NodeModel.COIN_ICON__LIVE__TON_CRYSTAL,
  );
  static const NodeModel NODE_TESTNET = NodeModel._(
    "testnet",
    "Testnet",
    <String>["net.ton.dev"],
    Colors.purple,
    NodeModel.COIN_ICON__TEST__RUBIE,
  );

  final String nodeId;
  final String name;
  final List<String> serverHosts;
  final Color color;
  final IconData coinIcon;

  factory NodeModel.fromJson(Map<String, dynamic> rawJson) {
    final String? nodeId = rawJson[NodeModel._ID_PROPERTY];
    final String? name = rawJson[NodeModel._NAME_PROPERTY];
    final String? serverHostsSentence = rawJson[NodeModel._SERVERHOST_PROPERTY];
    final String? colorStr = rawJson[NodeModel._COLOR_PROPERTY];
    final String? coinIconKey = rawJson[NodeModel._COINICON_PROPERTY];

    if (nodeId == null) {
      throw SerializationException(
          "A field '${NodeModel._ID_PROPERTY}' is null.");
    }

    if (name == null) {
      throw SerializationException(
          "A field '${NodeModel._NAME_PROPERTY}' is null.");
    }

    if (serverHostsSentence == null) {
      throw SerializationException(
          "A field '${NodeModel._SERVERHOST_PROPERTY}' is null.");
    }
    final Set<String> serverHosts = serverHostsSentence
        .split(",")
        .map((String serverHost) => serverHost.trim())
        .toSet();

    if (colorStr == null) {
      throw SerializationException(
          "A field '${NodeModel._COLOR_PROPERTY}' is null.");
    }

    if (coinIconKey == null) {
      throw SerializationException(
          "A field '${NodeModel._COINICON_PROPERTY}' is null.");
    }

    final Color color = Color(int.parse(colorStr, radix: 16));

    if (!NodeModel._coinIconMap.containsKey(coinIconKey)) {
      final String supportedCoinIconKeys =
          NodeModel._coinIconMap.keys.map((e) => "'${e}'").join(", ");
      throw SerializationException(
          "A field '${NodeModel._COINICON_PROPERTY}' has unsupported value '${coinIconKey}'. Expected one of: ${supportedCoinIconKeys}.");
    }

    final IconData coinIcon = NodeModel._coinIconMap[coinIconKey]!;

    return NodeModel(
      nodeId,
      name,
      serverHosts.toList(),
      color,
      coinIcon,
    );
  }

  factory NodeModel(
    final String nodeId,
    final String name,
    final List<String> serverHosts,
    final Color color,
    final IconData coinIcon,
  ) {
    assert(NodeModel._coinIconMap.containsValue(coinIcon));
    if (serverHosts.length == 0) {
      throw ArgumentError(
          "A serverHosts argument should contains at least one item in the list.");
    }

    return NodeModel._(
      nodeId,
      name,
      serverHosts,
      color,
      coinIcon,
    );
  }

  Map<String, dynamic> toJson() {
    final String coinIconKey = NodeModel._coinIconMap.entries
        .singleWhere(
            (MapEntry<String, IconData> pair) => pair.value == this.coinIcon)
        .key;

    return <String, dynamic>{
      NodeModel._ID_PROPERTY: this.nodeId,
      NodeModel._NAME_PROPERTY: this.name,
      NodeModel._SERVERHOST_PROPERTY: this.serverHosts.join(", "),
      NodeModel._COLOR_PROPERTY: this.color.value.toRadixString(16),
      NodeModel._COINICON_PROPERTY: coinIconKey,
    };
  }

  const NodeModel._(
    this.nodeId,
    this.name,
    this.serverHosts,
    this.color,
    this.coinIcon,
  );

  static const String _ID_PROPERTY = "nodeId";
  static const String _NAME_PROPERTY = "name";
  static const String _SERVERHOST_PROPERTY = "serverHost";
  static const String _COLOR_PROPERTY = "color";
  static const String _COINICON_PROPERTY = "icon";
}
