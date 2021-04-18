@JS()
library tonclient;

import "dart:js_util" show promiseToFuture;

import "package:freemework/freemework.dart" show ExecutionContext;
import "package:js/js.dart";

import "tonclient_contract.dart" show AbstractTonClient;

// The `TONClientFacade` constructor invokes JavaScript `new window.TONClientFacade()`
@JS("TONClientFacade")
class _TONClientFacadeInterop {
  external _TONClientFacadeInterop();
  external dynamic init();
  external dynamic generateMnemonicPhrase();
}

class TonClient extends AbstractTonClient {
  final _TONClientFacadeInterop _wrap;

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
}
