import "package:flutter/widgets.dart"
    show
        AsyncSnapshot,
        BuildContext,
        Center,
        ConnectionState,
        FutureBuilder,
        Key,
        StatelessWidget,
        Text,
        Widget;

import "widgets/business/crash.dart" show CrashStandalone;
import "widgets/business/splash.dart" show SplashStandalone;
import "package:provider/provider.dart"
    show
        ChangeNotifierProvider,
        Provider;

import "app_router.dart" show AppRouterWidget;
import "services/crypto_service.dart" show CryptoService;
import "services/service_factory.dart" show ServiceFactory;
import "services/encrypted_db_service.dart" show EncryptedDbService;
import "services/blockchain/blockchain.dart" show BlockchainService;
import "services/job.dart" show JobService;
import "states/app_state.dart" show AppState;

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
              servicesBundle.blockchainService,
              servicesBundle.jobService,
            ),
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
  EncryptedDbService? _encryptedDbService;
  BlockchainService? _blockchainService;
  JobService? _jobService;

  CryptoService get cryptoService {
    assert(this._cryptoService != null);
    return this._cryptoService!;
  }

  EncryptedDbService get encryptedDbService {
    assert(this._encryptedDbService != null);
    return this._encryptedDbService!;
  }

  BlockchainService get blockchainService {
    assert(this._blockchainService != null);
    return this._blockchainService!;
  }

  JobService get jobService {
    assert(this._jobService != null);
    return this._jobService!;
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
        this._blockchainService = null;

  Future<_ServicesBundle> _init() async {
    final CryptoService cryptoService =
        await this._serviceFactory.createCryptoService();
    final EncryptedDbService encryptedDbService =
        await this._serviceFactory.createEncryptedDbService(cryptoService);
    final BlockchainService blockchainService =
        await this._serviceFactory.createBlockchainService();
    final JobService jobService = await this
        ._serviceFactory
        .createJobService(blockchainService, encryptedDbService);

    this._cryptoService = cryptoService;
    this._encryptedDbService = encryptedDbService;
    this._blockchainService = blockchainService;
    this._jobService = jobService;

    return this;
  }
}
