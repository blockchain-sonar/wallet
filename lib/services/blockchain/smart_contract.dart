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

import "./abi/abi.dart"
    show ABI__SAFE_MULTISIG_20200501, ABI__SETCODE_MULTISIG_20200506;

import "./blobs/blobs.dart"
    show
        TVC__IO_TONLABS_SAFE_MULTISIG_20200501,
        TVC__IO_TONLABS_SETCODE_MULTISIG_20200506;

abstract class SmartContractAbi {
  static const List<SmartContractAbi> ALL = <SmartContractAbi>[
    SafeMultisigWalletAbi.instance,
    SetcodeMultisigWalletAbi.instance,
  ];

  final String spec;
  final String name;
  final String version;
  final String descriptionShort;
  final String descriptionLongMarkdown;
  Uri? get referenceUri {
    final String? referenceUri = this._referenceUri;
    return referenceUri != null ? Uri.parse(referenceUri) : null;
  }

  final String? _referenceUri;

  const SmartContractAbi._(
    this.spec,
    this.name,
    this.version,
    this.descriptionShort,
    this.descriptionLongMarkdown,
    this._referenceUri,
  );
}

class SafeMultisigWalletAbi extends SmartContractAbi {
  static const SafeMultisigWalletAbi instance = SafeMultisigWalletAbi._();

  const SafeMultisigWalletAbi._()
      : super._(
          ABI__SAFE_MULTISIG_20200501,
          "SafeMultisig",
          "v20200501",
          "Safe Multisig",
          "Safe Multisig",
          "https://github.com/tonlabs/ton-labs-contracts/tree/776bc3d614ded58330577167313a9b4f80767f41/solidity/safemultisig",
        );
}

class SetcodeMultisigWalletAbi extends SmartContractAbi {
  static const SetcodeMultisigWalletAbi instance = SetcodeMultisigWalletAbi._();

  const SetcodeMultisigWalletAbi._()
      : super._(
          ABI__SETCODE_MULTISIG_20200506,
          "SetcodeMultisig",
          "v20200506",
          "Setcode Multisig",
          "Setcode Multisig",
          "https://github.com/tonlabs/ton-labs-contracts/tree/b79bf98b89ae95b714fbcf55eb43ea22516c4788/solidity/setcodemultisig",
        );
}

class SmartContractBlob {
  static String makeFullQualifiedName(String namespace, String name) =>
      <String>[
        namespace,
        name,
      ].join(".");

  final SmartContractAbi abi;
  final String namespace;
  final String name;
  final String version;
  final String descriptionShort;
  final String descriptionLongMarkdown;

  String get fullQualifiedName => makeFullQualifiedName(
        this.namespace,
        this.name,
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
    SmartContractAbi smartContractAbi,
    String namespace,
    String name,
    String version,
    String descriptionShort,
    String descriptionLongMarkdown,
    List<int> tvc, [
    String? referenceUri = null,
  ]) {
    final String fullQualifiedName =
        SmartContractBlob.makeFullQualifiedName(namespace, name);

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
    this._blobs[IO_TONLABS_SAFE_MULTISIG_20200501.fullQualifiedName] =
        IO_TONLABS_SAFE_MULTISIG_20200501;
    this._blobs[IO_TONLABS_SETCODE_MULTISIG_20200506.fullQualifiedName] =
        IO_TONLABS_SETCODE_MULTISIG_20200506;
  }
}

// class SmartContract {
//   // static SmartContract getById(String smartContractId) {
//   //   return ALL.singleWhere(
//   //       (SmartContract smartContract) => smartContract.id == smartContractId);
//   // }

//   final String id;
//   final String name;
//   final String descriptionMarkdown;
//   final String abi;

//   Uint8List get tvc => Uint8List.fromList(this._tvc);
//   Uri? get referenceUri {
//     final String? referenceUri = this._referenceUri;
//     return referenceUri != null ? Uri.parse(referenceUri) : null;
//   }

//   final List<int> _tvc;
//   final String? _referenceUri;
//   const SmartContract(
//     this.id,
//     this.name,
//     this.descriptionMarkdown,
//     this.abi,
//     this._tvc, [
//     this._referenceUri = null,
//   ]);
// }

const Uri testUri = ConstUri();

class ConstUri implements Uri {
  const ConstUri();

  @override
  String get authority => throw UnimplementedError();

  @override
  UriData? get data => throw UnimplementedError();

  @override
  String get fragment => throw UnimplementedError();

  @override
  bool get hasAbsolutePath => throw UnimplementedError();

  @override
  bool get hasAuthority => throw UnimplementedError();

  @override
  bool get hasEmptyPath => throw UnimplementedError();

  @override
  bool get hasFragment => throw UnimplementedError();

  @override
  bool get hasPort => throw UnimplementedError();

  @override
  bool get hasQuery => throw UnimplementedError();

  @override
  bool get hasScheme => throw UnimplementedError();

  @override
  String get host => throw UnimplementedError();

  @override
  bool get isAbsolute => throw UnimplementedError();

  @override
  bool isScheme(String scheme) {
    throw UnimplementedError();
  }

  @override
  Uri normalizePath() {
    // TODO: implement normalizePath
    throw UnimplementedError();
  }

  @override
  // TODO: implement origin
  String get origin => throw UnimplementedError();

  @override
  // TODO: implement path
  String get path => throw UnimplementedError();

  @override
  // TODO: implement pathSegments
  List<String> get pathSegments => throw UnimplementedError();

  @override
  // TODO: implement port
  int get port => throw UnimplementedError();

  @override
  // TODO: implement query
  String get query => throw UnimplementedError();

  @override
  // TODO: implement queryParameters
  Map<String, String> get queryParameters => throw UnimplementedError();

  @override
  // TODO: implement queryParametersAll
  Map<String, List<String>> get queryParametersAll =>
      throw UnimplementedError();

  @override
  Uri removeFragment() {
    // TODO: implement removeFragment
    throw UnimplementedError();
  }

  @override
  Uri replace(
      {String? scheme,
      String? userInfo,
      String? host,
      int? port,
      String? path,
      Iterable<String>? pathSegments,
      String? query,
      Map<String, dynamic>? queryParameters,
      String? fragment}) {
    // TODO: implement replace
    throw UnimplementedError();
  }

  @override
  Uri resolve(String reference) {
    // TODO: implement resolve
    throw UnimplementedError();
  }

  @override
  Uri resolveUri(Uri reference) {
    // TODO: implement resolveUri
    throw UnimplementedError();
  }

  @override
  // TODO: implement scheme
  String get scheme => throw UnimplementedError();

  @override
  String toFilePath({bool? windows}) {
    // TODO: implement toFilePath
    throw UnimplementedError();
  }

  @override
  // TODO: implement userInfo
  String get userInfo => throw UnimplementedError();
}
