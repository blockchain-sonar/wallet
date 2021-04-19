import "package:flutter/widgets.dart";
import "package:freemework/freemework.dart" show ExecutionContext;
import 'widgets/business/enter_wallet_name.dart';
import 'widgets/business/import_mode_selector.dart'
    show ImportMode, ImportModeSelectorContext, ImportModeSelectorWidget;

class WizzardKeyNewWidget extends StatefulWidget {
  @override
  _WizzardKeyNewWidgetState createState() => _WizzardKeyNewWidgetState();
}

class _WizzardKeyNewWidgetState extends State<WizzardKeyNewWidget> {
  String? _keyName;
  ImportMode? _importMode;

  _WizzardKeyNewWidgetState()
      : this._importMode = null,
        this._keyName = null;

  void _setImportMode(ImportMode mode) {
    this.setState(() {
      this._importMode = mode;
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
      return Text("Creating key '${keyName}'...");
    }
  }
}
