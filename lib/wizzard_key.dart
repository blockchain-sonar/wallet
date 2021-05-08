import "package:flutter/widgets.dart";
import "package:freemework/freemework.dart" show ExecutionContext;

import "data/key_pair.dart" show KeyPair;
import "data/mnemonic_phrase.dart" show MnemonicPhrase;
import "services/wallet_service.dart" show WalletService;
import "wizzard_key_new.dart" show WizzardWalletNewWidget;
import "wizzard_key_restore.dart" show WizzardKeyRestoreWidget;
import "widgets/business/import_mode_selector.dart"
    show ImportMode, ImportModeSelectorContext, ImportModeSelectorWidget;

typedef _CompleteCallback = Future<void> Function(
  String walletName,
  KeyPair keyPair,
  MnemonicPhrase? mnemonicPhrase,
);

class WizzardKeyWidget extends StatefulWidget {
  final WalletService _walletService;
  final _CompleteCallback _onComplete;

  WizzardKeyWidget(
    this._walletService, {
    required _CompleteCallback onComplete,
  }) : this._onComplete = onComplete;

  @override
  _WizzardKeyWidgetState createState() => _WizzardKeyWidgetState();
}

class _WizzardKeyWidgetState extends State<WizzardKeyWidget> {
  ImportMode? _importMode;

  _WizzardKeyWidgetState() : this._importMode = null;

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
          this.widget._walletService,
          onComplete: (String walletName, MnemonicPhrase mnemonicPhrase) async {
            await Future<void>.delayed(Duration(seconds: 1));
            final KeyPair keyPair =
                await this.widget._walletService.deriveKeyPair(mnemonicPhrase);
            await this.widget._onComplete(walletName, keyPair, mnemonicPhrase);
          },
        );
      case ImportMode.RESTORE:
        return WizzardKeyRestoreWidget();
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
