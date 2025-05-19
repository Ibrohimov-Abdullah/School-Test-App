import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../features/themes/app_colors.dart';


enum ButtonType { primary, secondary, outline, text }

class AppButton extends StatelessWidget {
  final String text;
  final ButtonType type;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final double? width;
  final double? height;
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  const AppButton({
    Key? key,
    required this.text,
    this.type = ButtonType.primary,
    this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.width,
    this.height,
    this.prefixIcon,
    this.suffixIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null || isLoading;

    switch (type) {
      case ButtonType.primary:
        return _buildElevatedButton(
          context,
          backgroundColor: AppColors.primary,
          textColor: Colors.white,
          isDisabled: isDisabled,
        );
      case ButtonType.secondary:
        return _buildElevatedButton(
          context,
          backgroundColor: AppColors.secondary,
          textColor: Colors.white,
          isDisabled: isDisabled,
        );
      case ButtonType.outline:
        return _buildOutlinedButton(context, isDisabled: isDisabled);
      case ButtonType.text:
        return _buildTextButton(context, isDisabled: isDisabled);
    }
  }

  Widget _buildElevatedButton(
      BuildContext context, {
        required Color backgroundColor,
        required Color textColor,
        required bool isDisabled,
      }) {
    return SizedBox(
      width: isFullWidth ? double.infinity : width,
      height: height ?? 52.h,
      child: ElevatedButton(
        onPressed: isDisabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isDisabled ? AppColors.disabled : backgroundColor,
          foregroundColor: textColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          elevation: 0,
        ),
        child: _buildContent(
          color: isDisabled ? AppColors.textGrey : textColor,
        ),
      ),
    );
  }

  Widget _buildOutlinedButton(BuildContext context, {required bool isDisabled}) {
    return SizedBox(
      width: isFullWidth ? double.infinity : width,
      height: height ?? 52.h,
      child: OutlinedButton(
        onPressed: isDisabled ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: isDisabled ? AppColors.disabled : AppColors.primary,
          side: BorderSide(
            color: isDisabled ? AppColors.disabled : AppColors.primary,
            width: 1.5.w,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        child: _buildContent(
          color: isDisabled ? AppColors.disabled : AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildTextButton(BuildContext context, {required bool isDisabled}) {
    return SizedBox(
      width: isFullWidth ? double.infinity : width,
      height: height ?? 40.h,
      child: TextButton(
        onPressed: isDisabled ? null : onPressed,
        style: TextButton.styleFrom(
          foregroundColor: isDisabled ? AppColors.disabled : AppColors.primary,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
        child: _buildContent(
          color: isDisabled ? AppColors.disabled : AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildContent({required Color color}) {
    if (isLoading) {
      return SizedBox(
        height: 24.h,
        width: 24.h,
        child: CircularProgressIndicator(
          color: color,
          strokeWidth: 2.w,
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (prefixIcon != null) ...[
          prefixIcon!,
          SizedBox(width: 8.w),
        ],
        Text(
          text,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (suffixIcon != null) ...[
          SizedBox(width: 8.w),
          suffixIcon!,
        ],
      ],
    );
  }
}
