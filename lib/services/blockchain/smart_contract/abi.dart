//
// Copyright 2021 Free TON Wallet Team
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// 	http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

//import "package:decimal/decimal.dart";
import 'dart:convert';

import "package:freemework/ExecutionContext.dart";
import "package:freemework/freemework.dart";
import 'package:freeton_wallet/misc/ton_decimal.dart';

import "../../../data/account.dart" show Account;

import "abi/safemultisigwallet_20200501.dart" show ABI__SAFE_MULTISIG_20200501;
import "abi/setcodemultisigwallet_20200506.dart"
    show ABI__SETCODE_MULTISIG_20200506;

abstract class SmartContactRuntime {
  Future<RunMessage> createRunMessage(
    ExecutionContext ectx,
    Account account,
    String methodName,
    Map<String, dynamic> args,
  );
  Future<ProcessingState> sendMessage(
    ExecutionContext ectx, {
    required String messageSendToken,
  });
  Future<Transaction> waitForRunTransaction(
    ExecutionContext ectx, {
    required String messageSendToken,
    required String processingStateToken,
  });
}

class RunMessage {
  final String address;
  final String messageId;
  final String messageBodyBase64;
  final int expire;
  final String messageSendToken;

  RunMessage(this.address, this.messageId, this.messageBodyBase64, this.expire,
      this.messageSendToken);
}

class ProcessingState {
  final String lastBlockId;
  final int sendingTime;
  final String processingStateToken;

  ProcessingState(
      this.lastBlockId, this.sendingTime, this.processingStateToken);
}

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

abstract class SmartContractAbi {
  static const List<SmartContractAbi> ALL = <SmartContractAbi>[
    SafeMultisigWalletAbi.instance,
    SetcodeMultisigWalletAbi.instance,
  ];

  final String spec;
  final String name;
  final String version;
  final String descriptionShort;
  final String descriptionLongMarkdown;
  Uri? get referenceUri {
    final String? referenceUri = this._referenceUri;
    return referenceUri != null ? Uri.parse(referenceUri) : null;
  }

  Future<ProcessingState> sendMessage(
    final ExecutionContext ectx,
    final SmartContactRuntime contactRuntime, {
    required String messageSendToken,
  }) =>
      contactRuntime.sendMessage(
        ectx,
        messageSendToken: messageSendToken,
      );

  Future<Transaction> waitForRunTransaction(
    final ExecutionContext ectx,
    final SmartContactRuntime contactRuntime, {
    required String messageSendToken,
    required String processingStateToken,
  }) =>
      contactRuntime.waitForRunTransaction(
        ectx,
        messageSendToken: messageSendToken,
        processingStateToken: processingStateToken,
      );

  final String? _referenceUri;

  const SmartContractAbi._(
    this.spec,
    this.name,
    this.version,
    this.descriptionShort,
    this.descriptionLongMarkdown,
    this._referenceUri,
  );
}

class SafeMultisigWalletAbi extends SmartContractAbi with WalletAbi {
  static const SafeMultisigWalletAbi instance = SafeMultisigWalletAbi._();

  const SafeMultisigWalletAbi._()
      : super._(
          ABI__SAFE_MULTISIG_20200501,
          "SafeMultisig",
          "v20200501",
          "Safe Multisig",
          "Safe Multisig",
          "https://github.com/tonlabs/ton-labs-contracts/tree/776bc3d614ded58330577167313a9b4f80767f41/solidity/safemultisig",
        );
}

class SetcodeMultisigWalletAbi extends SmartContractAbi with WalletAbi {
  static const SetcodeMultisigWalletAbi instance = SetcodeMultisigWalletAbi._();

  const SetcodeMultisigWalletAbi._()
      : super._(
          ABI__SETCODE_MULTISIG_20200506,
          "SetcodeMultisig",
          "v20200506",
          "Setcode Multisig",
          "Setcode Multisig",
          "https://github.com/tonlabs/ton-labs-contracts/tree/b79bf98b89ae95b714fbcf55eb43ea22516c4788/solidity/setcodemultisig",
        );
}

mixin WalletAbi on SmartContractAbi {
  // 	{
  // 	"name": "sendTransaction",
  // 	"inputs": [
  // 		{"name":"dest","type":"address"},
  // 		{"name":"value","type":"uint128"},
  // 		{"name":"bounce","type":"bool"},
  // 		{"name":"flags","type":"uint8"},
  // 		{"name":"payload","type":"cell"}
  // 	],
  // 	"outputs": [
  // 	]
  // },
  Future<RunMessage> walletRegisterTransaction(
    final ExecutionContext ectx,
    final SmartContactRuntime contactRuntime,
    final Account account, {
    required final String dest,
    required final TonDecimal value,
    required final bool bounce,
    required final int flags,
    required final dynamic payload,
  }) async {
    final CancellationToken cancellationToken = ectx.cancellationToken;

    final String nanoValue = value.nanoDec;

    final Map<String, dynamic> args = <String, dynamic>{
      "dest": dest,
      "value": nanoValue,
      "bounce": bounce,
      "payload": payload,
      "allBalance": false, // required by underlaying lib
    };

    cancellationToken.throwIfCancellationRequested();
    final RunMessage runMessage = await contactRuntime.createRunMessage(
      ectx,
      account,
      "submitTransaction",
      args,
    );

    return runMessage;
  }
}
