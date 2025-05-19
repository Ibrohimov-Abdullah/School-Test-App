import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../view/pages/email_verification_page.dart';

class RegistrationController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Form variables
  var isLoading = false.obs;
  var obscurePassword = true.obs;
  var obscureConfirmPassword = true.obs;
  var selectedRole = 'student'.obs; // 'student' or 'psychologist'

  // Location data
  var selectedDistrict = ''.obs;
  var selectedCity = ''.obs;
  var selectedSchool = ''.obs;
  var selectedGrade = ''.obs;
  var selectedClass = ''.obs;

  // Lists from Firebase
  var districts = <String>[].obs;
  var cities = <String>[].obs;
  var schools = <String>[].obs;
  var grades = List.generate(11, (index) => '${index + 1}-sinf').obs;
  var classes = List.generate(26, (index) => String.fromCharCode(65 + index)).obs;

  @override
  void onInit() {
    super.onInit();
    loadDistricts();
    loadCities();

    ever(selectedDistrict, (_) {
      selectedSchool.value = '';
      if (selectedDistrict.value.isNotEmpty && selectedDistrict.value != 'Tumanni tanlang') {
        loadSchools(selectedDistrict.value);
      }
    });
  }

  Future<void> loadDistricts() async {
    try {
      isLoading(true);
      final snapshot = await _firestore.collection('districts').orderBy('name').get();

      districts.clear();
      districts.addAll(snapshot.docs.map((doc) => doc['name'] as String));

      selectedDistrict.value = districts[0];
    } catch (e) {
      Get.snackbar('Xatolik', 'Tumanlar yuklanmadi: $e');
    } finally {
      isLoading(false);
    }
  }
  Future<void> loadCities() async {
    try {
      isLoading(true);
      final snapshot = await _firestore.collection('cities').orderBy('name').get();

      cities.clear();
      cities.addAll(snapshot.docs.map((doc) => doc['name'] as String));

      selectedCity.value = cities[0];
    } catch (e) {
      Get.snackbar('Xatolik', 'Shaharlar yuklanmadi: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<void> loadSchools(String districtName) async {
    try {
      isLoading(true);
      schools.clear();

      final snapshot = await _firestore
          .collection('schools')
          .where('districtName', isEqualTo: districtName)
          .orderBy('name')
          .get();

      schools.addAll(snapshot.docs.map((doc) => doc['name'] as String));
      selectedSchool.value = schools[0];
    } catch (e) {
      Get.snackbar('Xatolik', 'Maktablar yuklanmadi: $e');
    } finally {
      isLoading(false);
    }
  }
// Add these new variables to the controller class
  var address = ''.obs;
  var phoneNumber = ''.obs;

// Update the registerUser method to include these fields
  Future<void> registerUser({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      isLoading(true);

      // 1. Create user in Firebase Auth with email verification
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2. Send email verification
      await userCredential.user?.sendEmailVerification();

      // 3. Save user data to Firestore
      final userData = {
        'name': name,
        'email': email,
        'role': role,
        'isVerified': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (role == 'student') {
        userData.addAll({
          'district': selectedDistrict.value,
          'school': selectedSchool.value,
          'grade': selectedGrade.value,
          'class': selectedClass.value,
          'tests': {},
        });
      } else if (role == 'psychologist') {
        userData.addAll({
          'district': selectedDistrict.value,
          'school': selectedSchool.value,
          'assignedStudents': [],
          'tests': {},
        });
      } else if (role == 'umumiy') {
        userData.addAll({
          'address': address.value,
          'phoneNumber': phoneNumber.value,
          'city': selectedCity.value,
        },);
      }

      await _firestore.collection('users').doc(userCredential.user?.uid).set(userData);

      // 4. Update school's user list (only if not umumiy)
      if (role != 'umumiy' && selectedSchool.value.isNotEmpty && selectedSchool.value != 'Maktabni tanlang') {
        final schoolQuery = await _firestore.collection('schools')
            .where('name', isEqualTo: selectedSchool.value)
            .limit(1)
            .get();

        if (schoolQuery.docs.isNotEmpty) {
          await schoolQuery.docs.first.reference.update({
            'users': FieldValue.arrayUnion([userCredential.user!.uid])
          });
        }
      }

      Get.offAll(() => EmailVerificationScreen(email: email));
      Get.snackbar('Muvaffaqiyatli', 'Tasdiqlash havolasi elektron pochtangizga yuborildi');
    } catch (e) {
      Get.snackbar('Xatolik', 'Ro\'yxatdan o\'tishda xatolik: $e');
    } finally {
      isLoading(false);
    }
  }

  void togglePasswordVisibility() => obscurePassword.toggle();
  void toggleConfirmPasswordVisibility() => obscureConfirmPassword.toggle();
}