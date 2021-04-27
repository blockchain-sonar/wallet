import "package:freemework/freemework.dart" show ExecutionContext;
import "models/deployData.dart" show TonDeployData;
import "models/keyPair.dart" show KeyPair;

abstract class AbstractTonClient {
  Future<void> init(ExecutionContext executionContext);

  Future<String> generateMnemonicPhrase();

  Future<KeyPair> deriveKeys(String seed);

  Future<TonDeployData> getDeployData(KeyPair keys);

  Future<dynamic> calcDeployFees(KeyPair keys);

  Future<dynamic> deployContract(KeyPair keys);

  Future<dynamic> getAccountData(String address);
}
