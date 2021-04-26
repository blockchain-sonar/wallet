import "package:freemework/freemework.dart" show ExecutionContext;
import "models/keyPair.dart" show KeyPair;

abstract class AbstractTonClient {
  Future<void> init(ExecutionContext executionContext);

  Future<String> generateMnemonicPhrase();

  Future<KeyPair> deriveKeys(String seed);

  Future<String> getDeployData(KeyPair keys);
}
