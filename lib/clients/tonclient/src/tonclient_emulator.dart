import "package:freemework/freemework.dart" show ExecutionContext;

import "../contract.dart" show AbstractTonClient, SeedType;

import "models/account_info.dart" show AccountInfo;
import "models/fees.dart" show Fees;
import "models/key_pair.dart" show KeyPair;
import "models/processing_state.dart" show ProcessingState;
import "models/run_message.dart" show RunMessage;
import "models/transaction.dart" show Transaction;

class TonClient extends AbstractTonClient {
  @override
  Future<void> init(ExecutionContext executionContext) async {
    print("Initialize TonClient Emulator");
  }

  @override
  Future<Fees> calcDeployFees(KeyPair keypair, String smartContractAbiSpec, String smartContractBlobTvcBase64) {
      // TODO: implement calcDeployFees
      throw UnimplementedError();
    }
  
    @override
    Future<RunMessage> createRunMessage(KeyPair keypair, String accountAddress, String smartContractAbiSpec, String methodName, Map<String, dynamic> args) {
      // TODO: implement createRunMessage
      throw UnimplementedError();
    }
  
    @override
    Future<void> deployContract(KeyPair keypair, String smartContractAbiSpec, String smartContractBlobTvcBase64) {
      // TODO: implement deployContract
      throw UnimplementedError();
    }
  
    @override
    Future<KeyPair> deriveKeys(String mnemonicPhraseSeed, SeedType seedType) {
      // TODO: implement deriveKeys
      throw UnimplementedError();
    }
  
    @override
    Future<AccountInfo?> fetchAccountInformation(String accountAddress) {
      // TODO: implement fetchAccountInformation
      throw UnimplementedError();
    }
  
    @override
    Future<String> generateMnemonicPhraseSeed(SeedType seedType) {
      // TODO: implement generateMnemonicPhraseSeed
      throw UnimplementedError();
    }
  
    @override
    Future<String> getDeployData(String keyPublic, String smartContractAbiSpec, String smartContractBlobTvcBase64) {
      // TODO: implement getDeployData
      throw UnimplementedError();
    }
  
    @override
    Future<ProcessingState> sendMessage(String messageSendToken) {
      // TODO: implement sendMessage
      throw UnimplementedError();
    }
  
    @override
    Future<Transaction> waitForRunTransaction(String messageSendToken, String processingStateToken) {
    // TODO: implement waitForRunTransaction
    throw UnimplementedError();
  }

}
