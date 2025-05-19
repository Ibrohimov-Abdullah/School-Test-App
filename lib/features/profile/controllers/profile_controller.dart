import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:school_test_app/features/auth/view/pages/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uzpay/enums.dart';
import 'package:uzpay/objects.dart';
import 'package:uzpay/uzpay.dart';

class ProfileController extends GetxController {
  final RxString name = ''.obs;
  final RxString email = ''.obs;
  final RxString role = ''.obs;
  final RxString school = ''.obs;
  final RxString district = ''.obs;
  final RxString grade = ''.obs;
  final RxBool isVerified = false.obs;
  final RxString profileImagePath = ''.obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadProfileImage();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      isLoading.value = true;
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Fetch user profile
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

        if (userDoc.exists) {
          name.value = userDoc['name'] ?? '';
          email.value = userDoc['email'] ?? '';
          role.value = userDoc['role'] ?? '';
          school.value = userDoc['school'] ?? '';
          district.value = userDoc['district'] ?? '';
          grade.value = userDoc['grade'] ?? '';
          isVerified.value = userDoc['isVerified'] ?? false;

          // Fetch balance
          final balanceDoc = await FirebaseFirestore.instance.collection('balances').doc(user.uid).get();

          balance.value = balanceDoc.exists ? (balanceDoc['amount'] ?? 0) : 0;
        }
      }
    } catch (e) {
      Get.snackbar('Xatolik', 'Ma\'lumotlarni yuklashda xatolik yuz berdi');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    profileImagePath.value = prefs.getString('profile_image') ?? '';
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      profileImagePath.value = pickedFile.path;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_image', pickedFile.path);
    }
  }

  void logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Xisobingizdan chiqib ketmoqchimisiz?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Yo'q"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await FirebaseAuth.instance.signOut();
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              Get.offAll(() => LoginScreen());
            },
            child: const Text("Ha"),
          ),
        ],
      ),
    );
  }

  // Add to ProfileController
  final RxInt balance = 0.obs;

// Update fetchUserData

// Add method to top up balance
  Future<void> topUpBalance(int amount, BuildContext context) async {
    // logic
    var payment = await UzPay.doPayment(
      context,
      amount: amount.toDouble(),
      paymentSystem: PaymentSystem.Click,
      paymentParams: Params(
        clickParams: ClickParams(
          transactionParam: "Transaction to Smart Quiz App",
          serviceId: "69003",
          merchantId: "37061",
          merchantUserId: "53110",
        ),
      ),
      browserType: BrowserType.ExternalOrDeepLink,
    );

    if(payment != null){
      try {
            final user = FirebaseAuth.instance.currentUser;
            if (user != null) {
              await FirebaseFirestore.instance.collection('balances').doc(user.uid).set({
                'amount': FieldValue.increment(amount),
                'lastUpdated': FieldValue.serverTimestamp(),
              }, SetOptions(merge: true));

              // Update local balance
              balance.value += amount;
              Get.snackbar('Muvaffaqiyatli', 'Balansingiz $amount so\'mga to\'ldirildi');
            }
          } catch (e) {
            Get.snackbar('Xatolik', 'Balansni to\'ldirishda xatolik: $e');
          }
    }else{
      log("Smth nigga");
    }

  }
}
