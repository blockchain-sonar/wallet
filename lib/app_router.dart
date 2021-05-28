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

import "dart:async" show Future;
import "dart:typed_data" show Uint8List;

import "package:flutter/material.dart"
    show Colors, MaterialApp, MaterialPage, ThemeData;
import "package:flutter/src/widgets/framework.dart";
import "package:flutter/src/widgets/navigator.dart";
import "package:flutter/widgets.dart"
    show
        Alignment,
        BoxConstraints,
        BuildContext,
        Center,
        ChangeNotifier,
        Container,
        GlobalKey,
        MainAxisAlignment,
        MainAxisSize,
        Navigator,
        NavigatorState,
        Page,
        PageRouteBuilder,
        PopNavigatorRouterDelegateMixin,
        RouteInformation,
        RouteInformationParser,
        RouteTransitionRecord,
        RouterDelegate,
        Row,
        StatefulWidget,
        StatelessWidget,
        StreamBuilder,
        Text,
        TransitionDelegate,
        ValueKey,
        Widget;
import "package:freemework/freemework.dart";
import 'package:freeton_wallet/widgets/business/deploy_contract.dart';
import 'package:freeton_wallet/widgets/business/send_modey.dart';
import 'package:freeton_wallet/widgets/layout/my_scaffold.dart';
import 'adapter/deploy_contract_adapter.dart';
import 'adapter/send_money_dapter.dart';
import "router/main_page.dart" show MainPage;
import "router/redirect_page.dart" show RedirectPage;
import "widgets/business/main_tab.dart" show MainTab;
import "data/key_pair.dart" show KeyPair;
import "data/mnemonic_phrase.dart" show MnemonicPhrase;
import "router/app_route_data.dart";
import "router/crash_page.dart" show CrashPage;
import "services/blockchain/blockchain.dart"
    show BlockchainService, SmartContract;
import "states/app_state.dart" show AppState;
import "package:provider/provider.dart" show Consumer;

import "services/encrypted_db_service.dart"
    show
        Account,
        DataSet,
        EncryptedDbService,
        KeypairBundle,
        KeypairBundlePlain;
import "services/job.dart" show JobService;
import "widgets/business/main_wallets.dart" show DeployContractCallback;
import "widgets/business/select_smart_contract.dart"
    show SelectSmartContractWidget;
import "widgets/business/setup_master_password.dart"
    show SetupMasterPasswordContext, SetupMasterPasswordWidget;
import "widgets/business/unlock.dart" show UnlockContext, UnlockWidget;
import "wizzard_key.dart" show WizzardWalletWidget;

class AppRouterWidget extends StatelessWidget {
  final _AppRouterDelegate _routerDelegate;
  final _AppRouteInformationParser _routeInformationParser;

  AppRouterWidget(
    final EncryptedDbService encryptedDbService,
    final BlockchainService blockchainService,
    final JobService jobService,
  )   : this._routerDelegate = _AppRouterDelegate(
            encryptedDbService, blockchainService, jobService),
        this._routeInformationParser = _AppRouteInformationParser();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: "Free TON Wallet (Alpha)",
      theme: ThemeData(
        primarySwatch: Colors.blue,
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
  final EncryptedDbService _encryptedDbService;
  final JobService _jobService;
  final BlockchainService _blockchainService;

  AppRouteData _currentConfiguration;

  _AppRouterDelegate(
      this._encryptedDbService, this._blockchainService, this._jobService)
      : this._navigatorKey = GlobalKey<NavigatorState>(),
        this._currentConfiguration = AppRouteDataMain.home();

  @override
  GlobalKey<NavigatorState> get navigatorKey => this._navigatorKey;

  @override
  AppRouteData? get currentConfiguration {
    return this._currentConfiguration;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(builder: (
      BuildContext consumerContext,
      AppState appState,
      Widget? child,
    ) {
      final AppRouteData currentConfiguration = this._currentConfiguration;

      List<Page<dynamic>> pagesStack;

      print(this._currentConfiguration);

      if (currentConfiguration is AppRouteDataCrash)
        pagesStack = _crashPagesStack(currentConfiguration);
      else if (currentConfiguration is AppRouteDataNewbeWizzard)
        pagesStack = _wizzardNewbePagesStack(
          currentConfiguration,
          consumerContext,
          appState,
          this._encryptedDbService,
          this._blockchainService,
        );
      else if (currentConfiguration is AppRouteDataMain)
        pagesStack = _mainPagesStack(
          currentConfiguration,
          consumerContext,
          appState,
          this._encryptedDbService,
          this._blockchainService,
        );
      else if (currentConfiguration is AppRouterDataSignin)
        pagesStack = _signinPagesStack(
          currentConfiguration,
          consumerContext,
          appState,
          this._encryptedDbService,
        );
      else if (currentConfiguration is AppRouterDataUnknown)
        pagesStack = _unknownPagesStack(currentConfiguration);
      else
        pagesStack = _unknownPagesStack(currentConfiguration);

      print(pagesStack);

      return Navigator(
        key: navigatorKey,
        // transitionDelegate: transitionDelegate,
        pages: pagesStack,
        onPopPage: (Route<dynamic> route, dynamic result) {
          if (!route.didPop(result)) {
            return false;
          }
          print("onPopPage");
          if (pagesStack.length > 1) {
            if (this._currentConfiguration
                    is AppRouteDataMainWalletsDeployContract ||
                this._currentConfiguration is AppRouteDataMainWalletsNew ||
                this._currentConfiguration
                    is AppRouteDataMainWalletsSendMoney) {
              this._currentConfiguration = AppRouteDataMainWallets();
            }
          } else {
            this._currentConfiguration = AppRouterDataUnknown();
          }
          notifyListeners();
          return true;
        },
      );
    });
  }

  @override
  Future<void> setNewRoutePath(AppRouteData configuration) async {
    print("_AppRouterDelegate#setNewRoutePath: ${configuration}");
    this._currentConfiguration = configuration;
  }

  MaterialPage<WizzardWalletWidget> _buildWizzardWalletPage(AppState appState) {
    return MaterialPage<WizzardWalletWidget>(
      key: ValueKey<Object>(WizzardWalletWidget),
      child: WizzardWalletWidget(
        this._blockchainService,
        onComplete: (
          String walletName,
          KeyPair keyPair,
          MnemonicPhrase? mnemonicPhrase,
        ) async {
          final DataSet dataSet =
              await this._encryptedDbService.read(appState.encryptionKey);
          final KeypairBundlePlain keypairBundle = dataSet
              .addKeypairBundlePlain(walletName, keyPair, mnemonicPhrase);

          await this._encryptedDbService.write(dataSet);
          appState.addKeypairBundle(keypairBundle);
          this._currentConfiguration = AppRouteDataMainWallets();
          this.notifyListeners();
          this._jobService.registerAccountsActivationJob(
              keypairBundle); // push keypairBundle to account activation
        },
      ),
    );
  }

  List<Page<dynamic>> _crashPagesStack(AppRouteDataCrash configuration) =>
      <Page<dynamic>>[CrashPage()];

  List<Page<dynamic>> _mainPagesStack(
    final AppRouteDataMain configuration,
    final BuildContext context,
    final AppState appState,
    final EncryptedDbService encryptedDbService,
    final BlockchainService blockchainService,
  ) {
    if (!encryptedDbService.isInitialized) {
      return this._redirectPagesStack(AppRouteDataNewbeWizzard.PATH);
    }

    if (!appState.isLogged) {
      return this._redirectPagesStack(AppRouterDataSignin.PATH);
    } else {
      if (appState.keypairBundles.length == 0) {
        return this._redirectPagesStack(AppRouteDataNewbeWizzard.PATH);
      }
    }

    final void Function() onSelectHome = () {
      this._currentConfiguration = AppRouteDataMain.home();
      this.notifyListeners();
    };
    final void Function() onSelectWallets = () {
      this._currentConfiguration = AppRouteDataMainWallets();
      this.notifyListeners();
    };
    final void Function() onSelectSetting = () {
      this._currentConfiguration = AppRouteDataMain.settings();
      this.notifyListeners();
    };
    final void Function() onWalletNew = () {
      this._currentConfiguration = AppRouteDataMainWalletsNew();
      this.notifyListeners();
    };
    final DeployContractCallback onDeployContract = (final Account account) {
      this._currentConfiguration =
          AppRouteDataMainWalletsDeployContract(account.blockchainAddress);
      this.notifyListeners();
    };
    final DeployContractCallback onSendMoney = (final Account account) {
      this._currentConfiguration =
          AppRouteDataMainWalletsSendMoney(account.blockchainAddress);
      this.notifyListeners();
    };

    final MainTab selectedTab = configuration.selectedTab;

    final AppRouteData currentConfiguration = this._currentConfiguration;
    return <Page<dynamic>>[
      if (selectedTab != MainTab.HOME)
        MainPage(
          AppRouteDataMain.home(),
          //appState,
          encryptedDbService,
          jobService: this._jobService,
          onSelectHome: onSelectHome,
          onSelectWallets: onSelectWallets,
          onSelectSetting: onSelectSetting,
          onWalletNew: onWalletNew,
          onDeployContract: onDeployContract,
          onSendMoney: onSendMoney,
        ),
      MainPage(
        configuration,
        //appState,
        encryptedDbService,
        jobService: this._jobService,
        onSelectHome: onSelectHome,
        onSelectWallets: onSelectWallets,
        onSelectSetting: onSelectSetting,
        onWalletNew: onWalletNew,
        onDeployContract: onDeployContract,
        onSendMoney: onSendMoney,
      ),
      if (currentConfiguration is AppRouteDataMainWalletsNew)
        _buildWizzardWalletPage(appState)
      else if (currentConfiguration is AppRouteDataMainWalletsDeployContract)
        ..._wizzardDeployContractPagesStack(
          appState,
          encryptedDbService,
          blockchainService,
          currentConfiguration.accountAddress,
        )
      else if (currentConfiguration is AppRouteDataMainWalletsSendMoney)
        ..._wizzardSendMoneyPagesStack(
          appState,
          encryptedDbService,
          blockchainService,
          currentConfiguration.accountAddress,
        )
    ];
  }

  List<Page<dynamic>> _signinPagesStack(
    AppRouterDataSignin configuration,
    BuildContext context,
    AppState appState,
    EncryptedDbService encryptedDbService,
  ) {
    if (!encryptedDbService.isInitialized) {
      return this._redirectPagesStack(AppRouteDataNewbeWizzard.PATH);
    }

    if (appState.isLogged) {
      if (appState.keypairBundles.length == 0) {
        return this._redirectPagesStack(AppRouteDataNewbeWizzard.PATH);
      }

      return this._redirectPagesStack(AppRouteDataMain.PATH);
    }

    return <Page<dynamic>>[
      MaterialPage<UnlockWidget>(
        key: ValueKey<Object>(UnlockWidget),
        child: UnlockWidget(
          onComplete: (
            ExecutionContext executionContext,
            UnlockContext ctx,
          ) async {
            final String masterPassword = ctx.password;
            if (encryptedDbService.isInitialized && !appState.isLogged) {
              try {
                final Uint8List encryptionKey = await encryptedDbService
                    .derivateEncryptionKey(masterPassword);
                final DataSet dataSet =
                    await encryptedDbService.read(encryptionKey);
                if (!appState.isLogged) {
                  appState.setLoginEncryptionKey(encryptionKey);
                  for (final KeypairBundle keypairBundle
                      in dataSet.keypairBundles) {
                    appState.addKeypairBundle(keypairBundle);
                    if (keypairBundle.accounts.length == 0) {
                      this._jobService.registerAccountsActivationJob(
                          keypairBundle); // push keypairBundle to account activation
                    }
                  }
                } else {
                  this._currentConfiguration = AppRouteDataCrash();
                }
              } catch (e) {
                final FreemeworkException err =
                    FreemeworkException.wrapIfNeeded(e);
                print(err);
                this._currentConfiguration = AppRouteDataCrash(/* err */);
              }
            } else {
              this._currentConfiguration = AppRouteDataCrash();
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

  List<Page<dynamic>> _wizzardNewbePagesStack(
    final AppRouteDataNewbeWizzard configuration,
    final BuildContext context,
    final AppState appState,
    final EncryptedDbService encryptedDbService,
    final BlockchainService blockchainService,
  ) {
    if (encryptedDbService.isInitialized) {
      if (!appState.isLogged) {
        return this._redirectPagesStack(AppRouterDataSignin.PATH);
      }
      if (appState.keypairBundles.length > 0) {
        return this._redirectPagesStack(AppRouteDataMain.PATH);
      }
    } else {
      return <Page<dynamic>>[
        MaterialPage<SetupMasterPasswordWidget>(
          key: ValueKey<Object>(SetupMasterPasswordWidget),
          child: SetupMasterPasswordWidget(
            onComplete: (
              ExecutionContext executionContext,
              SetupMasterPasswordContext ctx,
            ) async {
              final String masterPassword = ctx.password;
              if (!encryptedDbService.isInitialized && !appState.isLogged) {
                try {
                  final Uint8List encryptionKey =
                      await encryptedDbService.wipe(masterPassword);
                  appState.setLoginEncryptionKey(encryptionKey);
                } catch (e) {
                  final FreemeworkException err =
                      FreemeworkException.wrapIfNeeded(e);
                  print(err);
                  this._currentConfiguration = AppRouteDataCrash(/* err */);
                }
              } else {
                this._currentConfiguration = AppRouteDataCrash();
              }
              this.notifyListeners();
            },
          ),
        )
      ];
    }

    return <Page<dynamic>>[
      _buildWizzardWalletPage(appState),
    ];
  }

  List<Page<dynamic>> _wizzardDeployContractPagesStack(
    final AppState appState,
    final EncryptedDbService encryptedDbService,
    final BlockchainService blockchainService,
    final String accountAddress,
  ) {
    final DeployContractWidgetApi widgetApi =
        DeployContractWidgetApiAdapter(
      appState,
      blockchainService,
      encryptedDbService,
      accountAddress,
    );

    return <Page<dynamic>>[
      MaterialPage<DeployContractWidget>(
        key: ValueKey<Object>(DeployContractWidget),
        child: DeployContractWidget(widgetApi),
      )
    ];
  }

  List<Page<dynamic>> _wizzardSendMoneyPagesStack(
    final AppState appState,
    final EncryptedDbService encryptedDbService,
    final BlockchainService blockchainService,
    final String accountAddress,
  ) {
    final SendMoneyWidgetApi widgetApi =
        SendMoneyWidgetApiAdapter(
      appState,
      blockchainService,
      encryptedDbService,
      accountAddress,
    );

    return <Page<dynamic>>[
      MaterialPage<SendMoneyWidget>(
        key: ValueKey<Object>(SendMoneyWidget),
        child: SendMoneyWidget(widgetApi),
      )
    ];
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

// class _SplashScreenPage extends Page<AppRouteDataMain> {
//   final void Function(String routePath) onChangeRoute;
//   final EncryptedDbService _encryptedDbService;
//   final AppState _appState;

//   _SplashScreenPage(
//     this._appState,
//     this._encryptedDbService, {
//     required this.onChangeRoute,
//   });

//   @override
//   Route<AppRouteDataMain> createRoute(BuildContext context) {
//     return PageRouteBuilder<AppRouteDataMain>(
//       settings: this,
//       pageBuilder: (context, animation, animation2) {
//         // final tween = Tween(begin: Offset(0.0, 1.0), end: Offset.zero);
//         // final curveTween = CurveTween(curve: Curves.easeInOut);
//         // return SlideTransition(
//         //   position: animation.drive(curveTween).drive(tween),
//         //   child: BookDetailsScreen(
//         //     key: ValueKey(book),
//         //     book: book,
//         //   ),
//         // );
//         return _SplashScreen(
//           appState: _appState,
//           encryptedDbService: _encryptedDbService,
//           onChangeRoute: onChangeRoute,
//         );
//       },
//     );
//   }
// }

// class _SplashScreen extends StatefulWidget {
//   final EncryptedDbService encryptedDbService;
//   final AppState appState;
//   final void Function(String routePath) onChangeRoute;

//   _SplashScreen({
//     required this.appState,
//     required this.encryptedDbService,
//     required this.onChangeRoute,
//   });

//   @override
//   State<StatefulWidget> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<_SplashScreen> {
//   ManualCancellationTokenSource? _cts;

//   _SplashScreenState() : this._cts = null;

//   @override
//   void initState() {
//     super.initState();

//     final ManualCancellationTokenSource cts = ManualCancellationTokenSource();
//     this._cts = cts;

//     this._loadRoutePath().then((String routePath) {
//       this.widget.onChangeRoute(routePath);
//     }).catchError((dynamic error, dynamic stackTrace) {
//       this.widget.onChangeRoute(AppRouteDataCrash.PATH);
//     }).whenComplete(() => cts.cancel());
//   }

//   @override
//   void dispose() {
//     ManualCancellationTokenSource? cts = this._cts;
//     this._cts = null;
//     if (cts != null) {
//       cts.cancel();
//     }
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Text("Loading"),
//     );
//   }

//   Future<String> _loadRoutePath() async {
//     await Future<void>.delayed(Duration(seconds: 1));
//     final bool isInitialized = this.widget.encryptedDbService.isInitialized;
//     if (!isInitialized) {
//       return AppRouteDataNewbeWizzard.PATH;
//     } else {
//       final bool isLogged = this.widget.appState.isLogged;
//       if (isLogged) {
//         return AppRouterDataUnknown.PATH;
//       } else {
//         return AppRouterDataSignin.PATH;
//       }
//     }
//   }
// }
