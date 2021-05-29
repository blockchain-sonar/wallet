// Copyright 2021 Free TON Wallet Team

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

// 	http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

class RunMessage {
// {"address":"0:6be61c4f8ff0a64d852b14fd7b091184eeefd28ac650c393712d252c53e3e238","abi":{"ABI
// version":2,"header":["pubkey","time","expire"],"functions":[{"name":"constructor","inputs":[{"name":"owners","type":"uint256[]"},{"name":"reqConfirms","type":"uint8"}],"outputs":[]},{"name":"acceptTransfer","inputs
// ":[{"name":"payload","type":"bytes"}],"outputs":[]},{"name":"sendTransaction","inputs":[{"name":"dest","type":"address"},{"name":"value","type":"uint128"},{"name":"bounce","type":"bool"},{"name":"flags","type":"uin
// t8"},{"name":"payload","type":"cell"}],"outputs":[]},{"name":"submitTransaction","inputs":[{"name":"dest","type":"address"},{"name":"value","type":"uint128"},{"name":"bounce","type":"bool"},{"name":"allBalance","ty
// pe":"bool"},{"name":"payload","type":"cell"}],"outputs":[{"name":"transId","type":"uint64"}]},{"name":"confirmTransaction","inputs":[{"name":"transactionId","type":"uint64"}],"outputs":[]},{"name":"isConfirmed","in
// puts":[{"name":"mask","type":"uint32"},{"name":"index","type":"uint8"}],"outputs":[{"name":"confirmed","type":"bool"}]},{"name":"getParameters","inputs":[],"outputs":[{"name":"maxQueuedTransactions","type":"uint8"}
// ,{"name":"maxCustodianCount","type":"uint8"},{"name":"expirationTime","type":"uint64"},{"name":"minValue","type":"uint128"},{"name":"requiredTxnConfirms","type":"uint8"},{"name":"requiredUpdConfirms","type":"uint8"
// }]},{"name":"getTransaction","inputs":[{"name":"transactionId","type":"uint64"}],"outputs":[{"components":[{"name":"id","type":"uint64"},{"name":"confirmationsMask","type":"uint32"},{"name":"signsRequired","type":"
// uint8"},{"name":"signsReceived","type":"uint8"},{"name":"creator","type":"uint256"},{"name":"index","type":"uint8"},{"name":"dest","type":"address"},{"name":"value","type":"uint128"},{"name":"sendFlags","type":"uin
// t16"},{"name":"payload","type":"cell"},{"name":"bounce","type":"bool"}],"name":"trans","type":"tuple"}]},{"name":"getTransactions","inputs":[],"outputs":[{"components":[{"name":"id","type":"uint64"},{"name":"confir
// mationsMask","type":"uint32"},{"name":"signsRequired","type":"uint8"},{"name":"signsReceived","type":"uint8"},{"name":"creator","type":"uint256"},{"name":"index","type":"uint8"},{"name":"dest","type":"address"},{"n
// ame":"value","type":"uint128"},{"name":"sendFlags","type":"uint16"},{"name":"payload","type":"cell"},{"name":"bounce","type":"bool"}],"name":"transactions","type":"tuple[]"}]},{"name":"getTransactionIds","inputs":[
// ],"outputs":[{"name":"ids","type":"uint64[]"}]},{"name":"getCustodians","inputs":[],"outputs":[{"components":[{"name":"index","type":"uint8"},{"name":"pubkey","type":"uint256"}],"name":"custodians","type":"tuple[]"
// }]},{"name":"submitUpdate","inputs":[{"name":"codeHash","type":"uint256"},{"name":"owners","type":"uint256[]"},{"name":"reqConfirms","type":"uint8"}],"outputs":[{"name":"updateId","type":"uint64"}]},{"name":"confir
// mUpdate","inputs":[{"name":"updateId","type":"uint64"}],"outputs":[]},{"name":"executeUpdate","inputs":[{"name":"updateId","type":"uint64"},{"name":"code","type":"cell"}],"outputs":[]},{"name":"getUpdateRequests","
// inputs":[],"outputs":[{"components":[{"name":"id","type":"uint64"},{"name":"index","type":"uint8"},{"name":"signs","type":"uint8"},{"name":"confirmationsMask","type":"uint32"},{"name":"creator","type":"uint256"},{"
// name":"codeHash","type":"uint256"},{"name":"custodians","type":"uint256[]"},{"name":"reqConfirms","type":"uint8"}],"name":"updates","type":"tuple[]"}]}],"data":[],"events":[{"name":"TransferAccepted","inputs":[{"na
// me":"payload","type":"bytes"}],"outputs":[]}]},"functionName":"submitTransaction","message":{"address":"0:6be61c4f8ff0a64d852b14fd7b091184eeefd28ac650c393712d252c53e3e238","messageId":"bc9e68b05dff526cd48cf27ea60af
// f34aa8ff5d1f110ee70638f432a49016623","messageBodyBase64":"te6ccgEBBAEA0QABRYgA18w4nx/hTJsKVin69hIjCd3fpRWMoYcm4lpKWKfHxHAMAQHhgSjmEQF7SFkopCWpsgG5dBfU4nOrmQuuTrThriDxzRjxSrcoWJQyTkIE3woK+b4BjNU3WxYoLhf1bqdDC3UKANeE
// bpDgdSWxPm90QhmSl+RG02p3FfOXQp4wjPGSSIg6AAAAXm0Ue3aYLE8ChMdgs2ACAWOAEO7AJ82ls/J5+Jc5snyoAFjCUgo/ore3trOCodfyLRxAAAAAAAAAAAAAAAAAvrwgBAMAAA==","expire":1622227978}}

  final String address;
  final String messageId;
  final String messageBodyBase64;
  final int expire;
  final String messageSendToken;

  RunMessage(this.address, this.messageId, this.messageBodyBase64, this.expire,
      this.messageSendToken);
}
