import "authentication_service.dart" show AuthenticationService, AuthenticationServiceLocalStotage;
import "wallet_service.dart" show WalletService;

abstract class ServiceFactory {
  AuthenticationService createAuthenticationService();
  WalletService createWalletService();
}

class ServiceFactoryProductive extends ServiceFactory {
  @override
  AuthenticationService createAuthenticationService() =>
      AuthenticationServiceLocalStotage();

  @override
  WalletService createWalletService() {
    // TODO: implement createWalletService
    throw UnimplementedError();
  }
}
