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

import "../../../../misc/ton_decimal.dart" show TonDecimal;

class AccountInfo {
  final TonDecimal balance;
  const AccountInfo(this.balance);
}

class DeployedAccountInfo extends AccountInfo {
  final String codeHash;
  const DeployedAccountInfo(TonDecimal balance, this.codeHash) : super(balance);
}
