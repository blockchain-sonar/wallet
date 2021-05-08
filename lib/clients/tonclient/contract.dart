import "package:freemework/freemework.dart"
    show ExecutionContext, FreemeworkException;
import "src/models/deployData.dart" show TonDeployData;
import "src/models/keyPair.dart" show KeyPair;

enum SeedType {
  SHORT,
  LONG,
}

abstract class AbstractTonClient {
  Future<void> init(ExecutionContext executionContext);

  Future<String> generateMnemonicPhraseSeed(SeedType seedType);

  Future<KeyPair> deriveKeys(String mnemonicPhraseSeed);

  Future<TonDeployData> getDeployData(KeyPair keys);

  Future<dynamic> calcDeployFees(KeyPair keys);

  Future<dynamic> deployContract(KeyPair keys);

  Future<dynamic> getAccountData(String address);
}

///
/// A common exception for any [TonClient] issues.
///
class TonClientException extends FreemeworkException {
  TonClientException([String? message, FreemeworkException? innerException])
      : super(message, innerException);
}

///
/// Interop Contract Violation show integrity issue, like use non-compatible underlaying library.
/// Normally this exception should never happens in production build.
///
class InteropContractException extends TonClientException {
  final String property;
  InteropContractException(
    this.property, [
    String? message,
    FreemeworkException? innerException,
  ]) : super(message, innerException);
}
