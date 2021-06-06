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

import "dart:convert" show base64Decode;
import "dart:typed_data" show Uint8List;

import "package:flutter/material.dart" show CircularProgressIndicator;
import "package:flutter/widgets.dart"
    show
        AsyncSnapshot,
        BuildContext,
        ConnectionState,
        FutureBuilder,
        StatelessWidget,
        Widget;

import "../../services/session.dart" show SessionService;

typedef EncryptionKeyChildBuilder = Widget Function(
  BuildContext context, [
  Uint8List? encryptionKey,
]);

class EncryptionKeyLoader extends StatelessWidget {
  final SessionService _sessionService;
  final EncryptionKeyChildBuilder _childBuilder;

  EncryptionKeyLoader(this._sessionService,
      {required EncryptionKeyChildBuilder builder})
      : this._childBuilder = builder;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: this._sessionService.getValue("encryptionKey"),
      builder: this._buildSnapshotRouter,
    );
  }

  Widget _buildSnapshotRouter(
    final BuildContext context,
    final AsyncSnapshot<String> snapshot,
  ) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return _buildLoadingProgress(context);
    } else if (snapshot.hasError) {
      return this._childBuilder(context);
    }
    assert(snapshot.data != null);
    final String encryptionKeyStr = snapshot.data!;
    final Uint8List encryptionKey = base64Decode(encryptionKeyStr);

    return this._childBuilder(context, encryptionKey);
  }

  Widget _buildLoadingProgress(
    final BuildContext context,
  ) {
    return CircularProgressIndicator(
      semanticsLabel: "Circular progress indicator",
    );
  }
}
