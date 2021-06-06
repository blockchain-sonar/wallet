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

import 'package:flutter/material.dart' show Colors;
import 'package:flutter/widgets.dart'
    show
        AssetImage,
        BuildContext,
        Column,
        EdgeInsets,
        FontWeight,
        Image,
        Padding,
        StatelessWidget,
        Text,
        TextStyle,
        Widget;

class FWLogo128Widget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Image(image: AssetImage('assets/freeton-128.png')),
          Text(
            "Free TON Wallet",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 32,
              color: Colors.blueGrey,
            ),
          ),
        ],
      ),
    );
  }
}
