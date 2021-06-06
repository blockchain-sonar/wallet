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

import "serialization_exception.dart" show SerializationException;

import "key_pair_model.dart" show KeyPairModel;

class SeedModel {
  final int seedId;
  final List<KeyPairModel> keyPairs;

  factory SeedModel.fromJson(Map<String, dynamic> rawJson) {
    final int? seedId = rawJson[SeedModel._ID_PROPERTY];
    final List<dynamic>? keyPairs = rawJson[SeedModel._KEYPAIRS_PROPERTY];

    if (seedId == null) {
      throw SerializationException(
          "A field '${SeedModel._ID_PROPERTY}' is null.");
    }

    if (keyPairs == null) {
      throw SerializationException(
          "A field '${SeedModel._KEYPAIRS_PROPERTY}' is null.");
    }

    return SeedModel(
        seedId: seedId,
        keyPairs: keyPairs
            .cast<Map<String, dynamic>>()
            .map((Map<String, dynamic> keyPairRawJson) =>
                KeyPairModel.fromJson(keyPairRawJson))
            .toList(growable: true));
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      SeedModel._ID_PROPERTY: this.seedId,
      SeedModel._KEYPAIRS_PROPERTY: this
          .keyPairs
          .map((KeyPairModel keyPair) => keyPair.toJson())
          .toList(growable: false)
    };
  }

  SeedModel({
    required this.seedId,
    List<KeyPairModel>? keyPairs,
  }) : this.keyPairs = keyPairs ?? <KeyPairModel>[];

  static const String _ID_PROPERTY = "seedId";
  static const String _KEYPAIRS_PROPERTY = "keyPairs";
}
