# Free TON Wallet

Preconditions: [Flutter SDK](https://flutter.dev/docs) (2.2.1), [Dart](https://dart.dev/) (2.13.1), [NodeJS](https://nodejs.org/en/)

```
git submodule update --init && (cd submodule/wallet.platform.web/ && npm install && npm run build)
ln -sf index-webapp-devel.html web/index.html
flutter run --device-id chrome
```
---

## Builds

### Chrome Extenstion

```
ln -sf index-extenstion.html web/index.html
flutter build web --web-renderer html --release
```


## Getting Started

### Minimal Knowledge Check List

To develop this project you have to had minimal knowledge:

* [ ] - [Dart language](https://dart.dev/guides/language/language-tour)
* [ ] - [Simple app state management](https://flutter.dev/docs/development/data-and-backend/state-mgmt): ChangeNotifier, ChangeNotifierProvider, Consumer and Provider.


## TON Client

There are two third-patries `web/tonclient.js` and `web/tonclient.wasm` comming from [ton-client-js](https://github.com/tonlabs/ton-client-js).

To update these files execute following (on Linux):

```bash
curl --verbose http://sdkbinaries-ws.tonlabs.io/tonclient_0_wasm.gz | tee >(sha1sum > web/tonclient.wasm.gz.sha1) | gunzip | tee >(sha1sum > web/tonclient.wasm.sha1) > web/tonclient.wasm
```

```bash

```

```
curl --verbose http://sdkbinaries-ws.tonlabs.io/tonclient_0_wasm_js.gz | tee >(sha1sum > web/tonclient.js.gz.sha1) | gunzip | tee >(sha1sum > web/tonclient.js.sha1) > web/tonclient.js
```

```bash

```


## References

* [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
* [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)
