import "package:flutter/material.dart" show Colors, MaterialApp, ThemeData;
import "package:flutter/widgets.dart"
    show
        Alignment,
        AsyncSnapshot,
        BoxConstraints,
        BuildContext,
        Container,
        FutureBuilder,
        Key,
        MainAxisAlignment,
        MainAxisSize,
        Row,
        StatelessWidget,
        Text,
        Widget;
import 'package:flutter/widgets.dart';
import "package:freemework/freemework.dart" show ExecutionContext;
import 'package:freeton_wallet/router/crash_page.dart';
import 'package:freeton_wallet/widgets/business/crash.dart';
import 'package:freeton_wallet/widgets/business/splash.dart';
import "package:provider/provider.dart"
    show
        ChangeNotifierProvider,
        Consumer,
        FutureProvider,
        MultiProvider,
        Provider;
import "package:provider/single_child_widget.dart" show SingleChildWidget;

import 'app_router.dart';
import "services/crypto_service.dart" show CryptoService;
import "services/service_factory.dart" show ServiceFactory;
import 'services/encrypted_db_service.dart' show EncryptedDbService;
import "services/wallet_service.dart" show WalletService;
import 'states/app_state.dart';
import 'widgets/business/setup_master_password.dart'
    show SetupMasterPasswordContext, SetupMasterPasswordWidget;
import "widgets/business/unlock.dart" show UnlockContext, UnlockWidget;
import "wizzard_key.dart" show WizzardWalletWidget;

class App extends StatelessWidget {
  const App(this.serviceFactory, {Key? key}) : super(key: key);

  final ServiceFactory serviceFactory;

  @override
  Widget build(BuildContext context) {
    return Provider<ServiceFactory>.value(
      value: serviceFactory,
      child: FutureBuilder<_ServicesBundle>(
        future: _ServicesBundle(serviceFactory).init(),
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

          return ChangeNotifierProvider<AppState>(
            create: (_) => AppState(),
            child: AppRouterWidget(
              servicesBundle.encryptedDbService,
              servicesBundle.walletService,
            ),
          );
        },
      ),
    );
  }
}

// Widget _buildAuthenticationWidget() {
//   return Consumer<EncryptedDbService>(
//     builder: (
//       BuildContext context,
//       EncryptedDbService databaseService,
//       Widget? child,
//     ) {
//       if (databaseService.isLogged) {
//         if (databaseService.keys.length > 0) {
//           return Text("YEYEESSPS");
//         } else {
//           return WizzardKeyWidget();
//         }
//       } else {
//         if (!databaseService.hasDatabase) {
//           return SetupMasterPasswordWidget(
//             onComplete: (
//               ExecutionContext executionContext,
//               SetupMasterPasswordContext ctx,
//             ) async {
//               final String masterPassword = ctx.password;
//               await databaseService.wipeDatabase(masterPassword);
//             },
//           );
//         } else {
//           return UnlockWidget(
//             onComplete: (
//               ExecutionContext executionContext,
//               UnlockContext ctx,
//             ) async {
//               final String masterPassword = ctx.password;
//               await databaseService.loginDatabase(masterPassword);
//             },
//           );
//         }
//       }
//     },
//   );
// }

class _ServicesBundle {
  final ServiceFactory _serviceFactory;
  Future<_ServicesBundle>? _initFuture;
  CryptoService? _cryptoService;
  EncryptedDbService? _encryptedDbService;
  WalletService? _walletService;

  CryptoService get cryptoService {
    assert(this._cryptoService != null);
    return this._cryptoService!;
  }

  EncryptedDbService get encryptedDbService {
    assert(this._encryptedDbService != null);
    return this._encryptedDbService!;
  }

  WalletService get walletService {
    assert(this._walletService != null);
    return this._walletService!;
  }

  Future<_ServicesBundle> init() {
    final Future<_ServicesBundle>? initFuture = this._initFuture;
    if (initFuture != null) {
      return initFuture;
    }
    return this._initFuture = this._init();
  }

  _ServicesBundle(this._serviceFactory)
      : this._cryptoService = null,
        this._encryptedDbService = null,
        this._walletService = null;

  Future<_ServicesBundle> _init() async {
    final CryptoService cryptoService =
        await this._serviceFactory.createCryptoService();
    final EncryptedDbService encryptedDbService =
        await this._serviceFactory.createEncryptedDbService(cryptoService);
    final WalletService walletService =
        await this._serviceFactory.createWalletService();

    this._cryptoService = cryptoService;
    this._encryptedDbService = encryptedDbService;
    this._walletService = walletService;

    return this;
  }
}
