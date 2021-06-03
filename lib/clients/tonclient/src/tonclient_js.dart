@JS()
library tonclient;

import "dart:convert" show jsonDecode, jsonEncode;
import "dart:js_util"
    show getProperty, hasProperty, newObject, promiseToFuture, setProperty;
import "package:freemework/freemework.dart"
    show ExecutionContext, FreemeworkException, InvalidOperationException;
import "package:js/js.dart" show JS;

import "../contract.dart"
    show
        AbstractTonClient,
        InteropViolationDataException,
        InteropViolationResultException,
        SeedType,
        TonClientException;
import "../../../misc/ton_decimal.dart" show TonDecimal;

import "models/account_info.dart" show AccountInfo, DeployedAccountInfo;
import "models/fees.dart" show Fees;
import "models/key_pair.dart" show KeyPair;
import "models/processing_state.dart" show ProcessingState;
import "models/run_message.dart" show RunMessage;
import "models/transaction.dart" show Transaction;

// The `TONClientFacade` constructor invokes JavaScript `new window["freeton_wallet_platform"]`
// @JS("freeton_wallet_platform.TONClientFacade")
// external _TONClientFacadeInterop tonClientFacadeFactory();

@JS("freeton_wallet_platform.TONClientFacade")
class _TONClientFacadeInterop {
  external _TONClientFacadeInterop(dynamic opts);
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

  /// "m/44'/396'/0'/0/0"
  external dynamic deriveKeyPair(
    List<String> seedMnemonicWords,
    String hdpath,
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

  // static const String _DEPLOY_ACCOUNTID_PROPERTY_NAME = "accountId";
  // static const String _DEPLOY_ADDRESS_PROPERTY_NAME = "address";
  // static const String _DEPLOY_DATA_PROPERTY_NAME = "dataBase64";
  // static const String _DEPLOY_IMAGE_PROPERTY_NAME = "imageBase64";

  static const String __FEES__GAS_FEE__PROPERTY_NAME = "gasFee";
  static const String __FEES__IN_MSG_FWD_FEE__PROPERTY_NAME = "inMsgFwdFee";
  static const String __FEES__OUT_MSG_FWD_FEE__PROPERTY_NAME = "outMsgsFwdFee";
  static const String __FEES__STORAGE_FEE__PROPERTY_NAME = "storageFee";
  static const String __FEES__TOTAL_ACCOUNT_FEES__PROPERTY_NAME =
      "totalAccountFees";
  static const String __FEES__TOTAL_OUTPUT__PROPERTY_NAME = "totalOutput";

  static const String _EXCEPTION_MESSAGE_PROPERTY_NAME = "message";

  static _TONClientFacadeInterop _createTONClientFacadeInterop() {
    dynamic optsJsObject = newObject();

    setProperty(optsJsObject, "logger", "console");
    setProperty(optsJsObject, "servers", <String>["net.ton.dev"]);

    return _TONClientFacadeInterop(optsJsObject);
  }

  TonClient() : this._wrap = _createTONClientFacadeInterop() {}

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

    final dynamic jsData = await promiseToFuture(this._wrap.calcDeployFees(
          keypair.public,
          keypair.secret,
          smartContractAbiSpec,
          smartContractBlobTvcBase64,
        ));

    final String gasFee = _getInteropDataProperty(
        jsData, TonClient.__FEES__GAS_FEE__PROPERTY_NAME);
    final String inMsgFwdFee = _getInteropDataProperty(
        jsData, TonClient.__FEES__IN_MSG_FWD_FEE__PROPERTY_NAME);
    final String outMsgsFwdFee = _getInteropDataProperty(
        jsData, TonClient.__FEES__OUT_MSG_FWD_FEE__PROPERTY_NAME);
    final String storageFee = _getInteropDataProperty(
        jsData, TonClient.__FEES__STORAGE_FEE__PROPERTY_NAME);
    final String totalAccountFees = _getInteropDataProperty(
        jsData, TonClient.__FEES__TOTAL_ACCOUNT_FEES__PROPERTY_NAME);
    final String totalOutput = _getInteropDataProperty(
        jsData, TonClient.__FEES__TOTAL_OUTPUT__PROPERTY_NAME);

    return Fees(
      gasFee: TonDecimal.parseNanoHex(gasFee),
      inMsgFwdFee: TonDecimal.parseNanoHex(inMsgFwdFee),
      outMsgsFwdFee: TonDecimal.parseNanoHex(outMsgsFwdFee),
      storageFee: TonDecimal.parseNanoHex(storageFee),
      totalAccountFees: TonDecimal.parseNanoHex(totalAccountFees),
      totalOutput: TonDecimal.parseNanoHex(totalOutput),
    );
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
    List<String> seedMnemonicWords,
    String hdpath,
  ) async {
    final dynamic interopData = await TonClient._wrapCall<dynamic>(
      this._wrap.deriveKeyPair(seedMnemonicWords, hdpath),
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
  Future<void> deployContract(
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
      await TonClient._wrapCall<dynamic>(this._wrap.deployContract(
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
  Future<List<String>> generateMnemonicPhraseSeed(SeedType seedType) async {
    final int wordsCount = _resolveWordsCount(seedType);
    final dynamic jsArray = await TonClient._wrapCall<dynamic>(
        this._wrap.generateMnemonicPhraseSeed(wordsCount));

    final List<String> words = <String>[];
    for (int i = 0; i < jsArray.length; ++i) {
      final String word = jsArray[i];
      words.add(word);
    }
    return words;
  }

  @override
  Future<AccountInfo?> fetchAccountInformation(String accountAddress) async {
    final dynamic jsData = await TonClient._wrapCall<dynamic>(
        this._wrap.fetchAccountInformation(accountAddress));

    if (jsData == null) {
      return null;
    }

    final String balance = _getInteropDataProperty(
        jsData, TonClient._ACCOUNTINFO_BALANCE_PROPERTY_NAME);
    final String? codeHash = _getInteropDataProperty(
        jsData, TonClient._ACCOUNTINFO_CODEHASH_PROPERTY_NAME);

    if (codeHash != null) {
      return DeployedAccountInfo(TonDecimal.parseNanoDec(balance), codeHash);
    } else {
      return AccountInfo(TonDecimal.parseNanoDec(balance));
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
    final dynamic interopData = await TonClient._wrapCall<dynamic>(this
        ._wrap
        .waitForRunTransaction(messageSendToken, processingStateToken));

    // final dynamic feesInteropData =
    //     _getInteropDataProperty(interopData, "fees");

    // final dynamic outputInteropData =
    //     _getInteropDataProperty(interopData, "output");

    final dynamic transactionInteropData =
        _getInteropDataProperty(interopData, "transaction");

    final String transactionId =
        _getInteropDataProperty<String>(transactionInteropData, "id");

    final Transaction transaction = Transaction(transactionId);

    return transaction;
  }

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
