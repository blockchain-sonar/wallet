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

import "dart:async" show Completer, Future;

import "package:freemework/freemework.dart" show ExecutionContext;
import 'package:freeton_wallet/services/job.dart';

import "../clients/tonclient/tonclient.dart" show TonClient;

import "encrypted_db_service.dart"
    show EncryptedDbService, LocalStorageEncryptedDbService;
import "crypto_service.dart" show CryptoService, PointyCastleCryptoService;
import "blockchain/blockchain.dart"
    show BlockchainService, BlockchainServiceImpl;

abstract class ServiceFactory {
  EncryptedDbService createEncryptedDbService(
    CryptoService cryptoService,
  );
  CryptoService createCryptoService();
  Future<BlockchainService> createBlockchainService();
  JobService createJobService(
    BlockchainService blockchainService,
    EncryptedDbService encryptedDbService,
  );
}

class ServiceFactoryProductive extends ServiceFactory {
  @override
  EncryptedDbService createEncryptedDbService(
    CryptoService cryptoService,
  ) =>
      LocalStorageEncryptedDbService(cryptoService);

  @override
  CryptoService createCryptoService() => PointyCastleCryptoService();

  @override
  Future<BlockchainService> createBlockchainService() async {
    final TonClient tonClient = await this._tonClient;
    return BlockchainServiceImpl(tonClient);
  }

  Future<TonClient>? __tonClient;
  Future<TonClient> get _tonClient async {
    final Future<TonClient>? tonClientFuture = this.__tonClient;
    if (tonClientFuture != null) {
      return tonClientFuture;
    }
    Completer<TonClient> tonClientCompleter = Completer<TonClient>();

    final TonClient tonClient = TonClient();
    tonClient
        .init(ExecutionContext.EMPTY)
        .then((_) => tonClientCompleter.complete(tonClient))
        .catchError((Object error, [StackTrace? stackTrace]) =>
            tonClientCompleter.completeError(error, stackTrace));

    return this.__tonClient = tonClientCompleter.future;
  }

  @override
  JobService createJobService(
    BlockchainService blockchainService,
    EncryptedDbService encryptedDbService,
  ) =>
      JobServiceImpl(
        blockchainService: blockchainService,
        encryptedDbService: encryptedDbService,
      );
}
