import "package:freemework/freemework.dart"
    show ExecutionContext, FreemeworkException;
import "src/models/account_info.dart" show AccountInfo;
import "src/models/fees.dart" show Fees;
import "src/models/key_pair.dart" show KeyPair;

enum SeedType {
  SHORT,
  LONG,
}

abstract class AbstractTonClient {
  Future<void> init(ExecutionContext executionContext);

  Future<dynamic> deployContract(
    KeyPair keypair,
    String smartContractAbiSpec,
    String smartContractBlobTvcBase64,
  );
  Future<KeyPair> deriveKeys(String mnemonicPhraseSeed, SeedType seedType);
  Future<Fees> calcDeployFees(
    KeyPair keypair,
    String smartContractAbiSpec,
    String smartContractBlobTvcBase64,
  );
  Future<AccountInfo?> fetchAccountInformation(String accountAddress);
  Future<String> getDeployData(
    String keyPublic,
    String smartContractAbiSpec,
    String smartContractBlobTvcBase64,
  );
  Future<String> generateMnemonicPhraseSeed(SeedType seedType);
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
