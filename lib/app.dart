import "package:flutter/material.dart" show Colors, MaterialApp, ThemeData;
import "package:flutter/widgets.dart"
    show BuildContext, Key, StatelessWidget, Text, Widget;
import "package:freemework/freemework.dart" show ExecutionContext;
import 'package:freeton_wallet/wizzard_key.dart';
import "package:provider/provider.dart"
    show ChangeNotifierProvider, Consumer, MultiProvider, Provider;
import "package:provider/single_child_widget.dart" show SingleChildWidget;

import "services/crypto_service.dart" show CryptoService;
import "services/service_factory.dart" show ServiceFactory;
import "services/database_service.dart" show DatabaseService;
import "services/wallet_service.dart" show WalletService;
import "widgets/business/setup_master_password_widget.dart"
    show SetupMasterPasswordContext, SetupMasterPasswordWidget;
import "widgets/business/unlock.dart" show UnlockContext, UnlockWidget;
import "widgets/toolchain/dialog_widget.dart" show DialogWidget;

class App extends StatelessWidget {
  const App(this.serviceFactory, {Key? key}) : super(key: key);

  final ServiceFactory serviceFactory;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: <SingleChildWidget>[
        Provider<ServiceFactory>.value(value: serviceFactory),
        Provider<CryptoService>(
          create: (BuildContext context) =>
              this.serviceFactory.createCryptoService(),
        ),
      ],
      child: MultiProvider(
        providers: <SingleChildWidget>[
          ChangeNotifierProvider<DatabaseService>(
            create: (BuildContext context) {
              final CryptoService cryptoService =
                  Provider.of<CryptoService>(context, listen: false);
              return this.serviceFactory.createDatabaseService(cryptoService);
            },
          ),
          Provider<WalletService>(
            create: (BuildContext context) =>
                this.serviceFactory.createWalletService(),
          ),
        ],
        child: MaterialApp(
          title: "Free TON Wallet (Alpha)",
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: _buildAuthenticationWidget(),
        ),
      ),
    );
  }
}

Widget _buildAuthenticationWidget() {
  return Consumer<DatabaseService>(
    builder: (
      BuildContext context,
      DatabaseService databaseService,
      Widget? child,
    ) {
      if (databaseService.isLogged) {
        if (databaseService.keys.length > 0) {
          return Text("YEYEESSPS");
        } else {
          return WizzardKeyWidget();
        }
      } else {
        if (!databaseService.hasDatabase) {
          return SetupMasterPasswordWidget(
            onComplete: (
              ExecutionContext executionContext,
              SetupMasterPasswordContext ctx,
            ) async {
              final String masterPassword = ctx.password;
              await databaseService.wipeDatabase(masterPassword);
            },
          );
        } else {
          return UnlockWidget(
            onComplete: (
              ExecutionContext executionContext,
              UnlockContext ctx,
            ) async {
              final String masterPassword = ctx.password;
              await databaseService.loginDatabase(masterPassword);
            },
          );
        }
      }
    },
  );
}
