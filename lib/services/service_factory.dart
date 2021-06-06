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

import "dart:async" show Completer, Future;

import "package:freemework/freemework.dart" show ExecutionContext;
import 'package:freeton_wallet/services/job.dart';
import 'package:freeton_wallet/services/sensetive_storage_service.dart';
import 'package:freeton_wallet/services/storage_service.dart';

import "../clients/tonclient/tonclient.dart" show TonClient;

import "encrypted_db_service.dart"
    show EncryptedDbService, LocalStorageEncryptedDbService;
import "crypto_service.dart" show CryptoService, PointyCastleCryptoService;
import "blockchain/blockchain.dart"
    show BlockchainService, BlockchainServiceFactory, BlockchainServiceImpl;

abstract class ServiceFactory {
  CryptoService createCryptoService();
  BlockchainServiceFactory createBlockchainServiceFactory();
  // JobService createJobService(
  //   BlockchainService blockchainService,
  //   EncryptedDbService encryptedDbService,
  // );
  SensetiveStorageService createSensetiveStorageService(
    CryptoService cryptoService,
  );
  StorageService createStorageService();
}

class ServiceFactoryProductive extends ServiceFactory {
  @override
  CryptoService createCryptoService() => PointyCastleCryptoService();

  @override
  BlockchainServiceFactory createBlockchainServiceFactory() =>
      _BlockchainServiceFactory();

  @override
  SensetiveStorageService createSensetiveStorageService(
          CryptoService cryptoService) =>
      SensetiveLocalStorageService(cryptoService);

  @override
  StorageService createStorageService() => LocalStorageService();

  // @override
  // JobService createJobService(
  //   BlockchainService blockchainService,
  //   EncryptedDbService encryptedDbService,
  // ) =>
  //     JobServiceImpl(
  //       blockchainService: blockchainService,
  //       encryptedDbService: encryptedDbService,
  //     );
}

class _BlockchainServiceFactory extends BlockchainServiceFactory {
  @override
  Future<BlockchainService> create(List<String> nodeServers) async {
    final TonClient tonClient = TonClient(nodeServers);
    await tonClient.init(ExecutionContext.EMPTY);
    final BlockchainService blockchainService =
        BlockchainServiceImpl(tonClient);

    return blockchainService;
  }
}
