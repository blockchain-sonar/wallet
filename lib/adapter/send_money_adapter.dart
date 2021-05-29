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

import 'dart:convert';

import "package:freemework/freemework.dart"
    show ExecutionContext, FreemeworkException;
import 'package:freeton_wallet/data/account.dart';
import 'package:freeton_wallet/data/key_pair.dart';

//import "../services/blockchain/smart_contract/smart_contract.dart" show SmartContractAbi, SmartContractBlob, SmartContractKeeper;

import "../services/blockchain/blockchain.dart"
    show
        BlockchainService,
        ProcessingState,
        RunMessage,
        SafeMultisigWalletAbi,
        SetcodeMultisigWalletAbi,
        SmartContactRuntime,
        SmartContractAbi,
        SmartContractBlob,
        SmartContractKeeper,
        Transaction,
        WalletAbi;
import "../services/encrypted_db_service.dart"
    show DataAccount, EncryptedDbService, KeypairBundle, KeypairBundlePlain;
import "../states/app_state.dart" show AppState;

import '../widgets/business/send_money.dart' show SendMoneyWidgetApi;

class SendMoneyWidgetApiAdapter extends SendMoneyWidgetApi {
  final AppState appState;
  final EncryptedDbService encryptedDbService;
  final BlockchainService blockchainService;
  final String accountAddress;

  SendMoneyWidgetApiAdapter(
    this.appState,
    this.blockchainService,
    this.encryptedDbService,
    this.accountAddress,
  );

  @override
  Future<String> createTransaction(
    ExecutionContext ectx,
    String destinationAddress,
    String amount,
    String comment,
  ) async {
    await Future<void>.delayed(Duration(seconds: 1));

    final DataAccount accountData = await this._loadAccount();

    final SmartContractBlob smartContractBlob = SmartContractKeeper.instance
        .getByFullQualifiedName(accountData.smartContractFullQualifiedName);
    final SmartContractAbi smartContractAbi = smartContractBlob.abi;

    if (!(smartContractAbi is WalletAbi)) {
      throw StateError("Cannot send money. Unsupported contract ABI.");
    }

    String keySecret;

    final KeypairBundle keypairBundle = accountData.parentKeypairBundle;
    if (keypairBundle is KeypairBundlePlain) {
      keySecret = keypairBundle.keySecret;
    } else {
      throw FreemeworkException(
          "${KeypairBundlePlain} only supported right now.");
    }

    final SmartContactRuntime contactRuntime = this.blockchainService;
    final Account account = Account(
      KeyPair(public: keypairBundle.keyPublic, secret: keySecret),
      accountData.blockchainAddress,
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
    final SmartContactRuntime contactRuntime = this.blockchainService;

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
    final SmartContactRuntime contactRuntime = this.blockchainService;

    final Transaction transaction = await contactRuntime.waitForRunTransaction(
      ectx,
      messageSendToken: transactionToken,
      processingStateToken: submitToken,
    );

    return transaction.transactionId;
  }

  Future<DataAccount> _loadAccount() async {
    await Future<void>.delayed(Duration(seconds: 1));

    final List<DataAccount> accounts = appState.keypairBundles
        .expand((KeypairBundle keypairBundle) => keypairBundle.accounts.values)
        .toList();
    final DataAccount account = accounts.singleWhere(
        (DataAccount account) => account.blockchainAddress == accountAddress);

    return account;
  }
}
