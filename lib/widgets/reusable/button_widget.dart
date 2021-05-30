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

import "package:flutter/material.dart"
    show
        Center,
        Colors,
        FloatingActionButton,
        FontWeight,
        Icon,
        Icons,
        Key,
        SizedBox,
        Text,
        TextButton,
        TextStyle,
        VoidCallback;

class FWButton extends TextButton {
  FWButton(
    String text, {
    Key? key,
    required VoidCallback onPressed,
    VoidCallback? onLongPress,
  }) : super(
          key: key,
          onPressed: onPressed,
          onLongPress: onLongPress,
          child: SizedBox(
            height: 48,
            child: Center(
              child: Text(
                text,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          style: TextButton.styleFrom(
            primary: Colors.white,
            backgroundColor: Colors.blue,
          ),
        );
}

class FWCancelFloatingActionButton extends FloatingActionButton {
  FWCancelFloatingActionButton({
    required VoidCallback onPressed,
  }) : super(
          onPressed: onPressed,
          tooltip: "Cancel",
          child: Icon(Icons.cancel),
        );
}
