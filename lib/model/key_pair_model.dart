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

import "account_model.dart" show AccountModel;
import "serialization_exception.dart" show SerializationException;

class KeyPairModel {
  final int keyPairId;
  String name;
  final String? hdPath;
  final String keyPublic;
  bool isCollapsed;
  bool isHidden;
  final List<AccountModel> accounts;

  factory KeyPairModel.fromJson(Map<String, dynamic> rawJson) {
    final int? keyPairId = rawJson[KeyPairModel._ID_PROPERTY];
    final String? name = rawJson[KeyPairModel._NAME_PROPERTY];
    final String? hdPath = rawJson[KeyPairModel._HDPATH_PROPERTY];
    final String? keyPublic = rawJson[KeyPairModel._KEYPUBLIC_PROPERTY];
    final bool? isCollapsed = rawJson[KeyPairModel._ISCOLLAPSED_PROPERTY];
    final bool? isHidden = rawJson[KeyPairModel._ISHIDDEN_PROPERTY];
    final List<dynamic>? accounts = rawJson[KeyPairModel._ACCOUNTS_PROPERTY];

    if (keyPairId == null) {
      throw SerializationException(
          "A field '${KeyPairModel._ID_PROPERTY}' is null.");
    }

    if (name == null) {
      throw SerializationException(
          "A field '${KeyPairModel._NAME_PROPERTY}' is null.");
    }

    if (keyPublic == null) {
      throw SerializationException(
          "A field '${KeyPairModel._KEYPUBLIC_PROPERTY}' is null.");
    }

    if (isCollapsed == null) {
      throw SerializationException(
          "A field '${KeyPairModel._ISCOLLAPSED_PROPERTY}' is null.");
    }

    if (isHidden == null) {
      throw SerializationException(
          "A field '${KeyPairModel._ISHIDDEN_PROPERTY}' is null.");
    }

    if (accounts == null) {
      throw SerializationException(
          "A field '${KeyPairModel._ACCOUNTS_PROPERTY}' is null.");
    }

    return KeyPairModel(
      keyPairId: keyPairId,
      name: name,
      hdPath: hdPath,
      keyPublic: keyPublic,
      isCollapsed: isCollapsed,
      isHidden: isHidden,
      accounts: accounts
          .cast<Map<String, dynamic>>()
          .map((Map<String, dynamic> accountRawJson) =>
              AccountModel.fromJson(accountRawJson))
          .toList(growable: true),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      KeyPairModel._ID_PROPERTY: this.keyPairId,
      KeyPairModel._NAME_PROPERTY: this.name,
      KeyPairModel._HDPATH_PROPERTY: this.hdPath,
      KeyPairModel._KEYPUBLIC_PROPERTY: this.keyPublic,
      KeyPairModel._ISCOLLAPSED_PROPERTY: this.isCollapsed,
      KeyPairModel._ISHIDDEN_PROPERTY: this.isHidden,
      KeyPairModel._ACCOUNTS_PROPERTY: this
          .accounts
          .map((AccountModel account) => account.toJson())
          .toList(growable: false),
    };
  }

  KeyPairModel({
    required this.keyPairId,
    required this.name,
    required this.hdPath,
    required this.keyPublic,
    required this.isCollapsed,
    required this.isHidden,
    List<AccountModel>? accounts,
  }) : this.accounts = accounts ?? <AccountModel>[];

  static const String _ID_PROPERTY = "keyPairId";
  static const String _NAME_PROPERTY = "name";
  static const String _HDPATH_PROPERTY = "hdPath";
  static const String _KEYPUBLIC_PROPERTY = "keyPublic";
  static const String _ISCOLLAPSED_PROPERTY = "isCollapsed";
  static const String _ISHIDDEN_PROPERTY = "isHidden";
  static const String _ACCOUNTS_PROPERTY = "accounts";
}
