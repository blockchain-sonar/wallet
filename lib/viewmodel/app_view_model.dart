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

import 'dart:async';
import "dart:collection" show UnmodifiableListView;
import "dart:math" show max;
import "dart:typed_data" show Uint8List;

import "package:flutter/widgets.dart" show ChangeNotifier;
import 'package:freemework/freemework.dart';
import 'package:freeton_wallet/data/key_pair.dart';
import 'package:freeton_wallet/model/key_pair_sensetive_model.dart';

import "../model/app_model.dart" show AppModel;
import "../model/app_sensetive_model.dart" show AppSensetiveModel;
import "../model/auto_lock_delay.dart" show AutoLockDelay;
import "../model/key_pair_model.dart" show KeyPairModel;
import "../model/node_model.dart" show NodeModel;
import "../model/seed_model.dart" show SeedModel;
import "../model/seed_sensetive_model.dart" show SeedSensetiveModel;
import "../services/blockchain/blockchain.dart"
    show BlockchainService, BlockchainServiceFactory;
import "../services/sensetive_storage_service.dart"
    show SensetiveStorageService;
import "../services/storage_service.dart" show StorageService;

import "key_pair_view_model.dart" show KeyPairViewModel;
import "node_view_model.dart" show NodeViewModel;
import 'seed_view_model.dart';

class AppViewModel extends ChangeNotifier {
  AppViewModel(
    this._storageService,
    this._sensetiveStorageService,
    this._blockchainServiceFactory,
  )   : this._seedViewModels = Map<int, SeedViewModel>(),
        this._nodeViewModels = Map<String, NodeViewModel>(),
        this._encryptionKey = null {}

  Future<void> initialize(final Uint8List encryptionKey) async {
    final AppModel appModel = await this._storageService.read();
    final AppSensetiveModel appSensetiveModel =
        await this._sensetiveStorageService.read(encryptionKey);

    final List<String> nodeServerHosts =
        appModel.selectedNode.serverHosts.toList(growable: false);

    final BlockchainService blockchainService =
        await this._blockchainServiceFactory.create(nodeServerHosts);

    try {
      this.__appModel = appModel;
      this.__blockchainService = blockchainService;
      this._encryptionKey = encryptionKey;

      this._rebuildViewModels(appModel, appSensetiveModel);
    } catch (_) {
      await blockchainService.dispose();
      rethrow;
    }
  }

  Uint8List get encryptionKey {
    assert(this._encryptionKey != null);
    return this._encryptionKey!;
  }

  NodeViewModel get selectedNode {
    assert(this._nodeViewModels.containsKey(this._appModel.selectedNodeId));
    return this._nodeViewModels[this._appModel.selectedNodeId]!;
  }

  AutoLockDelay get autoLockDelay => this._appModel.autoLockDelay;
  UnmodifiableListView<KeyPairViewModel> get keyPairs =>
      UnmodifiableListView<KeyPairViewModel>(
          this.seeds.expand((SeedViewModel seed) => seed.keyPairs));
  UnmodifiableListView<SeedViewModel> get seeds =>
      UnmodifiableListView<SeedViewModel>(this._seedViewModels.values);
  UnmodifiableListView<NodeViewModel> get nodes =>
      UnmodifiableListView<NodeViewModel>(this._nodeViewModels.values);

  Future<void> addKeyPair(
    final Uint8List encryptionKey,
    final String name,
    final String keyPublic,
    final String keySecret,
    final String? mnemonicPhrase,
  ) async {
    final AppModel appModel = this._appModel;
    final AppSensetiveModel appSensetiveModel =
        await this._sensetiveStorageService.read(encryptionKey);

    SeedSensetiveModel seedSensetiveModel;
    SeedModel seedModel;
    {
      // local scope
      if (mnemonicPhrase != null) {
        final int newSeedId = _nextSeedId(appModel, appSensetiveModel);

        final Iterator<SeedSensetiveModel> existingSeedSensetiveIterator =
            appSensetiveModel.seeds
                .where((SeedSensetiveModel seed) =>
                    seed.mnemonicPhrase == mnemonicPhrase)
                .iterator;
        if (existingSeedSensetiveIterator.moveNext()) {
          seedSensetiveModel = existingSeedSensetiveIterator.current;
          seedModel = appModel.seeds.singleWhere(
              (SeedModel seed) => seed.seedId == seedSensetiveModel.seedId);
        } else {
          final SeedSensetiveModel newSeedSensetiveModel = SeedSensetiveModel(
            seedId: newSeedId,
            mnemonicPhrase: mnemonicPhrase,
          );
          final SeedModel newSeedModel = SeedModel(seedId: newSeedId);

          appSensetiveModel.seeds.add(newSeedSensetiveModel);
          appModel.seeds.add(newSeedModel);

          seedSensetiveModel = newSeedSensetiveModel;
          seedModel = newSeedModel;
        }
      } else {
        throw UnimplementedError(
            "addKeyPair without mnemonicPhrase not implemented yet");
      }
    }

    final String hdPath = "m/44'/396'/0'/0/0"; // TODO remove hardcode
    final int newKeyPairId = _nextKeyPairId(seedModel, seedSensetiveModel);

    if (seedSensetiveModel.keyPairs
        .where(
            (KeyPairSensetiveModel keyPair) => keyPair.keyPrivate == keySecret)
        .isNotEmpty) {
      throw StateError("Key already exist.");
    }

    seedSensetiveModel.keyPairs.add(KeyPairSensetiveModel(
      keyPairId: newKeyPairId,
      hdPath: hdPath,
      keyPublic: keyPublic,
      keyPrivate: keySecret,
    ));

    // Just to prevent duplicates
    seedModel.keyPairs
        .removeWhere((KeyPairModel keyPair) => keyPair.keyPublic == keyPublic);

    seedModel.keyPairs.add(KeyPairModel(
      keyPairId: newKeyPairId,
      name: name,
      hdPath: hdPath,
      keyPublic: keyPublic,
      isCollapsed: true,
      isHidden: false,
    ));

    final AppModel cloneAppModel = appModel.clone();
    await this._sensetiveStorageService.write(appSensetiveModel);
    await this._storageService.write(cloneAppModel);

    this._rebuildViewModels(appModel, appSensetiveModel);

    this.notifyListeners();
  }

  Future<void> addSeed(
    final Uint8List encryptionKey,
    final String mnemonicPhrase,
  ) async {
    final AppModel updatedAppModel = await this._storageService.read();
    final AppSensetiveModel updatedAppSensetiveModel =
        await this._sensetiveStorageService.read(encryptionKey);

    final int newSeedId =
        _nextSeedId(updatedAppModel, updatedAppSensetiveModel);

    final SeedSensetiveModel newSeedSensetiveModel = SeedSensetiveModel(
      seedId: newSeedId,
      mnemonicPhrase: mnemonicPhrase,
    );
    final SeedModel newSeedModel = SeedModel(seedId: newSeedId);

    updatedAppSensetiveModel.seeds.add(newSeedSensetiveModel);
    updatedAppModel.seeds.add(newSeedModel);

    await this._sensetiveStorageService.write(updatedAppSensetiveModel);
    await this._storageService.write(updatedAppModel);

    this._rebuildViewModels(updatedAppModel, updatedAppSensetiveModel);

    this.notifyListeners();
  }

  Future<void> persist() async {
    final AppModel cloneAppModel = this._appModel.clone();
    await this._storageService.write(cloneAppModel);
    print("AppViewModel was persisted");
  }

  Future<void> selectNode(String nodeId) async {
    final AppModel updatedAppModel = await this._storageService.read();

    assert(updatedAppModel.nodes
        .where((NodeModel node) => node.nodeId == nodeId)
        .isNotEmpty);

    updatedAppModel.selectedNodeId = nodeId;

    await this._storageService.write(updatedAppModel);

    this._rebuildViewModels(updatedAppModel);

    this.notifyListeners();
  }

  /// UI changes (like isCollapsed/isHidden flags) does not need to save syncrously
  /// Instead it schedule save operation to save all changes by once.
  void scheduleSaveUiData() {
    // TODO
    print("scheduleSaveUiData");
    if (this._saveUiDataTimer != null) {
      this._saveUiDataTimer!.cancel();
      this._saveUiDataTimer = null;
    }
    this._saveUiDataTimer = Timer(Duration(seconds: 3), () async {
      //
      try {
        await this.persist();
      } catch (e) {
        final FreemeworkException err = FreemeworkException.wrapIfNeeded(e);
        print(err.message);
      } finally {
        this._saveUiDataTimer = null;
      }
    });
  }

  Timer? _saveUiDataTimer;

  static int _nextSeedId(
    AppModel appModel,
    final AppSensetiveModel appSensetiveModel,
  ) {
    final int seedIdA =
        appModel.seeds.map((SeedModel seed) => seed.seedId).fold(0, max);
    final int seedIdB = appSensetiveModel.seeds
        .map((SeedSensetiveModel seed) => seed.seedId)
        .fold(0, max);
    final int newSeedId = max(
          seedIdA,
          seedIdB,
        ) +
        1;

    return newSeedId;
  }

  static int _nextKeyPairId(
    SeedModel seedModel,
    final SeedSensetiveModel seedSensetiveModel,
  ) {
    final int keyPairIdA = seedModel.keyPairs
        .map((KeyPairModel keyPair) => keyPair.keyPairId)
        .fold(0, max);
    final int keyPairIdB = seedSensetiveModel.keyPairs
        .map((KeyPairSensetiveModel keyPair) => keyPair.keyPairId)
        .fold(0, max);
    final int newKeyPairId = max(
          keyPairIdA,
          keyPairIdB,
        ) +
        1;

    return newKeyPairId;
  }

  final BlockchainServiceFactory _blockchainServiceFactory;
  final StorageService _storageService;
  final SensetiveStorageService _sensetiveStorageService;
  final Map<int, SeedViewModel> _seedViewModels;
  final Map<String, NodeViewModel> _nodeViewModels;

  BlockchainService? __blockchainService;
  AppModel? __appModel;
  Uint8List? _encryptionKey;

  AppModel get _appModel {
    assert(this.__appModel != null);
    return this.__appModel!;
  }

  BlockchainService get blockchainService {
    assert(this.__blockchainService != null);
    return this.__blockchainService!;
  }

  void _rebuildViewModels(
    final AppModel appModel, [
    final AppSensetiveModel? appSensetiveModel = null,
  ]) {
    this._seedViewModels.clear();
    this._nodeViewModels.clear();

    final Iterable<SeedViewModel> seedViewModels =
        appModel.seeds.map((SeedModel seedModel) => SeedViewModel(
              this.blockchainService,
              seedModel,
              this,
            ));

    final Iterable<NodeViewModel> nodeViewModels =
        appModel.nodes.map((NodeModel nodeModel) => NodeViewModel(nodeModel));

    for (NodeViewModel nodeViewModel in nodeViewModels) {
      this._nodeViewModels[nodeViewModel.nodeId] = nodeViewModel;
    }
    for (SeedViewModel seedViewModel in seedViewModels) {
      this._seedViewModels[seedViewModel.seedId] = seedViewModel;
    }
  }
}
