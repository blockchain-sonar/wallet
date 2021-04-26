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

import 'package:flutter/material.dart';
import "package:flutter/widgets.dart" show runApp;
import "package:freemework/freemework.dart" show ExecutionContext;
import 'widgets/business/import_mode_selector.dart'
    show ImportModeSelectorContext, ImportModeSelectorWidget;
import 'widgets/business/enter_wallet_name.dart'
    show EnterWalletNameContext, EnterWalletNameWidget;
import 'widgets/business/restore_by_mnemonic_phrase_widget.dart';
import 'widgets/business/restore_by_private_key_widget.dart'
    show RestoreByPrivateKeyContext, RestoreByPrivateKeyWidget;
import 'widgets/business/restore_mode_selector.dart'
    show RestoreModeSelectorContext, RestoreModeSelectorWidget;
import 'widgets/business/setup_master_password_widget.dart';
import 'widgets/business/show_mnemonic_widget.dart';
import 'widgets/business/unlock.dart' show UnlockContext, UnlockWidget;
import 'widgets/toolchain/dialog_widget.dart' show DialogWidget;

import 'clients/tonclient/tonclient.dart' show TonClient;

void mainTestUnlockWidget() async {
  runApp(UnlockWidget(
    onComplete: (
      ExecutionContext executionContext,
      UnlockContext ctx,
    ) async {
      print("Dialog completed with password: ${ctx.password}");
      await Future<void>.delayed(Duration(seconds: 3));
    },
  ));
}

void mainTestImportModeSelector() async {
  runApp(_buildRootWidget(ImportModeSelectorWidget(
    onComplete: (
      ExecutionContext executionContext,
      ImportModeSelectorContext ctx,
    ) async {
      print("Dialog completed with action: ${ctx.mode}");
      await Future<void>.delayed(Duration(seconds: 3));
    },
  )));
}

void mainTestRestoreModeSelectorWidget() {
  runApp(_buildRootWidget(RestoreModeSelectorWidget(
    onComplete: (
      ExecutionContext executionContext,
      RestoreModeSelectorContext ctx,
    ) async {
      print("Dialog completed with action: ${ctx.mode}");
      await Future<void>.delayed(Duration(seconds: 3));
    },
  )));
}

void mainTestEnterWalletNameWidget() {
  runApp(_buildRootWidget(EnterWalletNameWidget(
    onComplete: (
      ExecutionContext executionContext,
      EnterWalletNameContext ctx,
    ) async {
      print("Dialog completed with wallet name: ${ctx.walletName}");
      await Future<void>.delayed(Duration(seconds: 3));
    },
  )));
}

void mainTestRestoreByPrivateKeyWidget() async {
  final TonClient tonClient = TonClient();
  await tonClient.init(ExecutionContext.EMPTY);

  final String privateKey = await tonClient.generateMnemonicPhrase();

  runApp(_buildRootWidget(RestoreByPrivateKeyWidget(
    onComplete: (
      ExecutionContext executionContext,
      RestoreByPrivateKeyContext ctx,
    ) async {
      print("Dialog completed with private name: ${ctx.privateKey}");
      await Future<void>.delayed(Duration(seconds: 3));
    },
    dataContextInit: RestoreByPrivateKeyContext(privateKey),
  )));
}

Widget _buildRootWidget(Widget home) {
  return MaterialApp(
    title: "Free TON Wallet (Alpha)",
    theme: ThemeData(
      primarySwatch: Colors.blue,
    ),
    home: home,
  );
}

void mainTestSetupMasterPasswordWidget() async {
  runApp(_buildRootWidget(SetupMasterPasswordWidget(
    onComplete: (
      ExecutionContext executionContext,
      SetupMasterPasswordContext ctx,
    ) async {
      print("Dialog completed with password: ${ctx.password}");
      await Future<void>.delayed(Duration(seconds: 3));
    },
  )));
}

void mainTestRestoreByMnemonicPhraseWidget() async {
  final TonClient tonClient = TonClient();
  await tonClient.init(ExecutionContext.EMPTY);

  final String mnemonicPhrase = await tonClient.generateMnemonicPhrase();

  runApp(_buildRootWidget(RestoreByMnemonicPhraseWidget(
    onComplete: (
      ExecutionContext executionContext,
      RestoreByMnemonicPhraseContext ctx,
    ) async {
      print("Dialog completed with private name: ${ctx.mnemonicPhrase}");
      await Future<void>.delayed(Duration(seconds: 3));
    },
    dataContextInit: RestoreByMnemonicPhraseContext(mnemonicPhrase),
  )));
}

void mainTestShowMnemonicWidget() async {
  final TonClient tonClient = TonClient();
  await tonClient.init(ExecutionContext.EMPTY);

  final String mnemonicPhrase = await tonClient.generateMnemonicPhrase();

  runApp(_buildRootWidget(ShowMnemonicWidget(
    onComplete: (
      ExecutionContext executionContext,
      ShowMnemonicContext ctx,
    ) async {
      print("Dialog completed with private name: ${ctx.mnemonicPhrase}");
      await Future<void>.delayed(Duration(seconds: 3));
    },
    dataContextInit: ShowMnemonicContext(mnemonicPhrase),
  )));
}