import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

import '../Pages/splash.dart';
import '../utills/shared_preference.dart';
import 'internet.dart';

class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();

  factory ConnectivityService() => _instance;

  ConnectivityService._internal();

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _isNoInternetPageShown = false;
  BuildContext? _currentContext;

  void startMonitoring(BuildContext context) {
    _currentContext = context;
    _connectivitySubscription?.cancel();
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((
        List<ConnectivityResult> results,
        ) async {
      bool hasInternet = await _hasInternet();
      bool isConnected = results.any(
            (result) =>
        result == ConnectivityResult.wifi ||
            result == ConnectivityResult.mobile ||
            result == ConnectivityResult.ethernet,
      );

      if (!isConnected || !hasInternet) {
        if (!_isNoInternetPageShown && _currentContext != null) {
          _isNoInternetPageShown = true;
          Navigator.pushNamed(
            _currentContext!,
            NoInterNetScreen.routeName,
          ).then((_) {
            _isNoInternetPageShown = false;
          });
        }
        SharedPreferenceHelper.setInternet(true);
      } else {
        if (_isNoInternetPageShown && _currentContext != null) {
          SharedPreferenceHelper.setInternet(false);
          if (SharedPreferenceHelper.getSplash()) {
            Navigator.pop(_currentContext!);
            Navigator.push(
              _currentContext!,
              MaterialPageRoute(builder: (context) => const Splash()),
            );
          } else {
            print("Internet restored - attempting to pop NoInternet page");
            if (Navigator.canPop(_currentContext!)) {
              Navigator.pop(_currentContext!);
              print("NoInternet page popped successfully");
            } else {
              print("Cannot pop - NoInternet page not on top");
              _isNoInternetPageShown = false;
            }
          }
        }
      }
    });
  }

  Future<bool> _hasInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  void dispose() {
    _connectivitySubscription?.cancel();
    _currentContext = null;
  }
}

class ConnectivityNavigatorObserver extends NavigatorObserver {
  final ConnectivityService connectivityService;

  ConnectivityNavigatorObserver(this.connectivityService);

  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    if (navigator != null) {
      connectivityService.startMonitoring(navigator!.context);
    }
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    if (navigator != null) {
      connectivityService.startMonitoring(navigator!.context);
    }
  }
}
