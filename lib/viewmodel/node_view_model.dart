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

import "package:flutter/widgets.dart" show ChangeNotifier, Color, IconData;

import "../model/node_model.dart" show NodeModel;

class NodeViewModel extends ChangeNotifier {
  final NodeModel _nodeModel;

  NodeViewModel(this._nodeModel);

  String get nodeId => this._nodeModel.nodeId;
  String get name => this._nodeModel.name;
  List<String> get servers => this._nodeModel.serverHosts;
  Color get color => this._nodeModel.color;
  IconData get coinIcon => this._nodeModel.coinIcon;
}
