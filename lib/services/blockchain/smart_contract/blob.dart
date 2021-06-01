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

import "abi.dart" show SmartContractAbi;

class SmartContractBlob {
  static String makeFullQualifiedName(
    final String namespace,
    final String name,
    final String version,
  ) =>
      "$namespace.$name:$version";

  final SmartContractAbi abi;
  final String namespace;
  final String name;
  final String version;
  final String descriptionShort;
  final String descriptionLongMarkdown;

  String get qualifiedName => makeFullQualifiedName(
        this.namespace,
        this.name,
        this.version,
      );

  Uint8List get tvc => Uint8List.fromList(this._tvc);
  Uri? get referenceUri {
    final String? referenceUri = this._referenceUri;
    return referenceUri != null ? Uri.parse(referenceUri) : null;
  }

  final List<int> _tvc;
  final String? _referenceUri;

  const SmartContractBlob(
    this.abi,
    this.namespace,
    this.name,
    this.version,
    this.descriptionShort,
    this.descriptionLongMarkdown,
    this._tvc, [
    this._referenceUri = null,
  ]);
}
