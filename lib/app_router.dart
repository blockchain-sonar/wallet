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
    show AppBar, Colors, MaterialApp, MaterialPage, Scaffold, ThemeData;
import "package:flutter/src/widgets/framework.dart";
import "package:flutter/src/widgets/navigator.dart";
import "package:flutter/widgets.dart"
    show
        Alignment,
        AsyncSnapshot,
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
    show DataSet, EncryptedDbService, KeyPairBundleData, WalletDataPlain;
import 'widgets/business/main_wallets.dart';
import 'widgets/business/select_smart_contract.dart';
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
  )   : this._routerDelegate =
            _AppRouterDelegate(encryptedDbService, blockchainService),
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
  final BlockchainService _walletService;

  AppRouteData _currentConfiguration;

  _AppRouterDelegate(this._encryptedDbService, this._walletService)
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
          this._walletService,
        );
      else if (currentConfiguration is AppRouteDataMain)
        pagesStack = _mainPagesStack(
          currentConfiguration,
          consumerContext,
          appState,
          this._encryptedDbService,
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
          if (pagesStack.length > 1) {
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

  Widget _buildPageLayoutWidget({required Widget child}) {
    // child: MaterialApp(
    //   title: "Free TON Wallet (Alpha)",
    //   theme: ThemeData(
    //     primarySwatch: Colors.blue,
    //   ),
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          alignment: Alignment.center,
          constraints: BoxConstraints(minWidth: 196, maxWidth: 480),
          child: child,
        ),
      ],
    );
    // ),
  }

  MaterialPage<WizzardWalletWidget> _buildWizzardWalletPage(AppState appState) {
    return MaterialPage<WizzardWalletWidget>(
      key: ValueKey<Object>(WizzardWalletWidget),
      child: WizzardWalletWidget(
        this._walletService,
        onComplete: (
          String walletName,
          KeyPair keyPair,
          MnemonicPhrase? mnemonicPhrase,
        ) async {
          final DataSet dataSet =
              await this._encryptedDbService.read(appState.encryptionKey);
          final WalletDataPlain walletData =
              dataSet.addPlainWallet(walletName, keyPair, mnemonicPhrase);
          await this._encryptedDbService.write(dataSet);
          appState.addWallet(walletData);
          this._currentConfiguration = AppRouteDataMainWallets();
          this.notifyListeners();
        },
      ),
    );
  }

  List<Page<dynamic>> _crashPagesStack(AppRouteDataCrash configuration) =>
      <Page<dynamic>>[CrashPage()];

  List<Page<dynamic>> _mainPagesStack(
    AppRouteDataMain configuration,
    BuildContext context,
    AppState appState,
    EncryptedDbService encryptedDbService,
  ) {
    if (!encryptedDbService.isInitialized) {
      return this._redirectPagesStack(AppRouteDataNewbeWizzard.PATH);
    }

    if (!appState.isLogged) {
      return this._redirectPagesStack(AppRouterDataSignin.PATH);
    } else {
      if (appState.wallets.length == 0) {
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
    final MainWalletsDeployContractCallback onDeployContract =
        (final String keypairName) {
      this._currentConfiguration = AppRouteDataMainWallets(keypairName);
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
          onSelectHome: onSelectHome,
          onSelectWallets: onSelectWallets,
          onSelectSetting: onSelectSetting,
          onWalletNew: onWalletNew,
          onDeployContract: onDeployContract,
        ),
      MainPage(
        configuration,
        //appState,
        encryptedDbService,
        onSelectHome: onSelectHome,
        onSelectWallets: onSelectWallets,
        onSelectSetting: onSelectSetting,
        onWalletNew: onWalletNew,
        onDeployContract: onDeployContract,
      ),
      if (currentConfiguration is AppRouteDataMainWalletsNew)
        _buildWizzardWalletPage(appState)
      else if (currentConfiguration is AppRouteDataMainWallets &&
          currentConfiguration.keyNameToDeployContract != null)
        ..._wizzardDeployContractPagesStack(currentConfiguration.keyNameToDeployContract!)
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
      if (appState.wallets.length == 0) {
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
                  for (final KeyPairBundleData dsWallet in dataSet.wallets) {
                    appState.addWallet(dsWallet);
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
    AppRouteDataNewbeWizzard configuration,
    BuildContext context,
    AppState appState,
    EncryptedDbService encryptedDbService,
    BlockchainService blockchainService,
  ) {
    if (encryptedDbService.isInitialized) {
      if (!appState.isLogged) {
        return this._redirectPagesStack(AppRouterDataSignin.PATH);
      }
      if (appState.wallets.length > 0) {
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
      final String keyNameToDeployContract) {
    return <Page<dynamic>>[
      MaterialPage<SelectSmartContractWidget>(
        key: ValueKey<Object>(SelectSmartContractWidget),
        child: SelectSmartContractWidget(
          SmartContract.ALL,
          onComplete: (final SmartContract? selectedSmartContract) {
            if (selectedSmartContract != null) {
              this._currentConfiguration = AppRouteDataMainWallets(
                  keyNameToDeployContract, selectedSmartContract);
            } else {
              this._currentConfiguration = AppRouteDataMainWallets();
            }
            this.notifyListeners();
          },
        ),
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
    return Scaffold(
      appBar: AppBar(),
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
