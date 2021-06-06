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

import "dart:convert" show base64Encode;

import "package:freemework/freemework.dart" show FreemeworkException;

import "../viewmodel/account_view_mode.dart" show AccountViewModel;
import "../viewmodel/app_view_model.dart" show AppViewModel;
import "../viewmodel/key_pair_view_model.dart" show KeyPairViewModel;
import "../misc/ton_decimal.dart" show TonDecimal;
import "../services/blockchain/smart_contract/smart_contract.dart"
    show SmartContractAbi, SmartContractBlob, SmartContractKeeper;
import "../services/blockchain/blockchain.dart" show SmartContractKeeper;
import "../widgets/business/deploy_contract.dart" show DeployContractWidgetApi;

class DeployContractWidgetApiAdapter extends DeployContractWidgetApi {
  final AppViewModel appState;
  final String accountAddress;

  Future<AccountViewModel>? _account;

  DeployContractWidgetApiAdapter(
    this.appState,
    this.accountAddress,
  ) : this._account = null;

  @override
  Future<AccountViewModel> get account {
    if (this._account == null) {
      this._account = _loadAccount();
    }
    return this._account!;
  }

  @override
  Future<TonDecimal> calculateDeploymentFee() async {
    await Future<void>.delayed(Duration(seconds: 1));

    final AccountViewModel account = await this.account;

    final SmartContractBlob smartContractBlob = SmartContractKeeper.instance
        .getByFullQualifiedName(account.smartContractFullQualifiedName);
    final SmartContractAbi smartContractAbi = smartContractBlob.abi;
    final String tvcBase64 = base64Encode(smartContractBlob.tvc);

    String keySecret;

    // final KeyPairViewModel keypairBundle = account.parentKeypairBundle;
    // if (keypairBundle is KeypairBundlePlain) {
    //   keySecret = keypairBundle.keySecret;
    // } else {
    //   throw FreemeworkException(
    //       "${KeypairBundlePlain} only supported right now.");
    // }

    // final TonDecimal deploymentFee =
    //     await this.appState.blockchainService.calculateDeploymentFee(
    //           account.parentKeypairBundle.keyPublic,
    //           keySecret,
    //           smartContractAbi.spec,
    //           tvcBase64,
    //         );

    // return deploymentFee;

    return TonDecimal.zero;
  }

  @override
  Future<void> deploy() async {
    await Future<void>.delayed(Duration(seconds: 1));

    final AccountViewModel account = await this.account;

    final SmartContractBlob smartContractBlob = SmartContractKeeper.instance
        .getByFullQualifiedName(account.smartContractFullQualifiedName);
    final SmartContractAbi smartContractAbi = smartContractBlob.abi;
    final String tvcBase64 = base64Encode(smartContractBlob.tvc);

    String keySecret;

    // final KeyPairViewModel keypairBundle = account.parentKeypairBundle;
    // if (keypairBundle is KeypairBundlePlain) {
    //   keySecret = keypairBundle.keySecret;
    // } else {
    //   throw FreemeworkException(
    //       "${KeypairBundlePlain} only supported right now.");
    // }

    // await this.appState.blockchainService.deployContract(
    //       account.parentKeypairBundle.keyPublic,
    //       keySecret,
    //       smartContractAbi.spec,
    //       tvcBase64,
    //     );
  }

  Future<AccountViewModel> _loadAccount() async {
    await Future<void>.delayed(Duration(seconds: 1));

    final List<AccountViewModel> accounts = appState.keyPairs
        .expand((KeyPairViewModel keypair) => keypair.accounts)
        .toList();
    final AccountViewModel account = accounts.singleWhere(
        (AccountViewModel account) =>
            account.blockchainAddress == accountAddress);

    return account;
  }
}
