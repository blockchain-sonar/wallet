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

import "abi.dart" show SafeMultisigWalletAbi, SetcodeMultisigWalletAbi, SmartContractAbi;

import "blob.dart" show SmartContractBlob;
import "blob/io.tonlabs.safemultisigwallet.20200501.dart"
    show TVC__IO_TONLABS_SAFE_MULTISIG_20200501;
import "blob/io.tonlabs.setcodemultisigwallet.20200506.dart"
    show TVC__IO_TONLABS_SETCODE_MULTISIG_20200506;

class SmartContractKeeper {
  static const SmartContractBlob IO_TONLABS_SAFE_MULTISIG_20200501 =
      SmartContractBlob(
    SafeMultisigWalletAbi.instance,
    "io.tonlabs",
    "SafeMultisig",
    "v20200501",
    "TON Labs Safe Multisignature Wallet 20200501",
    """[Multisignature wallet](https://en.freeton.wiki/SafeMultisigWallet) is a crypto wallet on the blockchain, which supports multiple owners (custodians), who are authorized to manage the wallet.

Available actions in TONOS-CLI include the following:

* Configure TONOS-CLI environment
* Create seed phrase, private/public keys
* Create wallet
* Check wallet balance
* List transactions awaiting confirmation
* Create transactions
* Confirm transactions
""",
    TVC__IO_TONLABS_SAFE_MULTISIG_20200501,
    "https://github.com/tonlabs/ton-labs-contracts/tree/776bc3d614ded58330577167313a9b4f80767f41/solidity/safemultisig",
  );

  static const SmartContractBlob IO_TONLABS_SETCODE_MULTISIG_20200506 =
      SmartContractBlob(
    SetcodeMultisigWalletAbi.instance,
    "io.tonlabs",
    "SetcodeMultisigWallet",
    "v20200506",
    "TON Labs Setcode Multisignature Wallet 20200506",
    """[SetcodeMultisigWallet](https://en.freeton.wiki/SetcodeMultisigWallet) - multisignature wallet with setcode.

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
    TVC__IO_TONLABS_SETCODE_MULTISIG_20200506,
    "https://github.com/tonlabs/ton-labs-contracts/tree/b79bf98b89ae95b714fbcf55eb43ea22516c4788/solidity/setcodemultisig",
  );

  static SmartContractKeeper get instance =>
      _instance ?? (_instance = SmartContractKeeper._());
  static SmartContractKeeper? _instance;

  final Map<String, SmartContractBlob> _blobs;

  ///
  /// Iterable over all blobs
  ///
  Iterable<SmartContractBlob> get all => this._blobs.values;

  SmartContractBlob getByFullQualifiedName(final String fullQualifiedName) {
    SmartContractBlob? blob = this._blobs[fullQualifiedName];
    if (blob == null) {
      throw ArgumentError.value(fullQualifiedName, "fullQualifiedName",
          "Trying to get unregistered Smart Contract blob.");
    }
    return blob;
  }

  SmartContractBlob register(
    final SmartContractAbi smartContractAbi,
    final String namespace,
    final String name,
    final String version,
    final String descriptionShort,
    final String descriptionLongMarkdown,
    final List<int> tvc, [
    final String? referenceUri = null,
  ]) {
    final String fullQualifiedName =
        SmartContractBlob.makeFullQualifiedName(namespace, name, version);

    if (this._blobs.containsKey(fullQualifiedName)) {
      throw StateError(
          "Cannot register Smart Contract blob '${fullQualifiedName}' twice.");
    }

    final SmartContractBlob blob = SmartContractBlob(
      smartContractAbi,
      namespace,
      name,
      version,
      descriptionShort,
      descriptionLongMarkdown,
      tvc,
      referenceUri,
    );

    this._blobs[fullQualifiedName] = blob;

    return blob;
  }

  SmartContractKeeper._() : this._blobs = Map<String, SmartContractBlob>() {
    this._blobs[IO_TONLABS_SAFE_MULTISIG_20200501.qualifiedName] =
        IO_TONLABS_SAFE_MULTISIG_20200501;
    this._blobs[IO_TONLABS_SETCODE_MULTISIG_20200506.qualifiedName] =
        IO_TONLABS_SETCODE_MULTISIG_20200506;
  }
}
