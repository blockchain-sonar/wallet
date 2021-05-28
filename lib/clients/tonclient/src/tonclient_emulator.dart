import "package:freemework/freemework.dart" show ExecutionContext;

import "models/account_info.dart" show AccountInfo;
import "models/fees.dart" show Fees;
import "models/key_pair.dart";
import "../contract.dart" show AbstractTonClient, SeedType;

class TonClient extends AbstractTonClient {
  @override
  Future<void> init(ExecutionContext executionContext) async {
    print("Initialize TonClient Emulator");
  }

  @override
  Future<String> generateMnemonicPhraseSeed(SeedType seedType) async {
    return "stub stub stub stub stub stub stub stub stub stub stub stub";
  }

  @override
  Future<KeyPair> deriveKeys(
      String mnemonicPhraseSeed, SeedType seedType) async {
    return KeyPair(
        public:
            "public public public public public public public public public",
        secret:
            "secret secret secret secret secret secret secret secret secret");
  }

  @override
  Future<String> getDeployData(
    final String keyPublic,
    final String smartContractAbiSpec,
    final String smartContractBlobTvcBase64,
  ) async {
    // DeployData deployData = DeployData(
    //   accountId: "accountId",
    //   address: "address",
    //   dataBase64: "dataBase64",
    //   imageBase64: "imageBase64",
    // );
    return "address";
  }

  @override
  Future<Fees> calcDeployFees(
    final KeyPair keypair,
    final String smartContractAbiSpec,
    final String smartContractBlobTvcBase64,
  ) {
    // TODO: implement calcDeployFees
    throw UnimplementedError();
  }

  @override
  Future<dynamic> deployContract(
    final KeyPair keypair,
    final String smartContractAbiSpec,
    final String smartContractBlobTvcBase64,
  ) {
    // TODO: implement deployContract
    throw UnimplementedError();
  }

  @override
  Future<AccountInfo?> fetchAccountInformation(String accountAddress) {
    // TODO: implement getAccountData
    throw UnimplementedError();
  }

  @override
  Future<void> sendTransaction(
    final KeyPair keypair,
    final String sourceAddress,
    final String destinationAddress,
    final String amount,
    final String comment,
  ) {
    // TODO: implement sendTransaction
    throw UnimplementedError();
  }
}
