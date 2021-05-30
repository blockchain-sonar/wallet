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

import "package:freemework/errors/InvalidOperationException.dart"
    show InvalidOperationException;
import 'package:freemework/freemework.dart';
import 'package:freeton_wallet/data/account.dart';
import 'package:freeton_wallet/misc/ton_decimal.dart';

import "../../clients/tonclient/tonclient.dart" as TON;

import "../../data/account_info.dart" show AccountInfo;
import "../../data/key_pair.dart" show KeyPair;
import "../../data/mnemonic_phrase.dart"
    show MnemonicPhrase, MnemonicPhraseLength;
import "smart_contract/abi.dart"
    show ProcessingState, RunMessage, SmartContactRuntime, Transaction;

abstract class BlockchainService implements SmartContactRuntime {
  Future<TonDecimal> calculateDeploymentFee(
    String keyPublic,
    String keySecret,
    String smartContractAbiSpec,
    String smartContractBlobTvcBase64,
  );
  Future<void> deployContract(
    String keyPublic,
    String keySecret,
    String smartContractAbiSpec,
    String smartContractBlobTvcBase64,
  );
  Future<KeyPair> deriveKeyPair(MnemonicPhrase mnemonicPhrase);
  Future<AccountInfo> fetchAccountInformation(String accountAddress);
  Future<MnemonicPhrase> generateMnemonicPhrase(MnemonicPhraseLength length);
  Future<String> resolveAccountAddress(
    String keyPublic,
    String smartContractAbiSpec,
    String smartContractBlobTvcBase64,
  );
}

class BlockchainServiceImpl extends BlockchainService {
  final TON.AbstractTonClient _tonClient;

  BlockchainServiceImpl(this._tonClient);

  @override
  Future<TonDecimal> calculateDeploymentFee(
    final String keyPublic,
    final String keySecret,
    final String smartContractAbiSpec,
    final String smartContractBlobTvcBase64,
  ) async {
    final TON.Fees fees = await this._tonClient.calcDeployFees(
          TON.KeyPair(public: keyPublic, secret: keySecret),
          smartContractAbiSpec,
          smartContractBlobTvcBase64,
        );

    final TonDecimal deploymentFeeEstimatedAmount = fees.totalAccountFees;

    return deploymentFeeEstimatedAmount;
  }

  @override
  Future<RunMessage> createRunMessage(
    final ExecutionContext ectx,
    final Account account,
    final String methodName,
    final Map<String, dynamic> args,
  ) async {
    final KeyPair accountKeyPair = account.keyPair;

    final TON.KeyPair tonKeyPair = TON.KeyPair(
      public: accountKeyPair.public,
      secret: accountKeyPair.secret,
    );

    final String accountSmartContractAbiSpec = account.smartContractAbi.spec;

    final TON.RunMessage tonRunMessage = await this._tonClient.createRunMessage(
          tonKeyPair,
          account.blockchainAddress,
          accountSmartContractAbiSpec,
          methodName,
          args,
        );

    final RunMessage friendlyRunMessage = RunMessage(
      tonRunMessage.address,
      tonRunMessage.messageId,
      tonRunMessage.messageBodyBase64,
      tonRunMessage.expire,
      tonRunMessage.messageSendToken,
    );

    return friendlyRunMessage;
  }

  @override
  Future<ProcessingState> sendMessage(
    final ExecutionContext ectx, {
    required final String messageSendToken,
  }) async {
    final TON.ProcessingState tonProcessingState =
        await this._tonClient.sendMessage(messageSendToken);

    final ProcessingState friendlyProcessingState = ProcessingState(
      tonProcessingState.lastBlockId,
      tonProcessingState.sendingTime,
      tonProcessingState.processingStateToken,
    );

    return friendlyProcessingState;
  }

  @override
  Future<Transaction> waitForRunTransaction(
    final ExecutionContext ectx, {
    required final String messageSendToken,
    required final String processingStateToken,
  }) async {
    final TON.Transaction tonTransaction = await this._tonClient.waitForRunTransaction(
          messageSendToken,
          processingStateToken,
        );

    final Transaction firendlyTransaction = Transaction(tonTransaction.transactionId);
    return firendlyTransaction;
  }

  @override
  Future<void> deployContract(
    String keyPublic,
    String keySecret,
    String smartContractAbiSpec,
    String smartContractBlobTvcBase64,
  ) async {
    await this._tonClient.deployContract(
          TON.KeyPair(public: keyPublic, secret: keySecret),
          smartContractAbiSpec,
          smartContractBlobTvcBase64,
        );
  }

  @override
  Future<KeyPair> deriveKeyPair(MnemonicPhrase mnemonicPhrase) async {
    final String seed = mnemonicPhrase.words.join(" ");
    TON.SeedType seedType;
    switch (mnemonicPhrase.length) {
      case MnemonicPhraseLength.LONG:
        seedType = TON.SeedType.LONG;
        break;
      case MnemonicPhraseLength.SHORT:
        seedType = TON.SeedType.SHORT;
        break;
      default:
        throw InvalidOperationException("Unsupported MnemonicPhraseLength.");
    }
    final TON.KeyPair keyPair =
        await this._tonClient.deriveKeys(seed, seedType);
    return KeyPair(public: keyPair.public, secret: keyPair.secret);
  }

  @override
  Future<AccountInfo> fetchAccountInformation(String accountAddress) async {
    final TON.AccountInfo? accountInfo =
        await this._tonClient.fetchAccountInformation(accountAddress);
    if (accountInfo != null) {
      return AccountInfo(
        accountInfo.balance,
        accountInfo is TON.DeployedAccountInfo,
      );
    }
    return AccountInfo.EMPTY;
  }

  @override
  Future<MnemonicPhrase> generateMnemonicPhrase(
      MnemonicPhraseLength length) async {
    TON.SeedType seedType;
    switch (length) {
      case MnemonicPhraseLength.LONG:
        seedType = TON.SeedType.LONG;
        break;
      case MnemonicPhraseLength.SHORT:
        seedType = TON.SeedType.SHORT;
        break;
      default:
        throw InvalidOperationException("Unsupported MnemonicPhraseLength.");
    }
    final String mnemonicSentence =
        await this._tonClient.generateMnemonicPhraseSeed(seedType);
    return MnemonicPhrase(mnemonicSentence.split(" "), length);
  }

  @override
  Future<String> resolveAccountAddress(
    String keyPublic,
    String smartContractAbiSpec,
    String smartContractBlobTvcBase64,
  ) async {
    final String address = await this._tonClient.getDeployData(
          keyPublic,
          smartContractAbiSpec,
          smartContractBlobTvcBase64,
        );
    return address;
  }

  // @override
  // Future<void> sendTransaction(
  //   String keyPublic,
  //   String keySecret,
  //   String smartContractAbiSpec,
  //   String sourceAddress,
  //   String destinationAddress,
  //   String amount,
  //   String comment,
  // ) async {
  //   await this._tonClient.sendTransaction(
  //         TON.KeyPair(public: keyPublic, secret: keySecret),
  //         smartContractAbiSpec,
  //         sourceAddress,
  //         destinationAddress,
  //         amount,
  //         comment,
  //       );
  // }
}
