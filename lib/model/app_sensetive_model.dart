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

import "seed_sensetive_model.dart" show SeedSensetiveModel;

class AppSensetiveModel {
  final List<SeedSensetiveModel> seeds;

  factory AppSensetiveModel.fromJson(Map<String, dynamic> rawJson) {
    final List<dynamic>? seeds = rawJson[AppSensetiveModel._SEEDS_PROPERTY];

    if (seeds == null) {
      throw SerializationException(
          "A field '${AppSensetiveModel._SEEDS_PROPERTY}' is null.");
    }

    return AppSensetiveModel(
      seeds: seeds
          .cast<Map<String, dynamic>>()
          .map((Map<String, dynamic> seedRawJson) =>
              SeedSensetiveModel.fromJson(seedRawJson))
          .toList(growable: true),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      AppSensetiveModel._SEEDS_PROPERTY: this
          .seeds
          .map((SeedSensetiveModel seed) => seed.toJson())
          .toList(growable: false),
    };
  }

  AppSensetiveModel({
    List<SeedSensetiveModel>? seeds,
  }) : this.seeds = seeds ?? <SeedSensetiveModel>[];

  static const String _SEEDS_PROPERTY = "seeds";
}
