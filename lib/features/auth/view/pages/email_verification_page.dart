import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/storage/app_storage.dart';
import '../../../main/view/pages/main_page.dart';

class EmailVerificationScreen extends StatelessWidget {
  final String email;

  const EmailVerificationScreen({Key? key, required this.email}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Emailni tasdiqlash'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.email_outlined, size: 80, color: Colors.blue),
            SizedBox(height: 20),
            Text(
              'Tasdiqlash havolasi yuborildi',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Elektron pochtangizga yuborilgan tasdiqlash havolasini bosing ($email)',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () async {
                await FirebaseAuth.instance.currentUser?.reload();
                if (FirebaseAuth.instance.currentUser?.emailVerified ?? false) {
                  await AppStorage.storeBool(key: StorageKey.isUserHave, value: true);
                  Get.offAll(() => MainPage());
                } else {
                  Get.snackbar('Xatolik', 'Email hali tasdiqlanmagan');
                }
              },
              child: Text('Tasdiqlandi'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await FirebaseAuth.instance.currentUser?.sendEmailVerification();
                  Get.snackbar('Muvaffaqiyatli', 'Tasdiqlash havolasi qayta yuborildi');
                } catch (e) {
                  Get.snackbar('Xatolik', 'Havolani yuborishda xatolik: $e');
                }
              },
              child: Text('Havolani qayta yuborish'),
            ),
          ],
        ),
      ),
    );
  }
}