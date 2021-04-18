import "package:freemework/freemework.dart" show ExecutionContext;

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
}
