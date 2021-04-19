import 'database_service.dart'
    show DatabaseService, DatabaseServiceLocalStorage;
import "crypto_service.dart" show CryptoService, PointyCastleCryptoService;
import "wallet_service.dart" show WalletService;

abstract class ServiceFactory {
  DatabaseService createDatabaseService(CryptoService cryptoService);
  CryptoService createCryptoService();
  WalletService createWalletService();
}

class ServiceFactoryProductive extends ServiceFactory {
  @override
  DatabaseService createDatabaseService(CryptoService cryptoService) =>
      DatabaseServiceLocalStorage(cryptoService);

  @override
  CryptoService createCryptoService() => PointyCastleCryptoService();

  @override
  WalletService createWalletService() {
    // TODO: implement createWalletService
    throw UnimplementedError();
  }
}
