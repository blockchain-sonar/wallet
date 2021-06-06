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

class AccountModel {
  final String address;
  final String contractQualifiedName;
  bool isCollapsed;
  bool isHidden;

  factory AccountModel.fromJson(Map<String, dynamic> rawJson) {
    final String? address = rawJson[AccountModel._ADDRESS_PROPERTY];
    final String? contractQualifiedName =
        rawJson[AccountModel._CONTRACTQNAME_PROPERTY];
    final bool? isCollapsed = rawJson[AccountModel._ISCOLLAPSED_PROPERTY];
    final bool? isHidden = rawJson[AccountModel._ISHIDDEN_PROPERTY];

    if (address == null) {
      throw SerializationException(
          "A field '${AccountModel._ADDRESS_PROPERTY}' is null.");
    }

    if (contractQualifiedName == null) {
      throw SerializationException(
          "A field '${AccountModel._CONTRACTQNAME_PROPERTY}' is null.");
    }

    if (isCollapsed == null) {
      throw SerializationException(
          "A field '${AccountModel._ISCOLLAPSED_PROPERTY}' is null.");
    }

    if (isHidden == null) {
      throw SerializationException(
          "A field '${AccountModel._ISHIDDEN_PROPERTY}' is null.");
    }

    return AccountModel(
      address: address,
      contractQualifiedName: contractQualifiedName,
      isCollapsed: isCollapsed,
      isHidden: isHidden,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      AccountModel._ADDRESS_PROPERTY: this.address,
      AccountModel._CONTRACTQNAME_PROPERTY: this.contractQualifiedName,
      AccountModel._ISCOLLAPSED_PROPERTY: this.isCollapsed,
      AccountModel._ISHIDDEN_PROPERTY: this.isHidden,
    };
  }

  AccountModel({
    required this.address,
    required this.contractQualifiedName,
    this.isCollapsed = true,
    this.isHidden = false,
  });

  static const String _ADDRESS_PROPERTY = "address";
  static const String _CONTRACTQNAME_PROPERTY = "contractQualifiedName";
  static const String _ISCOLLAPSED_PROPERTY = "isCollapsed";
  static const String _ISHIDDEN_PROPERTY = "isHidden";
}
