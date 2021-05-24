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

import "package:flutter/widgets.dart";
import "package:freemework/freemework.dart" show ExecutionContext;

import "data/mnemonic_phrase.dart" show MnemonicPhrase;
import "widgets/business/enter_wallet_name.dart"
    show EnterWalletNameContext, EnterWalletNameWidget;
import "widgets/business/restore_by_private_key.dart"
    show RestoreByPrivateKeyContext, RestoreByPrivateKeyWidget;
import "widgets/business/restore_by_mnemonic_phrase.dart";
import "widgets/business/restore_mode_selector.dart"
    show RestoreMode, RestoreModeSelectorContext, RestoreModeSelectorWidget;

class WizzardKeyRestoreResult {
  final String walletName;

  WizzardKeyRestoreResult._(this.walletName);
}

class WizzardKeyRestoreMnemonicPhraseResult extends WizzardKeyRestoreResult {
  final MnemonicPhrase mnemonicPhrase;

  WizzardKeyRestoreMnemonicPhraseResult._(
      String walletName, this.mnemonicPhrase)
      : super._(walletName);
}

class WizzardKeyRestoreWidget extends StatefulWidget {
  final Future<void> Function(WizzardKeyRestoreResult result) onComplete;

  WizzardKeyRestoreWidget({
    required this.onComplete,
  });

  @override
  _WizzardKeyRestoreWidgeteState createState() =>
      _WizzardKeyRestoreWidgeteState();
}

class _WizzardKeyRestoreWidgeteState extends State<WizzardKeyRestoreWidget> {
  String? _keyName;
  RestoreMode? _restoreMode;

  _WizzardKeyRestoreWidgeteState()
      : this._restoreMode = null,
        this._keyName = null;

  void _setRestoreMode(RestoreMode mode) {
    this.setState(() {
      this._restoreMode = mode;
    });
  }

  void _setKeyName(String keyName) {
    this.setState(() {
      this._keyName = keyName;
    });
  }

  @override
  Widget build(BuildContext context) {
    final String? keyName = this._keyName;
    if (keyName == null) {
      return EnterWalletNameWidget(
        onComplete: (
          ExecutionContext executionContext,
          EnterWalletNameContext actionContext,
        ) {
          this._setKeyName(actionContext.keyName);
        },
      );
    } else {
      switch (this._restoreMode) {
        case RestoreMode.MNEMONIC:
          return RestoreByMnemonicPhraseWidget(
            onComplete: (ExecutionContext executionContext,
                RestoreByMnemonicPhraseContext actionContext) async {
              final MnemonicPhrase mnemonicPhrase =
                  MnemonicPhrase(actionContext.mnemonicPhraseWords);

              final WizzardKeyRestoreResult result =
                  WizzardKeyRestoreMnemonicPhraseResult._(keyName, mnemonicPhrase);

              await this.widget.onComplete(result);
            },
          );
        case RestoreMode.PRIVATE_KEY:
          return RestoreByPrivateKeyWidget(
            onComplete: (
              ExecutionContext executionContext,
              RestoreByPrivateKeyContext actionContext,
            ) {},
          );
        default:
          return RestoreModeSelectorWidget(
            onComplete: (
              ExecutionContext executionContext,
              RestoreModeSelectorContext actionContext,
            ) {
              this._setRestoreMode(actionContext.mode);
            },
          );
      }
    }
  }
}
