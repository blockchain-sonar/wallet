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

import 'dart:convert' show base64Encode;

import "package:flutter/widgets.dart" show ChangeNotifier;
import 'package:freeton_wallet/data/account_info.dart';

import "blockchain/blockchain.dart"
    show
        BlockchainService,
        SmartContractAbi,
        SmartContractBlob,
        SmartContractKeeper;
import "encrypted_db_service.dart"
    show Account, AccountType, EncryptedDbService, KeypairBundle;

abstract class Job extends ChangeNotifier {
  Future<void>? _future;
  Object? _failureError;

  Future<void> get future {
    assert(this._future != null,
        "Cannot access 'jobFuture'. Did you start the job?");
    return this._future!.whenComplete(() {
      // if (_failureError != null) {
      //   throw this._failureError!;
      // }
    });
  }

  void _run() async {
    assert(this._future == null, "Cannot start job ${this.runtimeType} twice");

    print("${this.runtimeType} started");
    Future<void> future = _doJob();
    future.then((_) {
      print("${this.runtimeType} completed");
    }).onError((Object error, StackTrace stackTrace) {
      this._failureError = error;
      print("${this.runtimeType} failure");
    }).whenComplete(() {});

    this._future = future;
  }

  Future<void> _doJob();

  Job._() : this._future = null;
}

///
/// AccountsActivationJob trying to activate(detect) accounts for each known contract
///
class AccountsActivationJob extends Job {
  final KeypairBundle keypairBundle;
  final BlockchainService _blockchainService;
  final EncryptedDbService _encryptedDbService;

  @override
  Future<void> _doJob() async {
    for (final SmartContractBlob smartContractBlob
        in SmartContractKeeper.instance.all) {
      //
      final SmartContractAbi smartContractAbi = smartContractBlob.abi;
      final String tvcBase64 = base64Encode(smartContractBlob.tvc);

      final String accountAddress =
          await this._blockchainService.resolveAccountAddress(
                this.keypairBundle.keyPublic,
                smartContractAbi.spec,
                tvcBase64,
              );

      final AccountInfo accountData =
          await this._blockchainService.fetchAccountInformation(accountAddress);

      final AccountType accountType = accountData.isSmartContractDeployed
          ? AccountType.ACTIVE
          : AccountType.UNINITIALIZED;

      final String balance = accountData.balance;

      keypairBundle.setAccount(
        smartContractBlob.fullQualifiedName,
        accountAddress,
        accountType,
        balance,
      );
    }
  }

  AccountsActivationJob._(
    this.keypairBundle, {
    required BlockchainService blockchainService,
    required EncryptedDbService encryptedDbService,
  })   : this._blockchainService = blockchainService,
        this._encryptedDbService = encryptedDbService,
        super._();
}

///
/// JobService is a manager of background jobs
///
abstract class JobService {
  AccountsActivationJob? fetchAccountsActivationJob(
    KeypairBundle keypairBundle,
  );

  /// Register a new KeypairActivationJob (or fetch is active)
  AccountsActivationJob registerAccountsActivationJob(
    KeypairBundle keypairBundle,
  );
}

class JobServiceImpl extends JobService {
  final BlockchainService blockchainService;
  final EncryptedDbService encryptedDbService;

  JobServiceImpl({
    required this.blockchainService,
    required this.encryptedDbService,
  }) : this._accountActivationJobs =
            Map<KeypairBundle, AccountsActivationJob>();

  @override
  AccountsActivationJob? fetchAccountsActivationJob(
    KeypairBundle keypairBundle,
  ) {
    final AccountsActivationJob? existingJob =
        this._accountActivationJobs[keypairBundle];

    return existingJob;
  }

  @override
  AccountsActivationJob registerAccountsActivationJob(
    KeypairBundle keypairBundle,
  ) {
    if (this._accountActivationJobs.containsKey(keypairBundle)) {
      throw StateError(
          "Cannot register AccountsActivationJob for same KeypairBundle twice. Try to fetchAccountsActivationJob instead.");
    }

    final AccountsActivationJob job = AccountsActivationJob._(
      keypairBundle,
      blockchainService: this.blockchainService,
      encryptedDbService: this.encryptedDbService,
    );

    this._accountActivationJobs[keypairBundle] = job;

    job._run();
    job.future.whenComplete(() {
      this._accountActivationJobs.remove(keypairBundle);
    });

    return job;
  }

  final Map<KeypairBundle, AccountsActivationJob> _accountActivationJobs;
}
