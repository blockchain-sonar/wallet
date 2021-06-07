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

import "dart:typed_data" show Uint8List;

import "package:freemework/freemework.dart" show ExecutionContext;

import "../data/account.dart" show Account;
import "../data/key_pair.dart" show KeyPair;
import "../misc/ton_decimal.dart" show TonDecimal;
import "../model/app_sensetive_model.dart";
import "../model/key_pair_sensetive_model.dart";
import "../model/seed_sensetive_model.dart";
import "../services/sensetive_storage_service.dart";
import "../viewmodel/account_view_mode.dart";
import "../viewmodel/app_view_model.dart" show AppViewModel;

import "../services/blockchain/blockchain.dart"
    show
        ProcessingState,
        RunMessage,
        SmartContactRuntime,
        SmartContractAbi,
        SmartContractBlob,
        SmartContractKeeper,
        Transaction,
        WalletAbi;

import "../widgets/business/send_money.dart" show SendMoneyWidgetApi;

class SendMoneyWidgetApiAdapter extends SendMoneyWidgetApi {
  final AppViewModel _appViewModel;
  final SensetiveStorageService _sensetiveStorageService;
  final AccountViewModel _accountViewModel;

  SendMoneyWidgetApiAdapter(
    this._sensetiveStorageService,
    this._appViewModel,
    this._accountViewModel,
  );

  @override
  Future<String> createTransaction(
    ExecutionContext ectx,
    String destinationAddress,
    TonDecimal amount,
    String comment,
  ) async {
    await Future<void>.delayed(Duration(seconds: 1));

    final SmartContractBlob smartContractBlob = SmartContractKeeper.instance
        .getByFullQualifiedName(
            this._accountViewModel.smartContractFullQualifiedName);
    final SmartContractAbi smartContractAbi = smartContractBlob.abi;

    if (!(smartContractAbi is WalletAbi)) {
      throw StateError("Cannot send money. Unsupported contract ABI.");
    }

    final Uint8List encryptionKey = this._appViewModel.encryptionKey;
    final AppSensetiveModel appSensetiveModel =
        await this._sensetiveStorageService.read(encryptionKey);

    final SeedSensetiveModel sensetiveSeedModel = appSensetiveModel.seeds
        .singleWhere((SeedSensetiveModel seed) =>
            seed.seedId ==
            this._accountViewModel.parentKeyPair.parentSeed.seedId);
    final KeyPairSensetiveModel keyPairSensetiveModel = sensetiveSeedModel
        .keyPairs
        .singleWhere((KeyPairSensetiveModel keyPair) =>
            keyPair.keyPairId ==
            this._accountViewModel.parentKeyPair.keyPairId);

    final SmartContactRuntime contactRuntime =
        this._appViewModel.blockchainService;
    final Account account = Account(
      KeyPair(
        public: keyPairSensetiveModel.keyPublic,
        secret: keyPairSensetiveModel.keyPrivate,
      ),
      this._accountViewModel.blockchainAddress,
      smartContractAbi,
    );

    final RunMessage runMessage =
        await smartContractAbi.walletRegisterTransaction(
      ectx,
      contactRuntime,
      account,
      dest: destinationAddress,
      value: amount,
      bounce: false,
      flags: 0,
      payload: "",
    );

    return runMessage.messageSendToken;
  }

  @override
  Future<String> submitTransaction(
    ExecutionContext ectx,
    String transactionToken,
  ) async {
    final SmartContactRuntime contactRuntime =
        this._appViewModel.blockchainService;

    final ProcessingState processingState = await contactRuntime.sendMessage(
      ectx,
      messageSendToken: transactionToken,
    );

    return processingState.processingStateToken;
  }

  @override
  Future<String> waitForAcceptTransaction(
    ExecutionContext ectx,
    String transactionToken,
    String submitToken,
  ) async {
    final SmartContactRuntime contactRuntime =
        this._appViewModel.blockchainService;

    final Transaction transaction = await contactRuntime.waitForRunTransaction(
      ectx,
      messageSendToken: transactionToken,
      processingStateToken: submitToken,
    );

    return transaction.transactionId;
  }
}
