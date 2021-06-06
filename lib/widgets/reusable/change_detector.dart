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

import "package:flutter/widgets.dart"
    show
        BuildContext,
        ChangeNotifier,
        State,
        StatefulWidget,
        Widget,
        WidgetBuilder;

class ChangeDetector extends StatefulWidget {
  final WidgetBuilder _builder;
  final ChangeNotifier _changeSource;

  ChangeDetector(this._changeSource, {required WidgetBuilder builder})
      : this._builder = builder;

  @override
  _ChangeDetectorState createState() => _ChangeDetectorState();
}

class _ChangeDetectorState extends State<ChangeDetector> {
  @override
  void initState() {
    super.initState();

    this.widget._changeSource.addListener(this._onSourceChanged);
  }

  @override
  void dispose() {
    this.widget._changeSource.removeListener(this._onSourceChanged);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return this.widget._builder(context);
  }

  void _onSourceChanged() {
    this.setState(() {});
  }
}
