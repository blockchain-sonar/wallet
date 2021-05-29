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
import 'package:freeton_wallet/services/blockchain/smart_contract/smart_contract.dart';

import "../services/blockchain/blockchain.dart"
    show BlockchainService, SmartContractKeeper;
import "../services/encrypted_db_service.dart"
    show DataAccount, EncryptedDbService, KeypairBundle, KeypairBundlePlain;
import "../states/app_state.dart" show AppState;

import "../widgets/business/deploy_contract.dart" show DeployContractWidgetApi;

class DeployContractWidgetApiAdapter extends DeployContractWidgetApi {
  final AppState appState;
  final EncryptedDbService encryptedDbService;
  final BlockchainService blockchainService;
  final String accountAddress;

  Future<DataAccount>? _account;

  DeployContractWidgetApiAdapter(
    this.appState,
    this.blockchainService,
    this.encryptedDbService,
    this.accountAddress,
  ) : this._account = null;

  @override
  Future<DataAccount> get account {
    if (this._account == null) {
      this._account = _loadAccount();
    }
    return this._account!;
  }

  @override
  Future<String> calculateDeploymentFee() async {
    await Future<void>.delayed(Duration(seconds: 1));

    final DataAccount account = await this.account;

    final SmartContractBlob smartContractBlob = SmartContractKeeper.instance
        .getByFullQualifiedName(account.smartContractFullQualifiedName);
    final SmartContractAbi smartContractAbi = smartContractBlob.abi;
    final String tvcBase64 = base64Encode(smartContractBlob.tvc);

    String keySecret;

    final KeypairBundle keypairBundle = account.parentKeypairBundle;
    if (keypairBundle is KeypairBundlePlain) {
      keySecret = keypairBundle.keySecret;
    } else {
      throw FreemeworkException(
          "${KeypairBundlePlain} only supported right now.");
    }

    final String deploymentFee =
        await this.blockchainService.calculateDeploymentFee(
              account.parentKeypairBundle.keyPublic,
              keySecret,
              smartContractAbi.spec,
              tvcBase64,
            );

    return deploymentFee;
  }

  @override
  Future<void> deploy() async {
    await Future<void>.delayed(Duration(seconds: 1));

    final DataAccount account = await this.account;

    final SmartContractBlob smartContractBlob = SmartContractKeeper.instance
        .getByFullQualifiedName(account.smartContractFullQualifiedName);
    final SmartContractAbi smartContractAbi = smartContractBlob.abi;
    final String tvcBase64 = base64Encode(smartContractBlob.tvc);

    String keySecret;

    final KeypairBundle keypairBundle = account.parentKeypairBundle;
    if (keypairBundle is KeypairBundlePlain) {
      keySecret = keypairBundle.keySecret;
    } else {
      throw FreemeworkException(
          "${KeypairBundlePlain} only supported right now.");
    }

    await this.blockchainService.deployContract(
          account.parentKeypairBundle.keyPublic,
          keySecret,
          smartContractAbi.spec,
          tvcBase64,
        );
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
