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
import "../../clients/tonclient/tonclient.dart" as TON;

import "../../data/key_pair.dart" show KeyPair;
import "../../data/mnemonic_phrase.dart" show MnemonicPhrase, MnemonicPhraseLength;

abstract class BlockchainService {
  Future<MnemonicPhrase> generateMnemonicPhrase(MnemonicPhraseLength length);
  Future<KeyPair> deriveKeyPair(MnemonicPhrase mnemonicPhrase);
  Future<Object> getDeployData(KeyPair keyPair);
}

class BlockchainServiceImpl extends BlockchainService {
  final TON.AbstractTonClient _tonClient;

  BlockchainServiceImpl(this._tonClient);

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
  Future<Object> getDeployData(KeyPair walletKeyPair) async {
    final TON.KeyPair keyPair = TON.KeyPair(
      public: walletKeyPair.public,
      secret: walletKeyPair.secret,
    );
    final TON.DeployData res = await this._tonClient.getDeployData(keyPair);
    print(res);
    return res;
  }
}