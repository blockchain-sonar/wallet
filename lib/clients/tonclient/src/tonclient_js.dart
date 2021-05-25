@JS()
library tonclient;

import 'dart:html';
import "dart:js_util" show getProperty, hasProperty, newObject, promiseToFuture;
import "package:freemework/freemework.dart"
    show ExecutionContext, FreemeworkException, InvalidOperationException;
import "package:js/js.dart";
import "package:js/js_util.dart"
    show getProperty, hasProperty, newObject, promiseToFuture, setProperty;
import '../contract.dart';
import 'models/account_info.dart';
import 'models/keypair.dart' show KeyPair;
import '../contract.dart'
    show AbstractTonClient, InteropContractException, TonClientException;

// The `TONClientFacade` constructor invokes JavaScript `new window.TONClientFacade()`
@JS("TONClientFacade")
class _TONClientFacadeInterop {
  external _TONClientFacadeInterop();
  external dynamic init();
  external dynamic generateMnemonicPhraseSeed(int wordsCount);
  external dynamic deriveKeyPair(String seedMnemonicPhrase, int wordsCount);
  external dynamic getDeployData(
    String publicKey,
    String smartContractABI,
    String smartContractTVCBase64,
  );
  external dynamic calcDeployFees(dynamic keys);
  external dynamic deployContract(dynamic keys);
  external dynamic fetchAccountInformation(String accountAddress);
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
    String publicKey,
    String smartContractABI,
    String smartContractTVCBase64,
  ) async {
    // dynamic nativeJsObject = newObject();
    // setProperty(
    //     nativeJsObject, TonClient._KEYPAIR_PUBLIC_PROPERTY_NAME, keys.public);
    // setProperty(
    //     nativeJsObject, TonClient._KEYPAIR_SECRET_PROPERTY_NAME, keys.secret);
    try {
      final String jsData = await promiseToFuture(this._wrap.getDeployData(
            publicKey,
            smartContractABI,
            smartContractTVCBase64,
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
  Future<dynamic> calcDeployFees(KeyPair keys) async {
    dynamic nativeJsObject = newObject();
    setProperty(
        nativeJsObject, TonClient._KEYPAIR_PUBLIC_PROPERTY_NAME, keys.public);
    setProperty(
        nativeJsObject, TonClient._KEYPAIR_SECRET_PROPERTY_NAME, keys.secret);
    try {
      final dynamic jsData =
          await promiseToFuture(this._wrap.calcDeployFees(nativeJsObject));
      return jsData;
    } catch (e) {
      throw TonClientException(
          getProperty(e, TonClient._EXCEPTION_MESSAGE_PROPERTY_NAME));
    }
  }

  @override
  Future<dynamic> deployContract(KeyPair keys) async {
    dynamic nativeJsObject = newObject();
    setProperty(
        nativeJsObject, TonClient._KEYPAIR_PUBLIC_PROPERTY_NAME, keys.public);
    setProperty(
        nativeJsObject, TonClient._KEYPAIR_SECRET_PROPERTY_NAME, keys.secret);
    try {
      final dynamic jsData =
          await promiseToFuture(this._wrap.deployContract(nativeJsObject));
      return jsData;
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

      if(jsData == null) {
        return null;
      }

      final String balance =
          getProperty(jsData, TonClient._ACCOUNTINFO_BALANCE_PROPERTY_NAME);
      final String codeHash =
          getProperty(jsData, TonClient._ACCOUNTINFO_CODEHASH_PROPERTY_NAME);

      return AccountInfo(balance, codeHash);
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
