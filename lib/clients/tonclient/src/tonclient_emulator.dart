import "package:freemework/freemework.dart" show ExecutionContext;
import 'package:freeton_wallet/clients/tonclient/src/models/keyPair.dart';

import "tonclient_contract.dart" show AbstractTonClient;

class TonClient extends AbstractTonClient {
  @override
  Future<void> init(ExecutionContext executionContext) async {
    print("Initialize TonClient Emulator");
  }

  @override
  Future<String> generateMnemonicPhrase() async {
    return "stub stub stub stub stub stub stub stub stub stub stub stub";
  }

  @override
  Future<KeyPair> deriveKeys(String seed) async {
    return KeyPair(
        public:
            "public public public public public public public public public",
        secret:
            "secret secret secret secret secret secret secret secret secret");
  }

  @override
  Future<String> getDeployData(KeyPair keys) async {
    return "stub stub stub stub stub stub stub stub stub stub stub stub";
  }
}
