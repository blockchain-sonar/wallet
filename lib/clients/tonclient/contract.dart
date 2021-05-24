import "package:freemework/freemework.dart"
    show ExecutionContext, FreemeworkException;
import "src/models/account_info.dart" show AccountInfo;
import 'src/models/keypair.dart' show KeyPair;

enum SeedType {
  SHORT,
  LONG,
}

abstract class AbstractTonClient {
  Future<void> init(ExecutionContext executionContext);

  Future<String> generateMnemonicPhraseSeed(SeedType seedType);

  Future<KeyPair> deriveKeys(String mnemonicPhraseSeed, SeedType seedType);

  // Future<DeployData> getDeployData(KeyPair keys);
  Future<String> getDeployData(String publicKey, String smartContractABI, String smartContractTVCBase64);

  Future<dynamic> calcDeployFees(KeyPair keys);

  Future<dynamic> deployContract(KeyPair keys);

  Future<AccountInfo> getAccountInformation(String accountAddress);
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
