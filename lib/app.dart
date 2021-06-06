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

import "package:flutter/widgets.dart"
    show
        AsyncSnapshot,
        BuildContext,
        Center,
        ConnectionState,
        FutureBuilder,
        Key,
        ObjectKey,
        StatelessWidget,
        Text,
        ValueKey,
        Widget;
import 'package:freeton_wallet/services/sensetive_storage_service.dart';
import 'package:freeton_wallet/services/session.dart';
import 'package:freeton_wallet/services/storage_service.dart';

import "widgets/business/crash.dart" show CrashStandalone;
import "widgets/business/splash.dart" show SplashStandalone;
import "package:provider/provider.dart" show ChangeNotifierProvider, Provider;

import "app_router.dart" show AppRouterWidget;
import "services/crypto_service.dart" show CryptoService;
import "services/service_factory.dart" show ServiceFactory;
import "services/encrypted_db_service.dart" show EncryptedDbService;
import "services/blockchain/blockchain.dart"
    show BlockchainService, BlockchainServiceFactory;
import "services/job.dart" show JobService;
import "viewmodel/app_view_model.dart" show AppViewModel;

class App extends StatelessWidget {
  App(this.serviceFactory)
      : this._serviceBundle = _ServicesBundle(serviceFactory) {
    print("Create App root widget");
  }

  final ServiceFactory serviceFactory;
  final _ServicesBundle _serviceBundle;

  @override
  Widget build(BuildContext context) {
    print("Build App root widget");

    return Provider<ServiceFactory>.value(
      value: serviceFactory,
      child: FutureBuilder<_ServicesBundle>(
        key: ValueKey<App>(this),
        future: this._serviceBundle.init(),
        builder: (
          BuildContext context,
          AsyncSnapshot<_ServicesBundle?> snapshot,
        ) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SplashStandalone();
          } else if (snapshot.hasError) {
            return CrashStandalone("Error: ${snapshot.error}");
          }
          final _ServicesBundle? servicesBundle = snapshot.data;
          if (servicesBundle == null) {
            return Center(child: Text("Error: servicesBundle is null"));
          }

          return AppRouterWidget(
            servicesBundle.blockchainServiceFactory,
            // servicesBundle.jobService,
            servicesBundle.sensetiveStorageService,
            servicesBundle.storageService,
            servicesBundle.sessionService,
          );
        },
      ),
    );
  }
}

class _ServicesBundle {
  final ServiceFactory _serviceFactory;
  Future<_ServicesBundle>? _initFuture;
  CryptoService? _cryptoService;
  SensetiveStorageService? _sensetiveStorageService;
  StorageService? _storageService;
  SessionService? _sessionService;
  BlockchainServiceFactory? _blockchainServiceFactory;
  // JobService? _jobService;

  CryptoService get cryptoService {
    assert(this._cryptoService != null);
    return this._cryptoService!;
  }

  BlockchainServiceFactory get blockchainServiceFactory {
    assert(this._blockchainServiceFactory != null);
    return this._blockchainServiceFactory!;
  }

  SensetiveStorageService get sensetiveStorageService {
    assert(this._sensetiveStorageService != null);
    return this._sensetiveStorageService!;
  }

  StorageService get storageService {
    assert(this._storageService != null);
    return this._storageService!;
  }

  SessionService get sessionService {
    assert(this._sessionService != null);
    return this._sessionService!;
  }

  // JobService get jobService {
  //   assert(this._jobService != null);
  //   return this._jobService!;
  // }

  Future<_ServicesBundle> init() {
    final Future<_ServicesBundle>? initFuture = this._initFuture;
    if (initFuture != null) {
      return initFuture;
    }
    return this._initFuture = this._init();
  }

  _ServicesBundle(this._serviceFactory)
      : this._cryptoService = null,
        this._blockchainServiceFactory = null {
    print("Create _ServicesBundle");
  }

  Future<_ServicesBundle> _init() async {
    if (this.__initializer == null) {
      this.__initializer = this.__init();
    }
    return this.__initializer!;
  }

  Future<_ServicesBundle>? __initializer;
  Future<_ServicesBundle> __init() async {
    final CryptoService cryptoService =
        await this._serviceFactory.createCryptoService();
    final BlockchainServiceFactory blockchainServiceFactory =
        await this._serviceFactory.createBlockchainServiceFactory();
    // final JobService jobService = await this
    //     ._serviceFactory
    //     .createJobService(blockchainService, encryptedDbService);
    final SensetiveStorageService sensetiveStorageService =
        this._serviceFactory.createSensetiveStorageService(cryptoService);
    final StorageService storageService =
        this._serviceFactory.createStorageService();
    final SessionService sessionService =
        await this._serviceFactory.createSessionService();

    this._cryptoService = cryptoService;
    this._blockchainServiceFactory = blockchainServiceFactory;
    // this._jobService = jobService;
    this._sensetiveStorageService = sensetiveStorageService;
    this._storageService = storageService;
    this._sessionService = sessionService;

    return this;
  }
}
