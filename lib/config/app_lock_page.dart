import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppLock extends StatelessWidget {
  final bool isLocked;
  final Widget child;

  const AppLock({
    super.key,
    required this.isLocked,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (isLocked) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: REdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock, size: 50, color: Colors.red),
                const SizedBox(height: 20),
                Text(
                  "Ilova blocklangan.",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return child;
  }
}