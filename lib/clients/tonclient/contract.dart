import "package:freemework/freemework.dart"
    show ExecutionContext, FreemeworkException;

import "src/models/account_info.dart" show AccountInfo;
import "src/models/fees.dart" show Fees;
import "src/models/key_pair.dart" show KeyPair;
import "src/models/processing_state.dart" show ProcessingState;
import "src/models/run_message.dart" show RunMessage;
import "src/models/transaction.dart" show Transaction;

enum SeedType {
  SHORT,
  LONG,
}

abstract class AbstractTonClient {
  Future<void> init(
    ExecutionContext executionContext,
  );

  Future<Fees> calcDeployFees(
    KeyPair keypair,
    String smartContractAbiSpec,
    String smartContractBlobTvcBase64,
  );
  Future<RunMessage> createRunMessage(
    KeyPair keypair,
    String accountAddress,
    String smartContractAbiSpec,
    String methodName,
    Map<String, dynamic> args,
  );
  Future<void> deployContract(
    KeyPair keypair,
    String smartContractAbiSpec,
    String smartContractBlobTvcBase64,
  );
  Future<KeyPair> deriveKeys(
    List<String> seedMnemonicWords,
    String hdpath,
  );
  Future<List<String>> generateMnemonicPhraseSeed(
    SeedType seedType,
  );
  Future<String> getDeployData(
    String keyPublic,
    String smartContractAbiSpec,
    String smartContractBlobTvcBase64,
  );
  Future<AccountInfo?> fetchAccountInformation(
    String accountAddress,
  );
  Future<ProcessingState> sendMessage(
    String messageSendToken,
  );
  Future<Transaction> waitForRunTransaction(
    String messageSendToken,
    String processingStateToken,
  );
}

///
/// A common exception for any [TonClient] issues.
///
class TonClientException extends FreemeworkException {
  TonClientException([String? message, FreemeworkException? innerException])
      : super(message, innerException);
}

///
/// Interop Violation show integrity issue, like use non-compatible underlaying library.
/// Normally this exception should never happens in production build.
///
abstract class InteropViolationException extends TonClientException {
  InteropViolationException(
      [String? message, FreemeworkException? innerException])
      : super(message, innerException);
}

///
/// Interop Violation Result show integrity issue, like use non-compatible underlaying library.
/// Normally this exception should never happens in production build.
///
class InteropViolationResultException extends InteropViolationException {
  final Object underlayingResult;
  InteropViolationResultException(this.underlayingResult,
      [String? message, FreemeworkException? innerException])
      : super(message, innerException);
}

///
/// Interop Violation Data show integrity issue, like use non-compatible underlaying library.
/// Normally this exception should never happens in production build.
///
class InteropViolationDataException extends InteropViolationException {
  final String property;
  InteropViolationDataException(
    this.property, [
    String? message,
    FreemeworkException? innerException,
  ]) : super(message, innerException);
}
