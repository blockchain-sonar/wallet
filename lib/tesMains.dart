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

import "package:flutter/widgets.dart" show runApp;
import "package:freemework/freemework.dart" show ExecutionContext;
import "widgets/business/enter_wallet_name.dart" show EnterWalletNameContext, EnterWalletNameWidget;
import "widgets/business/restore_by_private_key_widget.dart" show RestoreByPrivateKeyContext, RestoreByPrivateKeyWidget;
import "widgets/business/restore_mode_selector.dart"
    show RestoreModeSelectorContext, RestoreModeSelectorWidget;
import "widgets/business/unlock.dart" show UnlockContext, UnlockWidget;
import "widgets/toolchain/dialog_widget.dart" show DialogWidget;

import "clients/tonclient/tonclient.dart" show TonClient;

void mainTestUnlockWidget() async {
  runApp(DialogWidget<UnlockContext>(
    child: UnlockWidget(),
    onComplete: (
      ExecutionContext executionContext,
      UnlockContext ctx,
    ) async {
      print("Dialog completed with password: ${ctx.password}");
      await Future<void>.delayed(Duration(seconds: 3));
    },
  ));
}

void mainTestRestoreModeSelectorWidget() {
  runApp(DialogWidget<RestoreModeSelectorContext>(
    child: RestoreModeSelectorWidget(),
    onComplete: (
      ExecutionContext executionContext,
      RestoreModeSelectorContext ctx,
    ) async {
      print("Dialog completed with action: ${ctx.action}");
      await Future<void>.delayed(Duration(seconds: 3));
    },
  ));
}

void mainTestEnterWalletNameWidget() {
  runApp(DialogWidget<EnterWalletNameContext>(
    child: EnterWalletNameWidget(),
    onComplete: (
      ExecutionContext executionContext,
      EnterWalletNameContext ctx,
    ) async {
      print("Dialog completed with wallet name: ${ctx.walletName}");
      await Future<void>.delayed(Duration(seconds: 3));
    },
  ));
}

void mainTestRestoreByPrivateKeyWidget() async {
  final TonClient tonClient = TonClient();
  await tonClient.init(ExecutionContext.EMPTY);

  final String privateKey = await tonClient.generateMnemonicPhrase();

  runApp(DialogWidget<RestoreByPrivateKeyContext>(
    child: RestoreByPrivateKeyWidget(),
    onComplete: (
      ExecutionContext executionContext,
      RestoreByPrivateKeyContext ctx,
    ) async {
      print("Dialog completed with private name: ${ctx.privateKey}");
      await Future<void>.delayed(Duration(seconds: 3));
    },
    dataContextInit: RestoreByPrivateKeyContext(privateKey),
  ));
}
