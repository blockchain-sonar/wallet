@JS()
library tonclient;

import "dart:js_util" show getProperty, hasProperty, newObject, promiseToFuture;
import "package:freemework/freemework.dart"
    show ExecutionContext, InvalidOperationException;
import 'package:freeton_wallet/clients/tonclient/src/models/fees.dart';
import "package:js/js.dart";
import "package:js/js_util.dart"
    show getProperty, hasProperty, newObject, promiseToFuture, setProperty;
import "../contract.dart";
import "models/account_info.dart" show AccountInfo, DeployedAccountInfo;
import "models/key_pair.dart" show KeyPair;
import "../contract.dart"
    show AbstractTonClient, InteropContractException, TonClientException;

// The `TONClientFacade` constructor invokes JavaScript `new window.TONClientFacade()`
@JS("TONClientFacade")
class _TONClientFacadeInterop {
  external _TONClientFacadeInterop();
  external dynamic init();
  external dynamic calcDeployFees(
    String keyPublic,
    String keySecret,
    String smartContractAbiSpec,
    String smartContractBlobTvcBase64,
  );
  external dynamic deployContract(
    String keyPublic,
    String keySecret,
    String smartContractAbiSpec,
    String smartContractBlobTvcBase64,
  );
  external dynamic deriveKeyPair(String seedMnemonicPhrase, int wordsCount);
  external dynamic fetchAccountInformation(String accountAddress);
  external dynamic getDeployData(
    String keyPublic,
    String smartContractABI,
    String smartContractTVCBase64,
  );
  external dynamic generateMnemonicPhraseSeed(int wordsCount);
}

class TonClient extends AbstractTonClient {
  final _TONClientFacadeInterop _wrap;

  static const int SEED_LONG_PHRASE_WORDS_COUNT = 24;
  static const int SEED_SHORT_PHRASE_WORDS_COUNT = 12;

  static const String _KEYPAIR_PUBLIC_PROPERTY_NAME = "public";
  static const String _KEYPAIR_SECRET_PROPERTY_NAME = "secret";

  static const String _ACCOUNTINFO_BALANCE_PROPERTY_NAME = "balance";
  static const String _ACCOUNTINFO_CODEHASH_PROPERTY_NAME = "codeHash";

  static const String _DEPLOY_ACCOUNTID_PROPERTY_NAME = "accountId";
  static const String _DEPLOY_ADDRESS_PROPERTY_NAME = "address";
  static const String _DEPLOY_DATA_PROPERTY_NAME = "dataBase64";
  static const String _DEPLOY_IMAGE_PROPERTY_NAME = "imageBase64";

  static const String __FEES__GAS_FEE__PROPERTY_NAME = "gasFee";
  static const String __FEES__IN_MSG_FWD_FEE__PROPERTY_NAME = "inMsgFwdFee";
  static const String __FEES__OUT_MSG_FWD_FEE__PROPERTY_NAME = "outMsgsFwdFee";
  static const String __FEES__STORAGE_FEE__PROPERTY_NAME = "storageFee";
  static const String __FEES__TOTAL_ACCOUNT_FEES__PROPERTY_NAME =
      "totalAccountFees";
  static const String __FEES__TOTAL_OUTPUT__PROPERTY_NAME = "totalOutput";

  static const String _EXCEPTION_MESSAGE_PROPERTY_NAME = "message";

  TonClient() : this._wrap = _TONClientFacadeInterop() {}

  @override
  Future<void> init(ExecutionContext executionContext) async {
    await promiseToFuture(this._wrap.init());
    print("TonClient JS Interop was initalized");
  }

  @override
  Future<String> generateMnemonicPhraseSeed(SeedType seedType) {
    final int wordsCount = _resolveWordsCount(seedType);
    return promiseToFuture(this._wrap.generateMnemonicPhraseSeed(wordsCount));
  }

  @override
  Future<KeyPair> deriveKeys(
      String seedMnemonicPhraseSeed, SeedType seedType) async {
    final int wordsCount = _resolveWordsCount(seedType);
    final dynamic jsData = await promiseToFuture(
        this._wrap.deriveKeyPair(seedMnemonicPhraseSeed, wordsCount));
    if (!hasProperty(jsData, TonClient._KEYPAIR_PUBLIC_PROPERTY_NAME)) {
      throw InteropContractException(TonClient._KEYPAIR_PUBLIC_PROPERTY_NAME);
    }
    if (!hasProperty(jsData, TonClient._KEYPAIR_SECRET_PROPERTY_NAME)) {
      throw InteropContractException(TonClient._KEYPAIR_SECRET_PROPERTY_NAME);
    }
    return KeyPair(
      public: getProperty(jsData, TonClient._KEYPAIR_PUBLIC_PROPERTY_NAME),
      secret: getProperty(jsData, TonClient._KEYPAIR_SECRET_PROPERTY_NAME),
    );
  }

  @override
  Future<String> getDeployData(
    final String keyPublic,
    final String smartContractAbiSpec,
    final String smartContractBlobTvcBase64,
  ) async {
    // dynamic nativeJsObject = newObject();
    // setProperty(
    //     nativeJsObject, TonClient._KEYPAIR_PUBLIC_PROPERTY_NAME, keys.public);
    // setProperty(
    //     nativeJsObject, TonClient._KEYPAIR_SECRET_PROPERTY_NAME, keys.secret);
    try {
      final String jsData = await promiseToFuture(this._wrap.getDeployData(
            keyPublic,
            smartContractAbiSpec,
            smartContractBlobTvcBase64,
          ));

      // if (!hasProperty(jsData, TonClient._DEPLOY_ACCOUNTID_PROPERTY_NAME)) {
      //   throw InteropContractException(
      //       TonClient._DEPLOY_ACCOUNTID_PROPERTY_NAME);
      // }

      // if (!hasProperty(jsData, TonClient._DEPLOY_ADDRESS_PROPERTY_NAME)) {
      //   throw InteropContractException(TonClient._DEPLOY_ADDRESS_PROPERTY_NAME);
      // }

      // if (!hasProperty(jsData, TonClient._DEPLOY_DATA_PROPERTY_NAME)) {
      //   throw InteropContractException(TonClient._DEPLOY_DATA_PROPERTY_NAME);
      // }

      // if (!hasProperty(jsData, TonClient._DEPLOY_IMAGE_PROPERTY_NAME)) {
      //   throw InteropContractException(TonClient._DEPLOY_IMAGE_PROPERTY_NAME);
      // }

      // DeployData deployData = DeployData(
      //     accountId:
      //         getProperty(jsData, TonClient._DEPLOY_ACCOUNTID_PROPERTY_NAME),
      //     address: getProperty(jsData, TonClient._DEPLOY_ADDRESS_PROPERTY_NAME),
      //     dataBase64: getProperty(jsData, TonClient._DEPLOY_DATA_PROPERTY_NAME),
      //     imageBase64:
      //         getProperty(jsData, TonClient._DEPLOY_IMAGE_PROPERTY_NAME));

      return jsData;
    } catch (e) {
      throw TonClientException(
          getProperty(e, TonClient._EXCEPTION_MESSAGE_PROPERTY_NAME));
    }
  }

  @override
  Future<Fees> calcDeployFees(
    KeyPair keypair,
    final String smartContractAbiSpec,
    final String smartContractBlobTvcBase64,
  ) async {
    // dynamic nativeJsObject = newObject();
    // setProperty(
    //     nativeJsObject, TonClient._KEYPAIR_PUBLIC_PROPERTY_NAME, keys.public);
    // setProperty(
    //     nativeJsObject, TonClient._KEYPAIR_SECRET_PROPERTY_NAME, keys.secret);
    try {
      final dynamic jsData = await promiseToFuture(this._wrap.calcDeployFees(
            keypair.public,
            keypair.secret,
            smartContractAbiSpec,
            smartContractBlobTvcBase64,
          ));

      final String gasFee =
          getProperty(jsData, TonClient.__FEES__GAS_FEE__PROPERTY_NAME);
      final String inMsgFwdFee =
          getProperty(jsData, TonClient.__FEES__IN_MSG_FWD_FEE__PROPERTY_NAME);
      final String outMsgsFwdFee =
          getProperty(jsData, TonClient.__FEES__OUT_MSG_FWD_FEE__PROPERTY_NAME);
      final String storageFee =
          getProperty(jsData, TonClient.__FEES__STORAGE_FEE__PROPERTY_NAME);
      final String totalAccountFees = getProperty(
          jsData, TonClient.__FEES__TOTAL_ACCOUNT_FEES__PROPERTY_NAME);
      final String totalOutput =
          getProperty(jsData, TonClient.__FEES__TOTAL_OUTPUT__PROPERTY_NAME);

      return Fees(
        gasFee: gasFee,
        inMsgFwdFee: inMsgFwdFee,
        outMsgsFwdFee: outMsgsFwdFee,
        storageFee: storageFee,
        totalAccountFees: totalAccountFees,
        totalOutput: totalOutput,
      );
    } catch (e) {
      throw TonClientException(
          getProperty(e, TonClient._EXCEPTION_MESSAGE_PROPERTY_NAME));
    }
  }

  @override
  Future<dynamic> deployContract(
    final KeyPair keypair,
    final String smartContractAbiSpec,
    final String smartContractBlobTvcBase64,
  ) async {
    // dynamic nativeJsObject = newObject();
    // setProperty(
    //     nativeJsObject, TonClient._KEYPAIR_PUBLIC_PROPERTY_NAME, keys.public);
    // setProperty(
    //     nativeJsObject, TonClient._KEYPAIR_SECRET_PROPERTY_NAME, keys.secret);
    try {
      await promiseToFuture(this._wrap.deployContract(
            keypair.public,
            keypair.secret,
            smartContractAbiSpec,
            smartContractBlobTvcBase64,
          ));
    } catch (e) {
      throw TonClientException(
          getProperty(e, TonClient._EXCEPTION_MESSAGE_PROPERTY_NAME));
    }
  }

  @override
  Future<AccountInfo?> fetchAccountInformation(String accountAddress) async {
    try {
      final dynamic jsData = await promiseToFuture(
          this._wrap.fetchAccountInformation(accountAddress));

      if (jsData == null) {
        return null;
      }

      final String balance =
          getProperty(jsData, TonClient._ACCOUNTINFO_BALANCE_PROPERTY_NAME);
      final String? codeHash =
          getProperty(jsData, TonClient._ACCOUNTINFO_CODEHASH_PROPERTY_NAME);

      if (codeHash != null) {
        return DeployedAccountInfo(balance, codeHash);
      } else {
        return AccountInfo(balance);
      }
    } catch (e) {
      throw TonClientException(
          getProperty(e, TonClient._EXCEPTION_MESSAGE_PROPERTY_NAME));
    }
  }

  static int _resolveWordsCount(SeedType seedType) {
    int wordsCount;
    switch (seedType) {
      case SeedType.LONG:
        wordsCount = SEED_LONG_PHRASE_WORDS_COUNT;
        break;
      case SeedType.SHORT:
        wordsCount = SEED_SHORT_PHRASE_WORDS_COUNT;
        break;
      default:
        throw InvalidOperationException("Unsupported MnemonicPhraseLength.");
    }
    return wordsCount;
  }
}
