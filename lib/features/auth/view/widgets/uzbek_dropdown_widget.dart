import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class UzbekDropdownField extends StatelessWidget {
  final String label;
  final List<String> items;
  final RxString? selectedValue;
  final Function(String?) onChanged;
  final bool isRequired;

  const UzbekDropdownField({
    Key? key,
    required this.label,
    required this.items,
    required this.selectedValue,
    required this.onChanged,
    this.isRequired = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8.h),
          Obx(() {
            return DropdownButtonFormField<String>(
              value: selectedValue?.value.isEmpty ?? true
                  ? null
                  : selectedValue?.value,
              items: [
                if (isRequired)
                  DropdownMenuItem<String>(
                    value: null,
                    child: Text(
                      'Tanlang...',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ...items.map((String item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(item),
                  );
                }).toList(),
              ],
              onChanged: onChanged,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 12.h,
                ),
              ),
              validator: isRequired
                  ? (value) {
                if (value == null || value.isEmpty) {
                  return 'Iltimos, $label tanlang';
                }
                return null;
              }
                  : null,
            );
          }),
        ],
      ),
    );
  }
}