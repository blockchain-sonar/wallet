@JS()
library tonclient;

import 'dart:convert';
import "dart:js_util" show getProperty, hasProperty, newObject, promiseToFuture;
import "package:freemework/freemework.dart"
    show ExecutionContext, FreemeworkException, InvalidOperationException;
import 'package:freeton_wallet/clients/tonclient/src/models/fees.dart';
import 'package:freeton_wallet/clients/tonclient/src/models/run_message.dart';
import 'package:freeton_wallet/clients/tonclient/src/models/transaction.dart';
import "package:js/js.dart";
import "package:js/js_util.dart"
    show getProperty, hasProperty, newObject, promiseToFuture, setProperty;
import "../contract.dart";
import "models/account_info.dart" show AccountInfo, DeployedAccountInfo;
import "models/key_pair.dart" show KeyPair;
import "../contract.dart"
    show AbstractTonClient, InteropViolationDataException, TonClientException;
import 'models/processing_state.dart';

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
  external dynamic createRunMessage(
    String keyPublic,
    String keySecret,
    String accountAddress,
    String smartContractAbiSpec,
    String methodName,
    String args,
  );
  external dynamic deployContract(
    String keyPublic,
    String keySecret,
    String smartContractAbiSpec,
    String smartContractBlobTvcBase64,
  );
  external dynamic deriveKeyPair(
    String seedMnemonicPhrase,
    int wordsCount,
  );
  external dynamic fetchAccountInformation(
    String accountAddress,
  );
  external dynamic getDeployData(
    String keyPublic,
    String smartContractABI,
    String smartContractTVCBase64,
  );
  external dynamic generateMnemonicPhraseSeed(
    int wordsCount,
  );
  // external dynamic sendTransaction(
  //   String keyPublic,
  //   String keySecret,
  //   String smartContractABI,
  //   String accountAddress,
  //   String destinationAddress,
  //   String amount,
  //   String comment,
  // );
  external dynamic sendMessage(
    String messageSendToken,
  );
  external dynamic waitForRunTransaction(
    String messageSendToken,
    String processingStateToken,
  );
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
  Future<Fees> calcDeployFees(
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
  Future<RunMessage> createRunMessage(
    KeyPair keypair,
    String accountAddress,
    String smartContractAbiSpec,
    String methodName,
    Map<String, dynamic> args,
  ) async {
    final String jsonArgs = jsonEncode(args);

    String jsonRunMessage =
        await TonClient._wrapCall<String>(this._wrap.createRunMessage(
              keypair.public,
              keypair.secret,
              accountAddress,
              smartContractAbiSpec,
              methodName,
              jsonArgs,
            ));

    final Map<String, dynamic> rawRunMessage = jsonDecode(jsonRunMessage);

    final Map<String, dynamic> message =
        TonClient._getInteropJsonProperty<Map<String, dynamic>>(
            rawRunMessage, "message");

    final String address =
        TonClient._getInteropJsonProperty<String>(message, "address");

    final String messageId =
        TonClient._getInteropJsonProperty<String>(message, "messageId");

    final String messageBodyBase64 =
        TonClient._getInteropJsonProperty<String>(message, "messageBodyBase64");

    final int expire =
        TonClient._getInteropJsonProperty<int>(message, "expire");

    return RunMessage(
      address,
      messageId,
      messageBodyBase64,
      expire,
      jsonRunMessage,
    );
  }

  @override
  Future<KeyPair> deriveKeys(
      String seedMnemonicPhraseSeed, SeedType seedType) async {
    final int wordsCount = _resolveWordsCount(seedType);
    final dynamic interopData = await TonClient._wrapCall(
      this._wrap.deriveKeyPair(seedMnemonicPhraseSeed, wordsCount),
    );
    return KeyPair(
      public: _getInteropDataProperty(
          interopData, TonClient._KEYPAIR_PUBLIC_PROPERTY_NAME),
      secret: _getInteropDataProperty(
          interopData, TonClient._KEYPAIR_SECRET_PROPERTY_NAME),
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

    final String jsData =
        await TonClient._wrapCall<String>(this._wrap.getDeployData(
              keyPublic,
              smartContractAbiSpec,
              smartContractBlobTvcBase64,
            ));

    return jsData;
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
  Future<String> generateMnemonicPhraseSeed(SeedType seedType) {
    final int wordsCount = _resolveWordsCount(seedType);
    return promiseToFuture(this._wrap.generateMnemonicPhraseSeed(wordsCount));
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

  @override
  Future<ProcessingState> sendMessage(String messageSendToken) async {
    String jsonProcessingState = await TonClient._wrapCall<String>(
        this._wrap.sendMessage(messageSendToken));

    final Map<String, dynamic> rawProcessingState =
        jsonDecode(jsonProcessingState);

    final String lastBlockId = TonClient._getInteropJsonProperty<String>(
        rawProcessingState, "lastBlockId");

    final int sendingTime = TonClient._getInteropJsonProperty<int>(
        rawProcessingState, "sendingTime");

    return ProcessingState(
      lastBlockId,
      sendingTime,
      jsonProcessingState,
    );
  }

  @override
  Future<Transaction> waitForRunTransaction(
    final String messageSendToken,
    final String processingStateToken,
  ) async {
    final dynamic interopData = await TonClient._wrapCall(
        this
            ._wrap
            .waitForRunTransaction(messageSendToken, processingStateToken));

    final dynamic feesInteropData =
        _getInteropDataProperty(interopData, "fees");

    final dynamic outputInteropData =
        _getInteropDataProperty(interopData, "output");

    final dynamic transactionInteropData =
        _getInteropDataProperty(interopData, "transaction");

       final String transactionId  = _getInteropDataProperty<String>(transactionInteropData, "transaction");

    final Transaction transaction = Transaction(transactionId);

    return transaction;
  }

  // @override
  // Future<void> sendTransaction(
  //   final KeyPair keypair,
  //   final String smartContractAbiSpec,
  //   final String sourceAddress,
  //   final String destinationAddress,
  //   final String amount,
  //   final String comment,
  // ) async {
  //   try {
  //     await promiseToFuture(this._wrap.sendTransaction(
  //           keypair.public,
  //           keypair.secret,
  //           smartContractAbiSpec,
  //           sourceAddress,
  //           destinationAddress,
  //           amount,
  //           comment,
  //         ));
  //   } catch (e) {
  //     throw TonClientException(
  //         getProperty(e, TonClient._EXCEPTION_MESSAGE_PROPERTY_NAME));
  //   }
  // }

  static T _getInteropJsonProperty<T>(
      final Map<String, dynamic> raw, final String name) {
    if (!raw.containsKey(name)) {
      throw InteropViolationDataException(
        name,
        "Missing requred property '${name}'",
      );
    }
    try {
      final T data = raw[name];
      return data;
    } catch (e) {
      throw InteropViolationDataException(
        name,
        "Unexpected value of property '${name}'. Expected type '${T}'.",
        FreemeworkException.wrapIfNeeded(e),
      );
    }
  }

  static T _getInteropDataProperty<T>(final Object o, final String name) {
    if (!hasProperty(o, name)) {
      throw InteropViolationDataException(
        name,
        "Missing requred property '${name}'",
      );
    }
    try {
      final T data = getProperty(o, name);
      return data;
    } catch (e) {
      throw InteropViolationDataException(
        name,
        "Unexpected value of property '${name}'. Expected type '${T}'.",
        FreemeworkException.wrapIfNeeded(e),
      );
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

  static Future<T> _wrapCall<T>(Object jsPromise) async {
    dynamic result;
    try {
      result = await promiseToFuture(jsPromise);
    } catch (e) {
      throw TonClientException(
        "General interop call failure",
        FreemeworkException.wrapIfNeeded(e),
      );
    }

    T friendlyResult;
    try {
      friendlyResult = result;
    } catch (e) {
      throw InteropViolationResultException(
        result,
        "Cannot cast interop call result to type '${T}'.",
        FreemeworkException.wrapIfNeeded(e),
      );
    }

    return friendlyResult;
  }
}
