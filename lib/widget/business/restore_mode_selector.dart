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

import "package:flutter/material.dart" show Colors, Icons;
import "package:flutter/widgets.dart"
    show
        BorderRadius,
        BoxDecoration,
        BuildContext,
        Center,
        Column,
        Container,
        EdgeInsets,
        FontWeight,
        Icon,
        Padding,
        Radius,
        Text,
        TextStyle,
        Widget;
import "package:freemework_cancellation/freemework_cancellation.dart"
    show CancellationTokenSource;

import "../reusable/button_widget.dart" show FWButton;
import "../toolchain/dialog_widget.dart"
    show DialogActionContentWidget, DialogCallback;

class RestoreModeSelectorContext {
  RestoreModeSelectorContext();
}

class RestoreModeSelectorWidget
    extends DialogActionContentWidget<RestoreModeSelectorContext> {
  @override
  Widget buildActive(
    BuildContext context, {
    DialogCallback<RestoreModeSelectorContext> onComplete,
  }) {
    return Container(
      color: Colors.grey,
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(
                  const Radius.circular(3.0),
                ),
              ),
              // color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Center(
                  child: Column(
                    children: <Widget>[
                      Icon(Icons.access_alarms_outlined),
                      FWButton(
                        "Active111",
                        onPressed: () {
                          onComplete(RestoreModeSelectorContext());
                        },
                      ),
                      Text(
                        "Recommend new users to use",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                          color: Colors.blueGrey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          FWButton(
            "Active222",
            onPressed: () {
              onComplete(RestoreModeSelectorContext());
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget buildBusy(
    BuildContext context, {
    CancellationTokenSource cancellationTokenSource,
    Widget feedbackInfoWidget,
  }) {
    // TODO: implement buildBusy
    return Text("Active102");
  }
}
