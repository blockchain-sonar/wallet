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

class ProcessingState {
  // {"lastBlockId":"f210f3b713208c0c7430becd793fe601b156aadd10767bd3ef058afcd94cfc6d","sendingTime":1622227939}

  final String lastBlockId;
  final int sendingTime;
  final String processingStateToken;

  ProcessingState(
      this.lastBlockId, this.sendingTime, this.processingStateToken);
}
