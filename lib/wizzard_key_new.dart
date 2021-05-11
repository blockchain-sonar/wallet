import "package:flutter/foundation.dart" show listEquals;
import "package:flutter/widgets.dart";
import "package:freemework/freemework.dart" show ExecutionContext;

import "data/mnemonic_phrase.dart" show MnemonicPhrase, MnemonicPhraseLength;

import "services/wallet_service.dart" show WalletService;
import "widgets/business/show_mnemonic_widget.dart"
    show ShowMnemonicContext, ShowMnemonicWidget;
import "widgets/business/confirm_mnemonic.dart"
    show ConfirmMnemonicContext, ConfirmMnemonicWidget;
import "widgets/business/enter_wallet_name.dart"
    show EnterWalletNameContext, EnterWalletNameWidget;

class WizzardWalletNewWidget extends StatefulWidget {
  final Future<void> Function(String walletName, MnemonicPhrase mnemonicPhrase)
      onComplete;
  final WalletService _walletService;

  WizzardWalletNewWidget(
    this._walletService, {
    required this.onComplete,
  });

  @override
  _WizzardWalletNewState createState() => _WizzardWalletNewState();
}

class _WizzardWalletNewState extends State<WizzardWalletNewWidget> {
  String? _walletName;
  MnemonicPhrase? _mnemonicPhrase;
  bool _isMnemonicPhraseSeen;

  _WizzardWalletNewState()
      : this._walletName = null,
        _mnemonicPhrase = null,
        _isMnemonicPhraseSeen = false;

  @override
  Widget build(BuildContext context) {
    final String? walletName = this._walletName;
    final MnemonicPhrase? mnemonicPhrase = this._mnemonicPhrase;

    if (walletName == null || mnemonicPhrase == null) {
      return EnterWalletNameWidget(
        onComplete: (
          ExecutionContext executionContext,
          EnterWalletNameContext actionContext,
        ) async {
          final MnemonicPhrase mnemonicPhrase = await this
              .widget
              ._walletService
              .generateMnemonicPhrase(MnemonicPhraseLength.SHORT);
          this.setState(() {
            this._walletName = actionContext.walletName;
            this._mnemonicPhrase = mnemonicPhrase;
          });
        },
      );
    } else if (!this._isMnemonicPhraseSeen) {
      return ShowMnemonicWidget(
        dataContextInit:
            ShowMnemonicContext(mnemonicPhrase.words.toList(growable: false)),
        onComplete: (
          ExecutionContext executionContext,
          ShowMnemonicContext actionContext,
        ) {
          this.setState(() {
            this._isMnemonicPhraseSeen = true;
          });
        },
      );
    } else {
      return ConfirmMnemonicWidget(
        dataContextInit: ConfirmMnemonicContext(
            mnemonicPhrase.words.toList(growable: false)),
        onComplete: (
          ExecutionContext executionContext,
          ConfirmMnemonicContext actionContext,
        ) async {
          if (listEquals(
            mnemonicPhrase.words,
            actionContext.mnemonicPhraseWords,
          )) {
            await this.widget.onComplete(walletName, mnemonicPhrase);
          }
        },
      );
    }
  }
}
