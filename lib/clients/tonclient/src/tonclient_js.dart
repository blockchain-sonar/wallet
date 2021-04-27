@JS()
library tonclient;

import 'dart:html';
import "dart:js_util" show getProperty, hasProperty, newObject, promiseToFuture;
import "package:freemework/freemework.dart"
    show ExecutionContext, FreemeworkException;
import 'package:freeton_wallet/clients/tonclient/src/models/deployData.dart';
import "package:js/js.dart";
import "package:js/js_util.dart"
    show getProperty, hasProperty, newObject, promiseToFuture, setProperty;
import "models/keyPair.dart" show KeyPair;
import "tonclient_contract.dart" show AbstractTonClient;

// The `TONClientFacade` constructor invokes JavaScript `new window.TONClientFacade()`
@JS("TONClientFacade")
class _TONClientFacadeInterop {
  external _TONClientFacadeInterop();
  external dynamic init();
  external dynamic generateMnemonicPhrase();
  external dynamic deriveKeyPair(String seedMnemonicPhrase);
  external dynamic getDeployData(dynamic keys);
  external dynamic calcDeployFees(dynamic keys);
  external dynamic deployContract(dynamic keys);
  external dynamic getAccountData(String address);
}

class TonClient extends AbstractTonClient {
  final _TONClientFacadeInterop _wrap;

  static const String _KEYPAIR_PUBLIC_PROPERTY_NAME = "public";
  static const String _KEYPAIR_SECRET_PROPERTY_NAME = "secret";

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
  Future<String> generateMnemonicPhrase() {
    return promiseToFuture(this._wrap.generateMnemonicPhrase());
  }

  @override
  Future<KeyPair> deriveKeys(String seedMnemonicPhrase) async {
    final dynamic jsData =
        await promiseToFuture(this._wrap.deriveKeyPair(seedMnemonicPhrase));
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
  Future<TonDeployData> getDeployData(KeyPair keys) async {
    dynamic nativeJsObject = newObject();
    setProperty(
        nativeJsObject, TonClient._KEYPAIR_PUBLIC_PROPERTY_NAME, keys.public);
    setProperty(
        nativeJsObject, TonClient._KEYPAIR_SECRET_PROPERTY_NAME, keys.secret);
    try {
      final dynamic jsData =
          await promiseToFuture(this._wrap.getDeployData(nativeJsObject));

      if (!hasProperty(jsData, TonClient._DEPLOY_ACCOUNTID_PROPERTY_NAME)) {
        throw InteropContractException(
            TonClient._DEPLOY_ACCOUNTID_PROPERTY_NAME);
      }

      if (!hasProperty(jsData, TonClient._DEPLOY_ADDRESS_PROPERTY_NAME)) {
        throw InteropContractException(TonClient._DEPLOY_ADDRESS_PROPERTY_NAME);
      }

      if (!hasProperty(jsData, TonClient._DEPLOY_DATA_PROPERTY_NAME)) {
        throw InteropContractException(TonClient._DEPLOY_DATA_PROPERTY_NAME);
      }

      if (!hasProperty(jsData, TonClient._DEPLOY_IMAGE_PROPERTY_NAME)) {
        throw InteropContractException(TonClient._DEPLOY_IMAGE_PROPERTY_NAME);
      }

      TonDeployData deployData = TonDeployData(
          accountId:
              getProperty(jsData, TonClient._DEPLOY_ACCOUNTID_PROPERTY_NAME),
          address: getProperty(jsData, TonClient._DEPLOY_ADDRESS_PROPERTY_NAME),
          dataBase64: getProperty(jsData, TonClient._DEPLOY_DATA_PROPERTY_NAME),
          imageBase64:
              getProperty(jsData, TonClient._DEPLOY_IMAGE_PROPERTY_NAME));

      return deployData;
    } catch (e) {
      throw TonException(
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
      throw TonException(
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
      throw TonException(
          getProperty(e, TonClient._EXCEPTION_MESSAGE_PROPERTY_NAME));
    }
  }

  @override
  Future<dynamic> getAccountData(String address) async {
    try {
      final dynamic jsData =
          await promiseToFuture(this._wrap.getAccountData(address));
      return jsData;
    } catch (e) {
      throw TonException(
          getProperty(e, TonClient._EXCEPTION_MESSAGE_PROPERTY_NAME));
    }
  }
}

class TonException extends FreemeworkException {
  TonException([String? message, FreemeworkException? innerException])
      : super(message, innerException);
}

class InteropContractException extends TonException {
  final String property;
  InteropContractException(
    this.property, [
    String? message,
    FreemeworkException? innerException,
  ]) : super(message, innerException);
}
