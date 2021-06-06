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

import "serialization_exception.dart" show SerializationException;

import "auto_lock_delay.dart" show AutoLockDelay;
import "node_model.dart" show NodeModel;
import "seed_model.dart" show SeedModel;

class AppModel {
  static final AppModel EMPTY = AppModel(
    autoLockDelay: AutoLockDelay.HalfMinute,
    selectedNodeId: NodeModel.NODE_MAINNET_NODEID,
    nodes: <NodeModel>[
      NodeModel.NODE_MAINNET,
      NodeModel.NODE_TESTNET,
    ],
    seeds: <SeedModel>[],
  );

  String selectedNodeId;
  AutoLockDelay autoLockDelay;
  final List<NodeModel> nodes;
  final List<SeedModel> seeds;

  NodeModel get selectedNode => this
      .nodes
      .singleWhere((NodeModel node) => node.nodeId == this.selectedNodeId);

  factory AppModel.fromJson(Map<String, dynamic> rawJson) {
    final String? selectedNodeId = rawJson[AppModel._SELECTEDNODE_PROPERTY];
    final String? autoLockDelayName = rawJson[AppModel._AUTOLOCKDELAY_PROPERTY];
    final List<dynamic>? nodes = rawJson[AppModel._NODES_PROPERTY];
    final List<dynamic>? seeds = rawJson[AppModel._SEEDS_PROPERTY];

    if (selectedNodeId == null) {
      throw SerializationException(
          "A field '${AppModel._SELECTEDNODE_PROPERTY}' is null.");
    }

    if (autoLockDelayName == null) {
      throw SerializationException(
          "A field '${AppModel._AUTOLOCKDELAY_PROPERTY}' is null.");
    }

    if (nodes == null) {
      throw SerializationException(
          "A field '${AppModel._NODES_PROPERTY}' is null.");
    }

    final List<NodeModel> nodeModels = nodes
        .cast<Map<String, dynamic>>()
        .map((Map<String, dynamic> nodeRawJson) =>
            NodeModel.fromJson(nodeRawJson))
        .toList(growable: true);
    {
      // local scope
      final List<String> nodeIds = nodeModels
          .map((NodeModel nodeModel) => nodeModel.nodeId)
          .toList(growable: false);
      final Set<String> nodeUniqueIds = nodeIds.toSet();
      if (nodeIds.length > nodeUniqueIds.length) {
        throw SerializationException(
            "A field '${AppModel._NODES_PROPERTY}' is invalid. The nodes has duplicate id.");
      }
    }

    if (seeds == null) {
      throw SerializationException(
          "A field '${AppModel._SEEDS_PROPERTY}' is null.");
    }

    final List<SeedModel> seedModels = seeds
        .cast<Map<String, dynamic>>()
        .map((Map<String, dynamic> seedRawJson) =>
            SeedModel.fromJson(seedRawJson))
        .toList(growable: true);
    {
      // local scope
      final List<int> seedIds = seedModels
          .map((SeedModel seedModel) => seedModel.seedId)
          .toList(growable: false);
      final Set<int> seedUniqueIds = seedIds.toSet();
      if (seedIds.length > seedUniqueIds.length) {
        throw SerializationException(
            "A field '${AppModel._SEEDS_PROPERTY}' is invalid. The seeds has duplicate id.");
      }
    }

    final AutoLockDelay autoLockDelay = AutoLockDelay.parse(autoLockDelayName);

    return AppModel(
      selectedNodeId: selectedNodeId,
      autoLockDelay: autoLockDelay,
      nodes: nodeModels,
      seeds: seedModels,
    );
  }

  AppModel clone() {
    return AppModel.fromJson(this.toJson());
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      AppModel._AUTOLOCKDELAY_PROPERTY: this.autoLockDelay.toString(),
      AppModel._SELECTEDNODE_PROPERTY: this.selectedNodeId,
      AppModel._NODES_PROPERTY: this
          .nodes
          .map((NodeModel node) => node.toJson())
          .toList(growable: false),
      AppModel._SEEDS_PROPERTY: this
          .seeds
          .map((SeedModel seed) => seed.toJson())
          .toList(growable: false),
    };
  }

  AppModel({
    required this.autoLockDelay,
    required this.selectedNodeId,
    required this.nodes,
    required this.seeds,
  });

  static const String _SEEDS_PROPERTY = "seeds";
  static const String _NODES_PROPERTY = "nodes";
  static const String _SELECTEDNODE_PROPERTY = "selectedNodeId";
  static const String _AUTOLOCKDELAY_PROPERTY = "autoLockDelay";
}
