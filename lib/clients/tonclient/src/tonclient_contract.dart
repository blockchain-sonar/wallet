import "package:freemework/freemework.dart" show ExecutionContext;

abstract class AbstractTonClient {
  Future<void> init(ExecutionContext executionContext);

  Future<String> generateMnemonicPhrase();
}
