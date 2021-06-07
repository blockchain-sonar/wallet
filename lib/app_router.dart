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

import "dart:async" show Future;
import "dart:convert" show base64Encode;
import "dart:typed_data" show Uint8List;

import "package:flutter/material.dart"
    show Colors, MaterialApp, MaterialPage, ThemeData;
import "package:flutter/src/widgets/navigator.dart"
    show Navigator, NavigatorState, Page, Route;
import "package:flutter/widgets.dart"
    show
        BuildContext,
        Center,
        ChangeNotifier,
        GlobalKey,
        Navigator,
        NavigatorState,
        Page,
        PopNavigatorRouterDelegateMixin,
        RouteInformation,
        RouteInformationParser,
        RouterDelegate,
        StatelessWidget,
        Text,
        UniqueKey,
        ValueKey,
        VoidCallback,
        Widget,
        WidgetBuilder;
import "package:freemework/freemework.dart";
import 'package:freeton_wallet/services/session.dart';

import "adapter/deploy_contract_adapter.dart"
    show DeployContractWidgetApiAdapter;
import "data/key_pair.dart" show KeyPair;
import "data/mnemonic_phrase.dart" show MnemonicPhrase;
import "router/app_route_data.dart";
import "router/crash_page.dart" show CrashPage;
import "router/main_page.dart" show MainPage;
import "router/redirect_page.dart" show RedirectPage;
import "router/settings_nodes_page.dart";
import "router/settings_walletmanager_page.dart" show SettingsWalletManagerPage;
import "services/blockchain/blockchain.dart" show BlockchainServiceFactory;
import "services/sensetive_storage_service.dart" show SensetiveStorageService;
import "services/storage_service.dart" show StorageService;
import "viewmodel/account_view_mode.dart" show AccountViewModel;
import "viewmodel/app_view_model.dart" show AppViewModel;
import "widgets/business/deploy_contract.dart"
    show DeployContractWidget, DeployContractWidgetApi;
import "widgets/business/main.dart" show MainWidgetApi;
import "widgets/business/main_wallets.dart" show DeployContractCallback;
import "widgets/business/setup_master_password.dart"
    show SetupMasterPasswordContext, SetupMasterPasswordWidget;
import "widgets/business/unlock.dart"
    show UnlockContext, UnlockSuccessContext, UnlockWidget;
import "widgets/layout/my_scaffold.dart" show MyScaffold;

import "wizzard_key.dart" show WizzardWalletWidget;

class AppRouterWidget extends StatelessWidget {
  final _AppRouterDelegate _routerDelegate;
  final _AppRouteInformationParser _routeInformationParser;

  AppRouterWidget(
    final BlockchainServiceFactory blockchainServiceFactory,
    // final JobService jobService,
    final SensetiveStorageService sensetiveStorageService,
    final StorageService storageService,
    final SessionService sessionService,
  )   : this._routerDelegate = _AppRouterDelegate(
          blockchainServiceFactory,
          // jobService,
          sensetiveStorageService,
          storageService,
          sessionService,
        ),
        this._routeInformationParser = _AppRouteInformationParser();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: "Free TON Wallet (Beta)",
      theme: ThemeData(
        primarySwatch: Colors.lightBlue,
      ),
      routerDelegate: this._routerDelegate,
      routeInformationParser: this._routeInformationParser,
    );
  }
}

class _AppRouteInformationParser extends RouteInformationParser<AppRouteData> {
  static Uri _parseLocation(String? location) {
    if (location == null) {
      return Uri.parse("/");
    }
    return Uri.parse(location);
  }

  @override
  Future<AppRouteData> parseRouteInformation(
      RouteInformation routeInformation) async {
    final Uri routeUri = _parseLocation(routeInformation.location);
    final AppRouteData configuration = AppRouteData.fromUrl(routeUri);
    return configuration;
  }

  @override
  RouteInformation restoreRouteInformation(AppRouteData data) {
    final String location = data.location;
    final String? state = data.state;

    return RouteInformation(location: location, state: state);
  }
}

class _AppRouterDelegate extends RouterDelegate<AppRouteData>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<AppRouteData> {
  final GlobalKey<NavigatorState> _navigatorKey;
  // final JobService _jobService;
  final BlockchainServiceFactory _blockchainServiceFactory;
  final SensetiveStorageService _sensetiveStorageService;
  final StorageService _storageService;
  final SessionService _sessionService;

  AppViewModel? _appViewModel;
  AppRouteData _currentConfiguration;

  _AppRouterDelegate(
    this._blockchainServiceFactory,
    // this._jobService,
    this._sensetiveStorageService,
    this._storageService,
    this._sessionService,
  )   : this._navigatorKey = GlobalKey<NavigatorState>(),
        this._currentConfiguration = AppRouteDataMain.home(),
        this._appViewModel = null;

  @override
  GlobalKey<NavigatorState> get navigatorKey => this._navigatorKey;

  @override
  AppRouteData? get currentConfiguration {
    return this._currentConfiguration;
  }

  @override
  Widget build(BuildContext context) {
    final AppRouteData currentConfiguration = this._currentConfiguration;

    List<Page<dynamic>> pagesStack;

    print(this._currentConfiguration);

    final AppViewModel? appViewModel = this._appViewModel;

    print(appViewModel);

    final SensetiveStorageService sensetiveStorageService =
        this._sensetiveStorageService;

    if (appViewModel != null) {
      if (currentConfiguration is AppRouteDataCrash)
        pagesStack = _crashPagesStack(currentConfiguration);
      else if (currentConfiguration is AppRouteDataMain)
        pagesStack = _mainPagesStack(
          currentConfiguration,
          context,
          appViewModel,
          appViewModel.encryptionKey,
        );
      else
        pagesStack = _unknownPagesStack(currentConfiguration);
    } else {
      if (sensetiveStorageService.isInitialized) {
        if (currentConfiguration is AppRouterDataSignin) {
          pagesStack = _signinPagesStack(
            currentConfiguration,
            context,
            this._sensetiveStorageService,
          );
        } else {
          pagesStack = this._redirectPagesStack(AppRouterDataSignin.PATH);
        }
      } else {
        pagesStack = _wizzardMasterPasswordPagesStack(
          context,
          sensetiveStorageService,
          this._storageService,
        );
      }
    }

    print(pagesStack);

    return Navigator(
      key: navigatorKey,
      // transitionDelegate: transitionDelegate,
      pages: pagesStack,
      onPopPage: (Route<dynamic> route, dynamic result) {
        if (!route.didPop(result)) {
          return false;
        }
        // print("onPopPage");
        if (pagesStack.length > 1) {
          if (this._currentConfiguration
                  is AppRouteDataMainWalletsDeployContract ||
              this._currentConfiguration is AppRouteDataMainWalletsNew ||
              this._currentConfiguration is AppRouteDataMainWalletsSendMoney) {
            this._currentConfiguration = AppRouteDataMainWallets();
          }

          if (this._currentConfiguration is AppRouteDataMainSettings &&
              this.currentConfiguration.runtimeType !=
                  AppRouteDataMainSettings) {
            this._currentConfiguration = AppRouteDataMainSettings();
          }
        } else {
          this._currentConfiguration = AppRouterDataUnknown();
        }
        notifyListeners();
        return true;
      },
    );
  }

  @override
  Future<void> setNewRoutePath(AppRouteData configuration) async {
    // print("_AppRouterDelegate#setNewRoutePath: ${configuration}");
    this._currentConfiguration = configuration;
  }

  MaterialPage<WizzardWalletWidget> _buildWizzardWalletPage(
    final AppViewModel appViewModel,
    final Uint8List encryptionKey,
  ) {
    return MaterialPage<WizzardWalletWidget>(
      key: ValueKey<Object>(WizzardWalletWidget),
      child: WizzardWalletWidget(
        appViewModel.blockchainService,
        onComplete: (
          String keyName,
          KeyPair keyPair,
          MnemonicPhrase? mnemonicPhrase,
        ) async {
          await appViewModel.addKeyPair(
            encryptionKey,
            keyName,
            keyPair.public,
            keyPair.secret,
            mnemonicPhrase?.sentence,
          );

          this._currentConfiguration = AppRouteDataMainWallets();
          this.notifyListeners();
          // this._jobService.registerAccountsActivationJob(
          //     keypairBundle); // push keypairBundle to account activation
        },
      ),
    );
  }

  List<Page<dynamic>> _crashPagesStack(AppRouteDataCrash configuration) =>
      <Page<dynamic>>[CrashPage()];

  List<Page<dynamic>> _mainPagesStack(
    final AppRouteDataMain configuration,
    final BuildContext context,
    final AppViewModel appViewModel,
    final Uint8List encryptionKey,
  ) {
    final void Function() onSelectHome = () {
      this._currentConfiguration = AppRouteDataMain.home();
      this.notifyListeners();
    };
    final void Function() onSelectWallets = () {
      this._currentConfiguration = AppRouteDataMainWallets();
      this.notifyListeners();
    };
    final void Function() onAddNewKey = () {
      this._currentConfiguration = AppRouteDataMainWalletsNew();
      this.notifyListeners();
    };
    final DeployContractCallback onDeployContract =
        (final AccountViewModel account) {
      this._currentConfiguration =
          AppRouteDataMainWalletsDeployContract(account.blockchainAddress);
      this.notifyListeners();
    };
    final DeployContractCallback onSendMoney =
        (final AccountViewModel account) {
      this._currentConfiguration =
          AppRouteDataMainWalletsSendMoney(account.blockchainAddress);
      this.notifyListeners();
    };
    final void Function() onSelectSettings = () {
      this._currentConfiguration = AppRouteDataMainSettings();
      this.notifyListeners();
    };
    final VoidCallback onOpenSettingsNodes = () {
      this._currentConfiguration = AppRouteDataMainSettingsNodes();
      this.notifyListeners();
    };
    final VoidCallback onOpenSettingsWalletManager = () {
      this._currentConfiguration = AppRouteDataMainSettingsWalletManager();
      this.notifyListeners();
    };

    //final MainTab selectedTab = configuration.selectedTab;

    final AppRouteData currentConfiguration = this._currentConfiguration;
    return <Page<dynamic>>[
      MainPage(
        configuration,
        MainWidgetApi(
          appViewModel,
          // this._storageService,
          // jobService: this._jobService,
          onSelectHome: onSelectHome,
          onSelectWallets: onSelectWallets,
          onSelectSettings: onSelectSettings,
          onAddNewKey: onAddNewKey,
          onDeployContract: onDeployContract,
          onSendMoney: onSendMoney,
          onOpenSettingsNodes: onOpenSettingsNodes,
          onOpenSettingsWalletManager: onOpenSettingsWalletManager,
        ),
      ),
      if (currentConfiguration is AppRouteDataMainWalletsNew)
        _buildWizzardWalletPage(
          appViewModel,
          encryptionKey,
        )
      else if (currentConfiguration is AppRouteDataMainWalletsDeployContract)
        ..._deployContractPagesStack(
          appViewModel,
          currentConfiguration.accountAddress,
        )
      else if (currentConfiguration is AppRouteDataMainWalletsSendMoney)
        ..._sendMoneyPagesStack(
          appViewModel,
          currentConfiguration.accountAddress,
        ),
      if (currentConfiguration is AppRouteDataMainSettingsNodes)
        SettingsNodesPage(
          appViewModel,
        ),
      if (currentConfiguration is AppRouteDataMainSettingsWalletManager)
        SettingsWalletManagerPage(
          appViewModel,
        ),
    ];
  }

  List<Page<dynamic>> _signinPagesStack(
    AppRouterDataSignin configuration,
    BuildContext context,
    SensetiveStorageService sensetiveStorageService,
  ) {
    assert(this._appViewModel == null);
    assert(sensetiveStorageService.isInitialized);

    return <Page<dynamic>>[
      MaterialPage<UnlockWidget>(
        key: UniqueKey(),
        child: UnlockWidget(
          this._blockchainServiceFactory,
          this._sensetiveStorageService,
          this._storageService,
          this._sessionService,
          dataContextInit: UnlockContext("", configuration.errorMessage),
          onComplete: (
            ExecutionContext executionContext,
            UnlockContext ctx,
          ) async {
            assert(this._appViewModel == null);
            assert(sensetiveStorageService.isInitialized);

            try {
              if (ctx is UnlockSuccessContext) {
                this._appViewModel = ctx.appViewModel;
                this._currentConfiguration = AppRouteDataMain.home();
              } else {
                final String masterPassword = ctx.password;
                final Uint8List encryptionKey = await sensetiveStorageService
                    .derivateEncryptionKey(masterPassword);

                final AppViewModel newAppViewModel = AppViewModel(
                  this._storageService,
                  this._sensetiveStorageService,
                  this._blockchainServiceFactory,
                );

                await newAppViewModel.initialize(encryptionKey);

                final String encryptionKeyStr = base64Encode(encryptionKey);
                await this._sessionService.setValue(
                      SessionService.KEY__ENCRYPTION_KEY,
                      encryptionKeyStr,
                    );

                this._appViewModel = newAppViewModel;
                this._currentConfiguration = AppRouteDataMain.home();
              }
            } catch (e) {
              final FreemeworkException err =
                  FreemeworkException.wrapIfNeeded(e);
              print(err.message);
              print(err.stackTrace?.toString());
              this._currentConfiguration = AppRouterDataSignin(
                "Cannot unlock. Check your password and try again.",
              );
            }

            this.notifyListeners();
          },
        ),
      )
    ];
  }

  List<Page<dynamic>> _unknownPagesStack(dynamic tbd) => <Page<dynamic>>[
        MaterialPage<_UnknownScreen>(
          key: ValueKey<Object>(_UnknownScreen),
          child: _UnknownScreen(),
        )
      ];

  List<Page<dynamic>> _wizzardMasterPasswordPagesStack(
    final BuildContext context,
    final SensetiveStorageService sensetiveStorageService,
    final StorageService storageService,
  ) {
    assert(this._appViewModel == null);
    assert(!sensetiveStorageService.isInitialized);

    return <Page<dynamic>>[
      MaterialPage<SetupMasterPasswordWidget>(
        key: ValueKey<Object>(SetupMasterPasswordWidget),
        child: SetupMasterPasswordWidget(
          onComplete: (
            ExecutionContext executionContext,
            SetupMasterPasswordContext ctx,
          ) async {
            assert(this._appViewModel == null);
            assert(!sensetiveStorageService.isInitialized);

            final String masterPassword = ctx.password;

            try {
              await storageService.wipe();
              final Uint8List encryptionKey =
                  await sensetiveStorageService.wipe(masterPassword);

              final AppViewModel newAppViewModel = AppViewModel(
                this._storageService,
                this._sensetiveStorageService,
                this._blockchainServiceFactory,
              );
              await newAppViewModel.initialize(encryptionKey);

              final String encryptionKeyStr = base64Encode(encryptionKey);
              await this._sessionService.setValue(
                    SessionService.KEY__ENCRYPTION_KEY,
                    encryptionKeyStr,
                  );

              this._appViewModel = newAppViewModel;
            } catch (e) {
              final FreemeworkException err =
                  FreemeworkException.wrapIfNeeded(e);
              print(err);
              this._currentConfiguration = AppRouteDataCrash(/* err */);
            }

            this.notifyListeners();
          },
        ),
      )
    ];
  }

  List<Page<dynamic>> _deployContractPagesStack(
    final AppViewModel appViewModel,
    final String accountAddress,
  ) {
    final DeployContractWidgetApi widgetApi = DeployContractWidgetApiAdapter(
      appViewModel,
      accountAddress,
    );

    return <Page<dynamic>>[
      MaterialPage<DeployContractWidget>(
        key: ValueKey<Object>(DeployContractWidget),
        child: DeployContractWidget(widgetApi),
      )
    ];
  }

  List<Page<dynamic>> _sendMoneyPagesStack(
    final AppViewModel appViewModel,
    final String sourceAccountAddress,
  ) {
    return this._redirectPagesStack(AppRouteDataCrash.PATH);

    // final List<DataAccount> accounts = appViewModel.keypairBundles
    //     .expand((KeypairBundle keypairBundle) => keypairBundle.accounts.values)
    //     .toList();
    // final DataAccount account = accounts.singleWhere(
    //     (DataAccount account) => account.blockchainAddress == sourceAccountAddress);

    // final SendMoneyWidgetApi widgetApi = SendMoneyWidgetApiAdapter(
    //   account,
    //   appViewModel,
    //   blockchainService,
    //   jobService,
    // );

    // return <Page<dynamic>>[
    //   MaterialPage<SendMoneyWidget>(
    //     key: ValueKey<Object>(SendMoneyWidget),
    //     child: SendMoneyWidget(widgetApi),
    //   )
    // ];
  }

  List<Page<dynamic>> _redirectPagesStack(String location, [String? state]) {
    return <Page<dynamic>>[
      RedirectPage(
        (String location, String? state) {
          this._currentConfiguration =
              AppRouteData.fromUrl(Uri.parse(location));
          this.notifyListeners();
        },
        location,
        state,
      )
    ];
  }
}

class _UnknownScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      body: Center(
        child: Text("404!"),
      ),
    );
  }
}
