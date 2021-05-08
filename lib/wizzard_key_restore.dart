import "package:flutter/widgets.dart";
import "package:freemework/freemework.dart" show ExecutionContext;
import 'package:freeton_wallet/widgets/business/enter_wallet_name.dart';
import 'package:freeton_wallet/widgets/business/restore_by_private_key.dart';
import 'package:freeton_wallet/widgets/business/restore_mode_selector.dart';
import 'widgets/business/import_mode_selector.dart'
    show ImportMode, ImportModeSelectorContext, ImportModeSelectorWidget;

class WizzardKeyRestoreWidget extends StatefulWidget {
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
          this._setKeyName(actionContext.walletName);
        },
      );
    } else {
      switch (this._restoreMode) {
        case RestoreMode.MNEMONIC:
          return RestoreByPrivateKeyWidget(
            onComplete: (
              ExecutionContext executionContext,
              RestoreByPrivateKeyContext actionContext,
            ) {},
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
