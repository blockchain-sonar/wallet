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

class KeyPairSensetiveModel {
  final int keyPairId;
  final String? hdPath;
  final String keyPublic;
  final String keyPrivate;

  factory KeyPairSensetiveModel.fromJson(Map<String, dynamic> rawJson) {
    final int? keyPairId = rawJson[KeyPairSensetiveModel._ID_PROPERTY];
    final String? hdPath = rawJson[KeyPairSensetiveModel._HDPATH_PROPERTY];
    final String? keyPublic =
        rawJson[KeyPairSensetiveModel._KEYPUBLIC_PROPERTY];
    final String? keyPrivate =
        rawJson[KeyPairSensetiveModel._KEYPRIVATE_PROPERTY];

    if (keyPairId == null) {
      throw SerializationException(
          "A field '${KeyPairSensetiveModel._ID_PROPERTY}' is null.");
    }

    if (keyPublic == null) {
      throw SerializationException(
          "A field '${KeyPairSensetiveModel._KEYPUBLIC_PROPERTY}' is null.");
    }

    if (keyPrivate == null) {
      throw SerializationException(
          "A field '${KeyPairSensetiveModel._KEYPRIVATE_PROPERTY}' is null.");
    }

    return KeyPairSensetiveModel(
      keyPairId: keyPairId,
      hdPath: hdPath,
      keyPublic: keyPublic,
      keyPrivate: keyPrivate,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      KeyPairSensetiveModel._ID_PROPERTY: this.keyPairId,
      KeyPairSensetiveModel._HDPATH_PROPERTY: this.hdPath,
      KeyPairSensetiveModel._KEYPUBLIC_PROPERTY: this.keyPublic,
      KeyPairSensetiveModel._KEYPRIVATE_PROPERTY: this.keyPrivate,
    };
  }

  KeyPairSensetiveModel({
    required this.keyPairId,
    required this.hdPath,
    required this.keyPublic,
    required this.keyPrivate,
  });

  static const String _ID_PROPERTY = "keyPairId";
  static const String _HDPATH_PROPERTY = "hdPath";
  static const String _KEYPUBLIC_PROPERTY = "keyPublic";
  static const String _KEYPRIVATE_PROPERTY = "keyPrivate";
}
