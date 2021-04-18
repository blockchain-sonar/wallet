import "package:flutter/material.dart" show MaterialApp;
import "package:flutter/widgets.dart"
    show
        BuildContext,
        Key,
        StatelessWidget,
        Text,
        Widget;
import "package:provider/provider.dart"
    show ChangeNotifierProvider, Consumer, MultiProvider, Provider;
import "package:provider/single_child_widget.dart" show SingleChildWidget;

import "services/service_factory.dart" show ServiceFactory;
import "services/authentication_service.dart" show AuthenticationService;
import "services/wallet_service.dart" show WalletService;

class App extends StatelessWidget {
  const App(this.serviceFactory, {Key? key}) : super(key: key);

  final ServiceFactory serviceFactory;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: <SingleChildWidget>[
        ChangeNotifierProvider<AuthenticationService>(
          create: (BuildContext context) =>
              this.serviceFactory.createAuthenticationService(),
        ),
        Provider<WalletService>(
          create: (BuildContext context) =>
              this.serviceFactory.createWalletService(),
        ),
      ],
      child: _buildAuthenticationWidget(),
    );
  }
}

Widget _buildAuthenticationWidget() {
  return Consumer<AuthenticationService>(
    builder: (
      BuildContext context,
      AuthenticationService authenticationService,
      Widget? child,
    ) {
      if (authenticationService.isLogged) {
        return Text("You are logged");
      } else {
        return Text("You are NOT logged");
      }
    },
  );
}
