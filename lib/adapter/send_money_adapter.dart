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

import "package:freemework/freemework.dart"
    show ExecutionContext, FreemeworkException;
import 'package:freeton_wallet/viewmodel/account_view_mode.dart';
import 'package:freeton_wallet/viewmodel/key_pair_view_model.dart';

import "../viewmodel/app_view_model.dart" show AppViewModel;

import "../misc/ton_decimal.dart" show TonDecimal;
import "../services/job.dart" show AccountsActivationJob, JobService;
import "../data/account.dart" show Account;
import "../data/key_pair.dart" show KeyPair;
import "../services/blockchain/blockchain.dart"
    show
        BlockchainService,
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
  //final EncryptedDbService encryptedDbService;
  // final BlockchainService _blockchainService;
  // final JobService _jobService;
  final AccountViewModel _dataAccount;
  // final String accountAddress;

  SendMoneyWidgetApiAdapter(
    this._dataAccount,
    this._appViewModel,
    // this._blockchainService,
    // this._jobService,
    //this.encryptedDbService,
    //this.accountAddress,
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
            this._dataAccount.smartContractFullQualifiedName);
    final SmartContractAbi smartContractAbi = smartContractBlob.abi;

    if (!(smartContractAbi is WalletAbi)) {
      throw StateError("Cannot send money. Unsupported contract ABI.");
    }

    String keySecret = ""; // TODO

    final KeyPairViewModel keyPair = this._dataAccount.parentKeyPair;
    // if (keypairBundle is KeypairBundlePlain) {
    //   keySecret = keypairBundle.keySecret;
    // } else {
    //   throw FreemeworkException(
    //       "${KeypairBundlePlain} only supported right now.");
    // }

    final SmartContactRuntime contactRuntime =
        this._appViewModel.blockchainService;
    final Account account = Account(
      KeyPair(public: keyPair.keyPublic, secret: keySecret),
      this._dataAccount.blockchainAddress,
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
