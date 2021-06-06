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

import "package:flutter/widgets.dart";
import "package:freemework/freemework.dart" show ExecutionContext;

import "data/key_pair.dart" show KeyPair;
import "data/mnemonic_phrase.dart" show MnemonicPhrase;
import "services/blockchain/blockchain.dart" show BlockchainService;
import "wizzard_key_new.dart" show WizzardWalletNewWidget;
import "wizzard_key_restore.dart"
    show
        WizzardKeyRestoreMnemonicPhraseResult,
        WizzardKeyRestoreResult,
        WizzardKeyRestoreWidget;
import "widgets/business/import_mode_selector.dart"
    show ImportMode, ImportModeSelectorContext, ImportModeSelectorWidget;

typedef _CompleteCallback = Future<void> Function(
  String walletName,
  KeyPair keyPair,
  MnemonicPhrase? mnemonicPhrase,
);

class WizzardWalletWidget extends StatefulWidget {
  final BlockchainService _blockchainService;
  final _CompleteCallback _onComplete;

  WizzardWalletWidget(
    this._blockchainService, {
    required _CompleteCallback onComplete,
  }) : this._onComplete = onComplete;

  @override
  _WizzardWalletWidgetState createState() => _WizzardWalletWidgetState();
}

class _WizzardWalletWidgetState extends State<WizzardWalletWidget> {
  ImportMode? _importMode;

  _WizzardWalletWidgetState() : this._importMode = null;

  void _setImportMode(ImportMode mode) {
    this.setState(() {
      this._importMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (this._importMode) {
      case ImportMode.CREATE:
        return WizzardWalletNewWidget(
          this.widget._blockchainService,
          onComplete: (String walletName, MnemonicPhrase mnemonicPhrase) async {
            await Future<void>.delayed(Duration(seconds: 1));
            final KeyPair keyPair = await this
                .widget
                ._blockchainService
                .deriveKeyPair(mnemonicPhrase);
            await this.widget._onComplete(
                  walletName,
                  keyPair,
                  mnemonicPhrase,
                );
          },
        );
      case ImportMode.RESTORE:
        return WizzardKeyRestoreWidget(
          onComplete: (WizzardKeyRestoreResult restoreResult) async {
            await Future<void>.delayed(Duration(seconds: 1));
            if (restoreResult is WizzardKeyRestoreMnemonicPhraseResult) {
              final KeyPair keyPair = await this
                  .widget
                  ._blockchainService
                  .deriveKeyPair(restoreResult.mnemonicPhrase);
              await this.widget._onComplete(
                    restoreResult.walletName,
                    keyPair,
                    restoreResult.mnemonicPhrase,
                  );
            }
          },
        );
      default:
        return ImportModeSelectorWidget(
          onComplete: (
            ExecutionContext executionContext,
            ImportModeSelectorContext actionContext,
          ) {
            this._setImportMode(actionContext.mode);
          },
        );
    }
  }
}
