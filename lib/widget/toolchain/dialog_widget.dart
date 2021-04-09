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

import 'dart:async' show FutureOr;

import 'package:meta/meta.dart' show nonVirtual, protected, required;
import 'package:flutter/material.dart';
import "package:flutter/widgets.dart"
    show BuildContext, State, StatefulWidget, Widget;
import 'package:freemework/freemework.dart' show ExecutionContext, InvalidOperationException;
import 'package:freemework_cancellation/freemework_cancellation.dart'
    show CancellationTokenSource, ManualCancellationTokenSource;

typedef DialogHostCallback<T> = FutureOr Function(
    ExecutionContext executionContext, T);
typedef DialogCallback<T> = void Function(T);
typedef DialogFeedbackInfoWidgetBuilder = Widget Function(BuildContext context);

class DialogWidget<T> extends StatefulWidget {
  /// Initial record
  final T dataContextInit;

  /// Data record history from newest(recordHistory.first) to oldest(recordHistory.last)
  final List<T> dataContextsHistory;

  final DialogContentWidget<T> _child;
  final DialogHostCallback<T> _onCallback;
  final DialogFeedbackInfoWidgetBuilder _feedbackInfoWidgetBuilder;

  DialogWidget({
    @required DialogContentWidget<T> child,
    @required DialogHostCallback<T> onComplete,
    DialogFeedbackInfoWidgetBuilder feedbackInfoWidgetBuilder,
    this.dataContextInit,
    this.dataContextsHistory,
  })  : this._child = child,
        this._onCallback = onComplete,
        this._feedbackInfoWidgetBuilder = feedbackInfoWidgetBuilder {
    assert(child != null);
    assert(onComplete != null);
  }

  static DialogWidget<T> of<T>(BuildContext context) {
    final DialogWidget<T> dialogWidget =
        context.findAncestorWidgetOfExactType<DialogWidget<T>>();
    if (dialogWidget == null) {
      throw InvalidOperationException(
          "An $DialogWidget widget type does not exist in build context.");
    }
    return dialogWidget;
  }

  @override
  _DialogState<T> createState() => _DialogState<T>();
}

abstract class DialogFeedback {}

class DialogFeedbackActive<T> extends DialogFeedback {
  final DialogCallback<T> _onCallback;

  DialogFeedbackActive({
    @required DialogCallback<T> onComplete,
  }) : this._onCallback = onComplete;

  void onCallback(T dialogCompleteValue) =>
      this._onCallback(dialogCompleteValue);
}

class DialogFeedbackBusy extends DialogFeedback {
  final CancellationTokenSource _cancellationTokenSource;

  DialogFeedbackBusy()
      : this._cancellationTokenSource = ManualCancellationTokenSource();

  CancellationTokenSource get cancellationTokenSource =>
      this._cancellationTokenSource;
}

abstract class DialogContentWidget<T> extends Widget {
  @nonVirtual
  @override
  _DialogStatelessElement createElement() => _DialogStatelessElement(this);

  @protected
  Widget build(
    BuildContext context,
    DialogFeedback feedback,
  );
}

abstract class DialogActionContentWidget<T> extends DialogContentWidget<T> {
  @nonVirtual
  @override
  Widget build(
    BuildContext context,
    DialogFeedback feedback,
  ) {
    if (feedback is DialogFeedbackActive) {
      return this.buildActive(
        context,
        onComplete: feedback.onCallback,
      );
    } else if (feedback is DialogFeedbackBusy) {
      final DialogWidget<T> host = DialogWidget.of<T>(context);

      final Widget feedbackInfoWidget = host._feedbackInfoWidgetBuilder != null
          ? host._feedbackInfoWidgetBuilder(context)
          : null;

      return this.buildBusy(
        context,
        cancellationTokenSource: feedback.cancellationTokenSource,
        feedbackInfoWidget: feedbackInfoWidget,
      );
    } else {
      throw UnsupportedError(
          "Unsupported feedback runtimeType: ${feedback.runtimeType}");
    }
  }

  @protected
  Widget buildActive(
    BuildContext context, {
    DialogCallback<T> onComplete,
  });

  @protected
  Widget buildBusy(
    BuildContext context, {
    @required CancellationTokenSource cancellationTokenSource,
    Widget feedbackInfoWidget,
  });
}


class _DialogStatelessElement extends ComponentElement {
  /// Creates an element that uses the given widget as its configuration.
  _DialogStatelessElement(DialogContentWidget widget) : super(widget);

  @override
  DialogContentWidget get widget => super.widget as DialogContentWidget;

  @override
  Widget build() {
    final _DialogFeedbackWidget feedbackWidget =
        this.findAncestorWidgetOfExactType<_DialogFeedbackWidget>();
    final DialogFeedback feedback = feedbackWidget.feedback;
    return this.widget.build(this, feedback);
  }

  @override
  void update(DialogContentWidget newWidget) {
    super.update(newWidget);
    assert(this.widget == newWidget);
    rebuild();
  }
}

class _DialogState<T> extends State<DialogWidget<T>> {
  DialogFeedback _feedback;

  void initState() {
    super.initState();
    this._feedback = DialogFeedbackActive(
      onComplete: this._onCallbackProxy,
    );
  }

  void setDialogFeedback(DialogFeedback feedback) {
    assert(feedback != null);
    setState(() {
      this._feedback = feedback;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget homeWidget;

    if (this._feedback is DialogFeedbackBusy) {
      homeWidget = _DialogFeedbackWidget(
        key: ValueKey(DialogFeedbackBusy),
        feedback: this._feedback,
        child: this.widget._child,
      );
    } else if (this._feedback is DialogFeedbackActive) {
      homeWidget = _DialogFeedbackWidget(
          key: ValueKey(DialogFeedbackActive),
          feedback: this._feedback,
          child: this.widget._child);
    } else {
      throw UnsupportedError(
          "Unsupported feedback runtimeType: ${this._feedback.runtimeType}");
    }

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: homeWidget,
    );
  }

  FutureOr _onCallbackProxy(T dialogCompleteValue) async {
    assert(this._feedback is DialogFeedbackActive);
    final DialogFeedbackActive backupActiveFeedback = this._feedback;
    final DialogFeedbackBusy busyFeedback = DialogFeedbackBusy();
    this.setDialogFeedback(busyFeedback);
    try {
      final ExecutionContext executionContext = ExecutionContext.EMPTY
          .WithCancellationToken(busyFeedback.cancellationTokenSource.token);
      await this.widget._onCallback(
            executionContext,
            dialogCompleteValue,
          );
    } finally {
      this.setDialogFeedback(backupActiveFeedback);
    }
  }
}

class _DialogFeedbackWidget extends StatelessWidget {
  final DialogFeedback feedback;
  final Widget _child;

  _DialogFeedbackWidget({
    Key key,
    @required this.feedback,
    @required Widget child,
  })  : this._child = child,
        super(key: key);

  @override
  Widget build(BuildContext context) => this._child;
}
