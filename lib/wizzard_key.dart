import "package:flutter/widgets.dart";
import "package:freemework/freemework.dart" show ExecutionContext;

import "wizzard_key_new.dart" show WizzardKeyNewWidget;
import "wizzard_key_restore.dart" show WizzardKeyRestoreWidget;
import "widgets/business/import_mode_selector.dart"
    show ImportMode, ImportModeSelectorContext, ImportModeSelectorWidget;

class WizzardKeyWidget extends StatefulWidget {
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
        return WizzardKeyNewWidget();
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
