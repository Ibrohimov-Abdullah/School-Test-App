import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:school_test_app/config/remote_config.dart';

import 'app_lock_page.dart';

class AppLockWrapper extends StatefulWidget {
  final Widget child;

  const AppLockWrapper({super.key, required this.child});

  @override
  State<AppLockWrapper> createState() => _AppLockWrapperState();
}

class _AppLockWrapperState extends State<AppLockWrapper> with WidgetsBindingObserver {
  bool _isOnline = true;
  bool _isLoading = true;
  late RemoteConfigService _remoteConfig;

  @override
  void initState() {
    super.initState();
    _remoteConfig = RemoteConfigService();
    WidgetsBinding.instance.addObserver(this);
    _initialize();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkStatus();
    }
  }

  Future<void> _initialize() async {
    await _remoteConfig.initialize();
    await _checkStatus();
    setState(() => _isLoading = false);
  }

  Future<void> _checkStatus() async {
    // Check internet first
    final isOnline = await InternetChecker.hasInternetConnection();
    setState(() => _isOnline = isOnline);

    // Only fetch remote config if we have internet
    if (isOnline) {
      await _remoteConfig.forceFetch();
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Case 1: No internet
    if (!_isOnline) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.wifi_off, size: 50),
              SizedBox(height: 20),
              Text("No internet connection"),
              Text("Please check your network and try again"),
            ],
          ),
        ),
      );
    }

    // Case 2: Test lock is active
    if (_remoteConfig.testLock) {
      return AppLock(
        isLocked: true,
        child: widget.child,
      );
    }

    // Case 3: Client lock is active
    if (_remoteConfig.clientLock) {
      return AppLock(
        isLocked: true,
        child: widget.child,
      );
    }

    // Case 4: No locks - show normal app
    return widget.child;
  }
}