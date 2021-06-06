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

import "key_pair_sensetive_model.dart" show KeyPairSensetiveModel;
import "serialization_exception.dart" show SerializationException;

class SeedSensetiveModel {
  final int seedId;
  final String mnemonicPhrase;
  final List<KeyPairSensetiveModel> keyPairs;

  factory SeedSensetiveModel.fromJson(Map<String, dynamic> rawJson) {
    final int? seedId = rawJson[SeedSensetiveModel._ID_PROPERTY];
    final String? mnemonicPhrase =
        rawJson[SeedSensetiveModel._MNEMONICPHRASE_PROPERTY];
    final List<dynamic>? keyPairs =
        rawJson[SeedSensetiveModel._KEYPAIRS_PROPERTY];

    if (seedId == null) {
      throw SerializationException(
          "A field '${SeedSensetiveModel._ID_PROPERTY}' is null.");
    }

    if (mnemonicPhrase == null) {
      throw SerializationException(
          "A field '${SeedSensetiveModel._MNEMONICPHRASE_PROPERTY}' is null.");
    }

    if (keyPairs == null) {
      throw SerializationException(
          "A field '${SeedSensetiveModel._KEYPAIRS_PROPERTY}' is null.");
    }

    return SeedSensetiveModel(
        seedId: seedId,
        mnemonicPhrase: mnemonicPhrase,
        keyPairs: keyPairs
            .cast<Map<String, dynamic>>()
            .map((Map<String, dynamic> keyPairRawJson) =>
                KeyPairSensetiveModel.fromJson(keyPairRawJson))
            .toList(growable: true));
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      SeedSensetiveModel._ID_PROPERTY: this.seedId,
      SeedSensetiveModel._MNEMONICPHRASE_PROPERTY: this.mnemonicPhrase,
      SeedSensetiveModel._KEYPAIRS_PROPERTY: this
          .keyPairs
          .map((KeyPairSensetiveModel keyPair) => keyPair.toJson())
          .toList(growable: false)
    };
  }

  SeedSensetiveModel({
    required this.seedId,
    required this.mnemonicPhrase,
    List<KeyPairSensetiveModel>? keyPairs,
  }) : this.keyPairs = keyPairs ?? <KeyPairSensetiveModel>[];

  static const String _ID_PROPERTY = "seedId";
  static const String _MNEMONICPHRASE_PROPERTY = "mnemonicPhrase";
  static const String _KEYPAIRS_PROPERTY = "keyPairs";
}
