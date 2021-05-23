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

import "dart:typed_data" show Uint8List;

import "tonlabs.safemultisigwallet.20200501/index.dart" as safemultisigwallet;
import "tonlabs.setcodemultisigwallet.20200506/index.dart"
    as setcodemultisigwallet;

class SmartContract {
  static const SmartContract SafeMultisigWallet = SmartContract(
      "TON Labs Safe Multisignature Wallet 20200501",
      """Multisignature wallet is a crypto wallet on the blockchain, which supports multiple owners (custodians), who are authorized to manage the wallet.

Available actions in TONOS-CLI include the following:

* Configure TONOS-CLI environment
* Create seed phrase, private/public keys
* Create wallet
* Check wallet balance
* List transactions awaiting confirmation
* Create transactions
* Confirm transactions
""",
      safemultisigwallet.ABI,
      safemultisigwallet.TVC,
      "https://github.com/tonlabs/ton-labs-contracts/tree/776bc3d614ded58330577167313a9b4f80767f41/solidity/safemultisig");

  static const SmartContract SetcodeMultisigWallet = SmartContract(
      "TON Labs Setcode Multisignature Wallet 20200506",
      """SetcodeMultisigWallet - multisignature wallet with setcode.

Multisignature wallet is a crypto wallet on the blockchain, which supports multiple owners (custodians), who are authorized to manage the wallet.

Available actions in TONOS-CLI include the following:

* Configure TONOS-CLI environment
* Create seed phrase, private/public keys
* Create wallet
* Check wallet balance
* List transactions awaiting confirmation
* Create transactions
* Confirm transactions
""",
      setcodemultisigwallet.ABI,
      setcodemultisigwallet.TVC,
      "https://github.com/tonlabs/ton-labs-contracts/tree/776bc3d614ded58330577167313a9b4f80767f41/solidity/setcodemultisig");

  static const List<SmartContract> ALL = <SmartContract>[
    SafeMultisigWallet,
    SetcodeMultisigWallet,
  ];

  final String name;
  final String descriptionMarkdown;
  final String api;

  Uint8List get tvc => Uint8List.fromList(this._tvc);
  Uri? get referenceUri {
    final String? referenceUri = this._referenceUri;
    return referenceUri != null ? Uri.parse(referenceUri) : null;
  }

  final List<int> _tvc;
  final String? _referenceUri;
  const SmartContract(
    this.name,
    this.descriptionMarkdown,
    this.api,
    this._tvc, [
    this._referenceUri = null,
  ]);
}
