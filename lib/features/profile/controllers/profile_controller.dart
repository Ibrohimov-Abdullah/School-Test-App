import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../auth/view/pages/login_page.dart';

class ProfileController extends GetxController {
  // ——— Observable maydonlar ———
  final RxString name = ''.obs;
  final RxString email = ''.obs;
  final RxString role = ''.obs;
  final RxString school = ''.obs;
  final RxString district = ''.obs;
  final RxString grade = ''.obs;
  final RxBool isVerified = false.obs;
  final RxString profileImagePath = ''.obs;
  final RxBool isLoading = true.obs;
  final RxInt balance = 0.obs; // foydalanuvchi balansini saqlash

  // ——— Dio uchun client ———
  late final Dio _dio;
  final RxInt lastOrderId = RxInt(-1); // oxirgi yaratgan order_id


  @override
  void onInit() {
    super.onInit();
    _dio = Dio(BaseOptions(
      baseUrl: 'https://yordamchiman.uz',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));
    loadProfileImage();
    fetchUserData();
  }


  // ——— Foydalanuvchi ma'lumotlarini oluvchi metod ———
  Future<void> fetchUserData() async {
    try {
      isLoading.value = true;
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Firestore'dan user profili
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          name.value = userDoc['name'] ?? '';
          email.value = userDoc['email'] ?? '';
          role.value = userDoc['role'] ?? '';
          school.value = userDoc['school'] ?? '';
          district.value = userDoc['district'] ?? '';
          grade.value = userDoc['grade'] ?? '';
          isVerified.value = userDoc['isVerified'] ?? false;

          // Balansni olish
          final balanceDoc = await FirebaseFirestore.instance
              .collection('balances')
              .doc(user.uid)
              .get();

          balance.value = balanceDoc.exists
              ? (balanceDoc['amount'] as int? ?? 0)
              : 0;
        }
      }
    } catch (e) {
      Get.snackbar('Xatolik', 'Ma\'lumotlarni yuklashda xatolik yuz berdi: $e',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  // ——— Profil rasmini SharedPreferences'dan olish ———
  Future<void> loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    profileImagePath.value = prefs.getString('profile_image') ?? '';
  }

  // ——— Galereyadan rasm tanlash va SharedPreferences'ga saqlash ———
  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      profileImagePath.value = pickedFile.path;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_image', pickedFile.path);
    }
  }

  // ——— Chiqish (Logout) ———
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



  Future<void> _checkClickPayment(int orderId, int amount, BuildContext context) async {
    try {
      isLoading.value = true;

      final response = await _dio.get('/click/order/$orderId/payment-status/');

      if (response.statusCode == 200) {

        final data = response.data as Map<String, dynamic>;
        final bool isPaid = data['is_paid'] as bool;

        if (isPaid) {
          final user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            await FirebaseFirestore.instance
                .collection('balances')
                .doc(user.uid)
                .set({
              'amount': FieldValue.increment(amount),
              'lastUpdated': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));

            // Lokal balans ham yangilansin
            balance.value += amount;

            Get.snackbar(
              'Muvaffaqiyatli',
              'Balansingiz $amount so\'mga to\'ldirildi',
              snackPosition: SnackPosition.BOTTOM,
            );
          }
        } else {
          // To‘lov hali amalga oshirilmagan
          Get.snackbar(
            'Diqqat',
            'Siz to\'lov qilmadingiz yoki to\'lov hali amalga oshmadi',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      } else {
        Get.snackbar(
          'Xatolik',
          'To‘lov holatini tekshirishda xatolik: ${response.statusCode}',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Xatolik',
        'To‘lov holatini tekshirishda xatolik: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }


  // ——— UI’dan chaqirish uchun public metodlar ———


  void verifyTopUp(int amount, BuildContext context) {
    final orderId = lastOrderId.value;
    if (orderId == -1) {
      Get.snackbar(
        'Diqqat',
        'Avval to‘lov yarating',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    _checkClickPayment(orderId, amount, context);
  }

  Future<bool> startTopUp(int amount, BuildContext context) async {
    try {
      return await createClickOrder(amount, context);
    } catch (e) {
      return false;
    }
  }

// Modify createClickOrder to return a Future<bool>
  Future<bool> createClickOrder(int amount, BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Get.snackbar(
        'Xatolik',
        'Avval tizimga kiring',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    // POST body
    final body = {
      "customer_name": name.value,
      "address": "${district.value}, ${school.value}",
      "total_cost": amount,
      "payment_method": "click",
    };

    try {
      isLoading.value = true;

      // 1) /click/order/create/ endpoint uchun POST so'rov
      final response = await _dio.post(
        '/click/order/create/',
        data: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data as Map<String, dynamic>;
        final Map<String, dynamic> orderData = data['order'] as Map<String, dynamic>;
        final int orderId = orderData['id'] as int;
        final bool isPaid = orderData['is_paid'] as bool;
        final String? paymentLink = data['payment_link'] as String?;

        // Save the order ID for later checks
        lastOrderId.value = orderId;

        if (isPaid) {
          // Payment already processed
          Get.snackbar(
            'Ma\'lumot',
          'To\'lov allaqachon amalga oshirilgan',
            snackPosition: SnackPosition.BOTTOM,
          );
          return true;
        } else {
          if (paymentLink != null && paymentLink.isNotEmpty) {
            // Open payment link
            final launched = await launchUrlString(
              paymentLink,
              mode: LaunchMode.externalApplication,
            );

            if (!launched) {
              Get.snackbar(
                'Xatolik',
                'To\'lov havolasi ochilmadi',
                snackPosition: SnackPosition.BOTTOM,
              );
              return false;
            }

            return true; // Successfully initiated payment
          } else {
            Get.snackbar(
              'Xatolik',
              'Server to\'lov havolasini qaytarmadi',
              snackPosition: SnackPosition.BOTTOM,
            );
            return false;
          }
        }
      } else {
        Get.snackbar(
          'Xatolik',
          'To\'lov yaratishda xatolik: ${response.statusCode}',
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        'Xatolik',
        'To\'lov yaratishda xatolik yuz berdi: $e',
      snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

// New method to check payment status
  Future<bool> checkPaymentStatus(int amount, BuildContext context) async {
    final orderId = lastOrderId.value;
    if (orderId == -1) {
      log('No order ID to check');
      return false;
    }

    return await checkClickPayment(orderId, amount, context);
  }

// Modified _checkClickPayment to return a Future<bool>
  Future<bool> checkClickPayment(int orderId, int amount, BuildContext context) async {
    try {
      // No need to set isLoading here as we're doing periodic checks

      // GET so'rov: /click/order/{orderId}/payment-status/
      final response = await _dio.get('/click/order/$orderId/payment-status/');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final bool isPaid = data['is_paid'] as bool;

        if (isPaid) {
          // Payment successful: update balance
          final user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            await FirebaseFirestore.instance
                .collection('balances')
                .doc(user.uid)
                .set({
              'amount': FieldValue.increment(amount),
              'lastUpdated': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));

            // Update local balance
            balance.value += amount;

            Get.snackbar(
              'Muvaffaqiyatli',
              'Balansingiz $amount so\'mga to\'ldirildi',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.green.shade100,
              colorText: Colors.green.shade800,
              duration: const Duration(seconds: 3),
            );

            // Reset order ID after successful payment
            lastOrderId.value = -1;
            return true;
          }
        }

        // If we get here, payment is not successful yet
        return isPaid;
      } else {
        log('Error checking payment status: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      log('Exception checking payment status: $e');
      return false;
    }
  }
}
