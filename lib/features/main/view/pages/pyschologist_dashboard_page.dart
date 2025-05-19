// Create this new file in your pages directory
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PsychologistDashboardScreen extends StatelessWidget {
  const PsychologistDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Psixolog Kabineti'),
      ),
      body: Center(
        child: Text('Psixologlar uchun asosiy sahifa'),
      ),
    );
  }
}