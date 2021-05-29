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

class Transaction {
//   {"transaction":{"__typename":"Transaction","aborted":false,"action":{"__typename":"TransactionAction","no_funds":false,"result_code":0,"success":true,"total_action_fees":"0x145850","total_fwd_fees":"0x1e8480","vali
// d":true},"compute":{"__typename":"TransactionCompute","exit_code":0,"gas_fees":"0xd856d0","skipped_reason":null,"success":true},"id":"ef555770e998a8af080b4972b155b965a49353ac1f0473b6ffe98cfce17a1801","in_msg":"bc9e
// 68b05dff526cd48cf27ea60aff34aa8ff5d1f110ee70638f432a49016623","now":1622227944,"out_messages":[{"__typename":"Message","body":null,"id":"a14c4d5ce0211c723b882aec3438ea1d4217baa5e9f3966405ac99930f89a82e","msg_type":
// 0,"value":"0x5f5e100"},{"__typename":"Message","body":"te6ccgEBAQEADgAAGJMdgs0AAAAAAAAAAA==","id":"59f71e701465704d1addd494516abd14b7b6fe3ac66e6886d017a4b6a37e3714","msg_type":2,"value":null}],"out_msgs":["a14c4d5c
// e0211c723b882aec3438ea1d4217baa5e9f3966405ac99930f89a82e","59f71e701465704d1addd494516abd14b7b6fe3ac66e6886d017a4b6a37e3714"],"status":3,"storage":{"__typename":"TransactionStorage","status_change":0,"storage_fees_
// collected":"0x40b6"},"total_fees":"0x114888e"},"output":{"transId":"0x0"},"fees":{"inMsgFwdFee":"0x2798b8","storageFee":"0x40b6","gasFee":"0xd856d0","outMsgsFwdFee":"0x1e8480","totalAccountFees":"0x11eb4be","totalO
// utput":"0x5f5e100"}}
  final String transactionId;

  Transaction(this.transactionId);
}
