import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:school_test_app/core/constants/constants.dart';
import '../../controllers/register_controller.dart';
import '../widgets/uzbek_dropdown_widget.dart';
import 'login_page.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final RegistrationController _controller = Get.put(RegistrationController());

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hisob yaratish'.tr),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo and app name
                Container(
                  width: 80.w,
                  height: 80.w,
                  decoration: BoxDecoration(
                    color: Colors.blue.customOpacity(0.1),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  margin: EdgeInsets.symmetric(horizontal: 120.w),
                  child: Icon(
                    Icons.school_outlined,
                    size: 40.w,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  'Smart Survey\'ga xush kelibsiz'.tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Hisob yaratish uchun ma\'lumotlarni kiriting'.tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 32.h),

                // Full name
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'To\'liq ism'.tr,
                    hintText: 'Ismingizni kiriting'.tr,
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Iltimos, ismingizni kiriting'.tr;
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.h),

                // Email
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Elektron pochta'.tr,
                    hintText: 'Elektron pochtangizni kiriting'.tr,
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Iltimos, elektron pochtangizni kiriting'.tr;
                    }
                    if (!value.contains('@') || !value.contains('.')) {
                      return 'To\'g\'ri elektron pochta kiriting'.tr;
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.h),

                // Role selection
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mening holatim:'.tr,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Obx(() => Row(
                          children: [
                            // Student option
                            Expanded(
                              child: RadioListTile<String>(
                                title: Text('O\'quvchi'.tr),
                                value: 'student',
                                groupValue: _controller.selectedRole.value,
                                onChanged: (value) => _controller.selectedRole.value = value!,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                            // Teacher option
                            Expanded(
                              child: RadioListTile<String>(
                                title: Text('Psixolog'.tr),
                                value: 'teacher',
                                groupValue: _controller.selectedRole.value,
                                onChanged: (value) => _controller.selectedRole.value = value!,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ],
                        ),),
                    Obx(
                      () => RadioListTile<String>(
                        title: Text('Umumiy'.tr),
                        value: 'umumiy',
                        groupValue: _controller.selectedRole.value,
                        onChanged: (value) => _controller.selectedRole.value = value!,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),

                // School-related fields (only for students)
                Obx(() {
                  return Column(
                    children: [
                      if (_controller.selectedRole.value == "umumiy")
                        Column(
                          children: [
                            // Address (MFY) field
                            TextFormField(
                              onChanged: (value) => _controller.address.value = value,
                              decoration: InputDecoration(
                                labelText: 'Manzil (MFY)'.tr,
                                hintText: 'Mahalla yoki MFY nomini kiriting'.tr,
                                prefixIcon: const Icon(Icons.location_on_outlined),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                              ),
                              validator: (value) {
                                if (_controller.selectedRole.value == "umumiy" &&
                                    (value == null || value.isEmpty)) {
                                  return 'Iltimos, manzilingizni kiriting'.tr;
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 16.h),

                            // Phone number field
                            TextFormField(
                              onChanged: (value) => _controller.phoneNumber.value = value,
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                labelText: 'Telefon raqam'.tr,
                                hintText: '+998901234567'.tr,
                                prefixIcon: const Icon(Icons.phone_outlined),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                              ),
                              validator: (value) {
                                if (_controller.selectedRole.value == "umumiy" &&
                                    (value == null || value.isEmpty)) {
                                  return 'Iltimos, telefon raqamingizni kiriting'.tr;
                                }
                                if (_controller.selectedRole.value == "umumiy" &&
                                    !value!.startsWith('+998') && value.length != 13) {
                                  return 'To\'g\'ri telefon raqam kiriting'.tr;
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 16.h),

                            // City dropdown
                            UzbekDropdownField(
                              label: 'Shaharlar'.tr,
                              items: _controller.cities,
                              selectedValue: _controller.selectedCity,
                              onChanged: (value) {
                                _controller.selectedCity.value = value ?? '';
                              },
                            ),
                            SizedBox(height: 16.h),
                          ],
                        ),

                      // District dropdown (shown for all roles)
                      UzbekDropdownField(
                        label: 'Tumanlar'.tr,
                        items: _controller.districts,
                        selectedValue: _controller.selectedDistrict,
                        onChanged: (value) {
                          _controller.selectedDistrict.value = value ?? '';
                        },
                      ),

                      // Rest of your existing fields...
                    ],
                  );
                }),
                SizedBox(height: 16.h),

                // Password
                Obx(() => TextFormField(
                      controller: _passwordController,
                      obscureText: _controller.obscurePassword.value,
                      decoration: InputDecoration(
                        labelText: 'Parol'.tr,
                        hintText: 'Parol yarating'.tr,
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _controller.obscurePassword.value ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          ),
                          onPressed: _controller.togglePasswordVisibility,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Iltimos, parol kiriting'.tr;
                        }
                        if (value.length < 6) {
                          return 'Parol kamida 6 belgidan iborat bo\'lishi kerak'.tr;
                        }
                        return null;
                      },
                    )),
                SizedBox(height: 16.h),

                // Confirm Password
                Obx(() => TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _controller.obscureConfirmPassword.value,
                      decoration: InputDecoration(
                        labelText: 'Parolni tasdiqlang'.tr,
                        hintText: 'Parolni qayta kiriting'.tr,
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _controller.obscureConfirmPassword.value ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          ),
                          onPressed: _controller.toggleConfirmPasswordVisibility,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Iltimos, parolni tasdiqlang'.tr;
                        }
                        if (value != _passwordController.text) {
                          return 'Parollar mos kelmadi'.tr;
                        }
                        return null;
                      },
                    )),
                SizedBox(height: 24.h),

                // Register button
                Obx(() => ElevatedButton(
                      onPressed: _controller.isLoading.value
                    ? null
                    : () {
                if (_formKey.currentState!.validate()) {
                if (_controller.selectedRole.value == 'student' &&
                (_controller.selectedDistrict.value.isEmpty ||
                _controller.selectedSchool.value.isEmpty ||
                _controller.selectedGrade.value.isEmpty ||
                _controller.selectedClass.value.isEmpty)) {
                Get.snackbar(
                'Xatolik'.tr,
                'Iltimos, barcha maydonlarni to\'ldiring'.tr,
                );
                return;
                }

                if (_controller.selectedRole.value == 'umumiy' &&
                (_controller.address.value.isEmpty ||
                _controller.phoneNumber.value.isEmpty ||
                _controller.selectedCity.value.isEmpty)) {
                Get.snackbar(
                'Xatolik'.tr,
                'Iltimos, barcha maydonlarni to\'ldiring'.tr,
                );
                return;
                }

                _controller.registerUser(
                name: _nameController.text,
                email: _emailController.text,
                password: _passwordController.text,
                role: _controller.selectedRole.value,
                );
                }
                },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                      ),
                      child: _controller.isLoading.value
                          ? SizedBox(
                              height: 20.h,
                              width: 20.h,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.w,
                                color: Colors.white,
                              ),
                            )
                          : Text('Hisob yaratish'.tr),
                    ),),
                SizedBox(height: 16.h),

                // Login option
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Allaqachon hisobingiz bormi? '.tr,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Get.offAll(() => LoginScreen()),
                      child: Text('Kirish'.tr),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
