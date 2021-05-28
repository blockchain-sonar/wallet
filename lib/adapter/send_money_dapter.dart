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

import 'package:freemework/freemework.dart';
import 'package:freeton_wallet/services/blockchain/smart_contract.dart';

import "../services/blockchain/blockchain.dart"
    show BlockchainService, SmartContractKeeper;
import "../services/encrypted_db_service.dart"
    show Account, EncryptedDbService, KeypairBundle, KeypairBundlePlain;
import "../states/app_state.dart" show AppState;

import "../widgets/business/send_modey.dart" show SendMoneyWidgetApi;

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
  Future<void> sendMoney(
    final String destinationAmount,
    final String amount,
    final String comment,
  ) async {
    await Future<void>.delayed(Duration(seconds: 1));

    final Account account = await this._loadAccount();

    String keySecret;

    final KeypairBundle keypairBundle = account.parentKeypairBundle;
    if (keypairBundle is KeypairBundlePlain) {
      keySecret = keypairBundle.keySecret;
    } else {
      throw FreemeworkException(
          "${KeypairBundlePlain} only supported right now.");
    }

    await this.blockchainService.sendTransaction(
          account.parentKeypairBundle.keyPublic,
          keySecret,
          account.blockchainAddress,
          destinationAmount,
          amount,
          comment,
        );
  }

  Future<Account> _loadAccount() async {
    await Future<void>.delayed(Duration(seconds: 1));

    final List<Account> accounts = appState.keypairBundles
        .expand((KeypairBundle keypairBundle) => keypairBundle.accounts.values)
        .toList();
    final Account account = accounts.singleWhere(
        (Account account) => account.blockchainAddress == accountAddress);

    return account;
  }
}
