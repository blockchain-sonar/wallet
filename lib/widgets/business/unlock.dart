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

import "dart:typed_data" show Uint8List;

import "package:flutter/material.dart"
    show
        Colors,
        FloatingActionButton,
        Icons,
        InputDecoration,
        CircularProgressIndicator,
        OutlineInputBorder,
        TextField;
import "package:flutter/widgets.dart"
    show
        BuildContext,
        Center,
        Column,
        EdgeInsets,
        Expanded,
        FontWeight,
        Icon,
        Key,
        Padding,
        State,
        StatefulWidget,
        StatelessWidget,
        Text,
        TextEditingController,
        TextStyle,
        Widget,
        WidgetBuilder;
import 'package:freemework/ExecutionContext.dart';

import "package:freemework_cancellation/freemework_cancellation.dart"
    show CancellationTokenSource;
import 'package:freeton_wallet/services/blockchain/blockchain.dart';
import '../../services/sensetive_storage_service.dart';
import '../../services/storage_service.dart';
import '../reusable/app_view_model_initializer.dart';

import "../../services/session.dart" show SessionService;
import "../../viewmodel/app_view_model.dart" show AppViewModel;

import "../layout/my_scaffold.dart" show MyScaffold;
import "../reusable/button_widget.dart" show FWCancelFloatingActionButton;
import "../reusable/encryption_key_loader.dart" show EncryptionKeyLoader;
import "../reusable/logo_widget.dart" show FWLogo128Widget;
import "../toolchain/dialog_widget.dart"
    show
        DialogActionContentWidget,
        DialogCallback,
        DialogHostCallback,
        DialogWidget;

class UnlockContext {
  final String password;
  final String? errorMessage;

  UnlockContext(this.password, this.errorMessage);
}

class UnlockSuccessContext implements UnlockContext {
  final AppViewModel appViewModel;

  UnlockSuccessContext(this.appViewModel);

  @override
  String get password => throw StateError("Use appViewModel instead");

  @override
  String? get errorMessage => null;
}

class UnlockWidget extends StatelessWidget {
  final BlockchainServiceFactory _blockchainServiceFactory;
  final SensetiveStorageService _sensetiveStorageService;
  final StorageService _storageService;
  final SessionService _sessionService;
  final UnlockContext? _dataContextInit;
  final DialogHostCallback<UnlockContext> _onComplete;

  UnlockWidget(
    this._blockchainServiceFactory,
    this._sensetiveStorageService,
    this._storageService,
    this._sessionService, {
    required DialogHostCallback<UnlockContext> onComplete,
    UnlockContext? dataContextInit,
  })  : this._onComplete = onComplete,
        this._dataContextInit = dataContextInit;

  Widget unlockWidgetBuilder(BuildContext context) =>
      DialogWidget<UnlockContext>(
        onComplete: this._onComplete,
        dataContextInit: this._dataContextInit,
        child: _UnlockWidget(),
      );

  @override
  Widget build(BuildContext context) {
    final UnlockContext? dataContextInit = this._dataContextInit;
    if (dataContextInit != null && dataContextInit.errorMessage != null) {
      return unlockWidgetBuilder(context);
    }

    return EncryptionKeyLoader(
      this._sessionService,
      builder: (
        _, [
        Uint8List? sessionEncryptionKey,
      ]) {
        if (sessionEncryptionKey != null) {
          final AppViewModel newAppViewModel = AppViewModel(
            this._storageService,
            this._sensetiveStorageService,
            this._blockchainServiceFactory,
          );

          return AppViewModelInitializer(
            newAppViewModel,
            sessionEncryptionKey,
            onSuccess: () {
              //
              this._onComplete(
                ExecutionContext.EMPTY,
                UnlockSuccessContext(newAppViewModel),
              );
            },
            failureBuilder: unlockWidgetBuilder,
          );
        }

        return unlockWidgetBuilder(context);
      },
    );
  }
}

class _UnlockWidget extends DialogActionContentWidget<UnlockContext> {
  @override
  Widget buildActive(
    BuildContext context, {
    required DialogCallback<UnlockContext> onComplete,
  }) =>
      _UnlockActiveWidget(onComplete);

  @override
  Widget buildBusy(
    BuildContext context, {
    required CancellationTokenSource cancellationTokenSource,
    Widget? feedbackInfoWidget,
  }) {
    return _buildContainer(
        Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: CircularProgressIndicator(
                semanticsLabel: "Circular progress indicator",
              ),
            ),
            if (feedbackInfoWidget != null)
              Expanded(
                child: feedbackInfoWidget,
              )
          ],
        ),
        floatingActionButton: FWCancelFloatingActionButton(
          onPressed: cancellationTokenSource.cancel,
        ));
  }

  static Widget _buildContainer(
    Widget body, {
    required FloatingActionButton floatingActionButton,
  }) {
    return MyScaffold(
      body: Center(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: FWLogo128Widget(),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                "Welcome back",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: Colors.blueGrey,
                ),
              ),
            ),
            Expanded(
              child: body,
            )
          ],
        ),
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}

class _UnlockActiveWidget extends StatefulWidget {
  final DialogCallback<UnlockContext> onComplete;
  _UnlockActiveWidget(
    this.onComplete, {
    Key? key,
  }) : super(key: key);

  @override
  _UnlockActiveWidgetState createState() => _UnlockActiveWidgetState();
}

class _UnlockActiveWidgetState extends State<_UnlockActiveWidget> {
  final TextEditingController _passwordTextEditingController =
      TextEditingController();

  @override
  void initState() {
    final UnlockContext? dataContextInit =
        DialogWidget.of<UnlockContext>(this.context).dataContextInit;
    if (dataContextInit != null) {
      this._passwordTextEditingController.text = dataContextInit.password;
    }

    super.initState();
  }

  @override
  void dispose() {
    this._passwordTextEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final UnlockContext? dataContextInit =
        DialogWidget.of<UnlockContext>(this.context).dataContextInit;
    if (dataContextInit != null) {
      this._passwordTextEditingController.text = dataContextInit.password;
    }

    final String? errorMessage =
        dataContextInit != null ? dataContextInit.errorMessage : null;

    return _UnlockWidget._buildContainer(
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextField(
                  controller: _passwordTextEditingController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Master Password",
                  ),
                  obscureText: true,
                ),
              ),
              if (errorMessage != null)
                Text(
                  errorMessage,
                  style: TextStyle(
                    color: Colors.red,
                  ),
                ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            widget.onComplete(
              UnlockContext(
                this._passwordTextEditingController.text,
                null,
              ),
            );
          },
          tooltip: "Continue",
          child: Icon(Icons.login),
        ));
  }
}
