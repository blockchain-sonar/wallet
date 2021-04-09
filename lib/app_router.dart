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

import 'dart:async';

import 'package:flutter/material.dart'
    show AppBar, MaterialApp, MaterialPage, Scaffold;
import 'package:flutter/widgets.dart'
    show
        AsyncSnapshot,
        BuildContext,
        Center,
        ChangeNotifier,
        GlobalKey,
        Navigator,
        NavigatorState,
        PopNavigatorRouterDelegateMixin,
        RouteInformation,
        RouteInformationParser,
        RouteTransitionRecord,
        RouterDelegate,
        StatelessWidget,
        StreamBuilder,
        Text,
        TransitionDelegate,
        ValueKey,
        Widget;
import 'package:freemework/ExecutionContext.dart';
import 'package:freeton_wallet/widget/toolchain/dialog_widget.dart';
import 'package:freeton_wallet/widget/business/unlock.dart';

class AppRouterWidget extends StatelessWidget {
  final _AppRouterDelegate _routerDelegate = _AppRouterDelegate();
  final _AppRouteInformationParser _routeInformationParser =
      _AppRouteInformationParser();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'App',
      routerDelegate: _routerDelegate,
      routeInformationParser: _routeInformationParser,
    );
  }
}

class _AppRouteInformationParser
    extends RouteInformationParser<_AppRouterConfiguration> {
  @override
  Future<_AppRouterConfiguration> parseRouteInformation(
      RouteInformation routeInformation) async {
    final uri = Uri.parse(routeInformation.location);
    if (uri.pathSegments.length == 0) {
      // Handle '/'
      Object state = routeInformation.state;
      UnlockContext unlockContext;
      if (state != null) {
        assert(state is UnlockContext);
        unlockContext = state;
      } else {
        unlockContext = null;
      }
      return _AppRouterConfiguration.unlock(unlockContext);
    }

    return _AppRouterConfiguration.unlock(
        UnlockContext("Hello parseRouteInformation 2"));
  }

  @override
  RouteInformation restoreRouteInformation(
      _AppRouterConfiguration configuration) {
    if (configuration != null) {
      final routeState = configuration.routeState;
      print("restoreRouteInformation routeState: $routeState");
      if (routeState is UnlockContext) {
        return RouteInformation(location: '/', state: routeState);
      }
    }
    print("restoreRouteInformation $configuration");
    return RouteInformation(location: '/');
  }
}

class _AppRouterDelegate extends RouterDelegate<_AppRouterConfiguration>
    with
        ChangeNotifier,
        PopNavigatorRouterDelegateMixin<_AppRouterConfiguration> {
  final GlobalKey<NavigatorState> navigatorKey;
  _AppRouterConfiguration _currentConfiguration;

  _AppRouterDelegate()
      : this.navigatorKey = GlobalKey<NavigatorState>(),
        this._currentConfiguration = null;

  _AppRouterConfiguration get currentConfiguration {
    return this._currentConfiguration;
  }

  @override
  Widget build(BuildContext context) {
    final TransitionDelegate transitionDelegate =
        NoAnimationTransitionDelegate();
    StreamController<String> completeStreamController;

    print(
        "_AppRouterDelegate#build: this._currentConfiguration: ${this._currentConfiguration}");
    if (this._currentConfiguration != null) {
      print(
          "_AppRouterDelegate#build: this._currentConfiguration.routeState: ${this._currentConfiguration.routeState}");
    }

    final UnlockContext dataContextInit =
        this._currentConfiguration?.routeState as UnlockContext;
    if (dataContextInit != null) {
      print(
          "_AppRouterDelegate#build: dataContextInit.password: ${dataContextInit.password}");
    }

    return Navigator(
      key: navigatorKey,
      transitionDelegate: transitionDelegate,
      pages: [
        MaterialPage(
          key: ValueKey(dataContextInit),
          child: DialogWidget<UnlockContext>(
            dataContextInit: dataContextInit,
            child: UnlockWidget(),
            onComplete: (
              executionContext,
              value,
            ) async {
              completeStreamController = StreamController<String>();
              int count = 0;
              while (
                  !executionContext.cancellationToken.isCancellationRequested) {
                ++count;
                completeStreamController.sink.add(count.toString());
                await Future.delayed(Duration(milliseconds: 250));
              }
              await Future.delayed(Duration(seconds: 1));
              await completeStreamController.close();
              completeStreamController = null;
              this._currentConfiguration =
                  _AppRouterConfiguration.unlock(value);
              this.notifyListeners();
            },
            feedbackInfoWidgetBuilder: (BuildContext context) {
              assert(completeStreamController != null);
              return StreamBuilder<String>(
                stream: completeStreamController.stream,
                builder:
                    (BuildContext context, AsyncSnapshot<String> snapshot) {
                  return Text(
                      "feedbackInfoWidget ${DateTime.now().toIso8601String()} ${snapshot.data}");
                },
              );
            },
          ),
        ),
        if (this._currentConfiguration == null)
          MaterialPage(key: ValueKey(UnknownScreen), child: UnknownScreen())
      ],
      onPopPage: (route, result) {
        if (!route.didPop(result)) {
          return false;
        }

        this._currentConfiguration = null;
        notifyListeners();
        return true;
      },
    );
  }

  @override
  Future<void> setNewRoutePath(_AppRouterConfiguration configuration) async {
    this._currentConfiguration = configuration;
  }
}

class _AppRouterConfiguration {
  final dynamic routeState;
  _AppRouterConfiguration.unlock(UnlockContext routeState)
      : this.routeState = routeState;
}

class UnknownScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Text('404!'),
      ),
    );
  }
}

class NoAnimationTransitionDelegate extends TransitionDelegate<void> {
  @override
  Iterable<RouteTransitionRecord> resolve({
    List<RouteTransitionRecord> newPageRouteHistory,
    Map<RouteTransitionRecord, RouteTransitionRecord>
        locationToExitingPageRoute,
    Map<RouteTransitionRecord, List<RouteTransitionRecord>>
        pageRouteToPagelessRoutes,
  }) {
    final results = <RouteTransitionRecord>[];

    for (final pageRoute in newPageRouteHistory) {
      if (pageRoute.isWaitingForEnteringDecision) {
        pageRoute.markForAdd();
      }
      results.add(pageRoute);
    }

    for (final exitingPageRoute in locationToExitingPageRoute.values) {
      if (exitingPageRoute.isWaitingForExitingDecision) {
        exitingPageRoute.markForRemove();
      }

      final pagelessRoutes = pageRouteToPagelessRoutes[exitingPageRoute];
      if (pagelessRoutes != null) {
        for (final pagelessRoute in pagelessRoutes) {
          pagelessRoute.markForRemove();
        }
      }

      results.add(exitingPageRoute);
    }
    return results;
  }
}
