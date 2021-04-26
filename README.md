# Free TON Wallet

Preconditions: [Flutter SDK](https://flutter.dev/docs) (2.0.2), [Dart](https://dart.dev/) (2.12.1)

```
ln -sf index-webapp.html web/index.html
flutter run --device-id chrome
```

---

https://freetonwallet.pages.zxteam.net/wallet

## Builds

### Chrome Extenstion

```
ln -sf index-extension.html web/index.html
flutter build web --web-renderer html
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
