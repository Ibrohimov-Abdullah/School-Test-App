import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

class RemoteConfigService {
  static final RemoteConfigService _instance = RemoteConfigService._internal();
  factory RemoteConfigService() => _instance;
  RemoteConfigService._internal();

  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  Future<void> initialize() async {
    await Firebase.initializeApp();

    // Set default values in case fetching fails
    await _remoteConfig.setDefaults({
      'test_lock': false,
      'client_lock': false,
    });

    // Set cache expiration and fetch
    await _remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 10),
      minimumFetchInterval: Duration.zero,
    ));

    try {
      await _remoteConfig.fetchAndActivate();
    } catch (e) {
      log('Failed to fetch remote config: $e');
    }
  }

  bool get testLock => _remoteConfig.getBool('test_lock');
  bool get clientLock => _remoteConfig.getBool('client_lock');

  Future<void> _fetchAndActivate() async {
    try {
      await _remoteConfig.fetchAndActivate();
      print('Remote config updated: testLock=$testLock, clientLock=$clientLock');
    } catch (e) {
      print('Failed to fetch remote config: $e');
    }
  }

  // Call this whenever you want to force an update
  Future<void> forceFetch() async {
    await _fetchAndActivate();
  }
}


class InternetChecker {
  static Future<bool> hasInternetConnection() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      return false;
    }
    return true;
  }
}