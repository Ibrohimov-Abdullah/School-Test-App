import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: AppColors.scaffoldLight,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.scaffoldLight,
        iconTheme: const IconThemeData(color: AppColors.textDark),
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.textDark,
        ),
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.poppins(
          fontSize: 32.sp,
          fontWeight: FontWeight.bold,
          color: AppColors.textDark,
        ),
        displayMedium: GoogleFonts.poppins(
          fontSize: 28.sp,
          fontWeight: FontWeight.w700,
          color: AppColors.textDark,
        ),
        displaySmall: GoogleFonts.poppins(
          fontSize: 24.sp,
          fontWeight: FontWeight.w700,
          color: AppColors.textDark,
        ),
        headlineMedium: GoogleFonts.poppins(
          fontSize: 20.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.textDark,
        ),
        headlineSmall: GoogleFonts.poppins(
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.textDark,
        ),
        titleLarge: GoogleFonts.poppins(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.textDark,
        ),
        titleMedium: GoogleFonts.poppins(
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
          color: AppColors.textDark,
        ),
        bodyLarge: GoogleFonts.poppins(
          fontSize: 16.sp,
          fontWeight: FontWeight.normal,
          color: AppColors.textDark,
        ),
        bodyMedium: GoogleFonts.poppins(
          fontSize: 14.sp,
          fontWeight: FontWeight.normal,
          color: AppColors.textDark,
        ),
        bodySmall: GoogleFonts.poppins(
          fontSize: 12.sp,
          fontWeight: FontWeight.normal,
          color: AppColors.textDark.withOpacity(0.8),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputFillDark,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppColors.primary, width: 1.5.w),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppColors.error, width: 1.5.w),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppColors.error, width: 1.5.w),
        ),
        hintStyle: GoogleFonts.poppins(
          fontSize: 14.sp,
          fontWeight: FontWeight.normal,
          color: AppColors.textDark.withOpacity(0.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.black,
          minimumSize: Size(double.infinity, 52.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
          padding: EdgeInsets.symmetric(vertical: 16.h),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppColors.primary, width: 1.5.w),
          foregroundColor: AppColors.primary,
          minimumSize: Size(double.infinity, 52.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
          padding: EdgeInsets.symmetric(vertical: 16.h),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: GoogleFonts.poppins(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      cardTheme: CardTheme(
        elevation: 2,
        color: Colors.black,
        margin: EdgeInsets.symmetric(vertical: 8.h, horizontal: 0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.primary;
          }
          return Colors.transparent;
        }),
        side: BorderSide(color: AppColors.primary, width: 1.5.w),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4.r),
        ),
      ),
      radioTheme: RadioThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.primary;
          }
          return Colors.grey.shade600;
        }),
      ),
      dividerTheme: DividerThemeData(
        color: Colors.grey.shade300,
        thickness: 1.h,
        space: 24.h,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: AppColors.scaffoldDark,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.scaffoldDark,
        iconTheme: const IconThemeData(color: AppColors.textDark),
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.textDark,
        ),
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.poppins(
          fontSize: 32.sp,
          fontWeight: FontWeight.bold,
          color: AppColors.textDark,
        ),
        displayMedium: GoogleFonts.poppins(
          fontSize: 28.sp,
          fontWeight: FontWeight.w700,
          color: AppColors.textDark,
        ),
        displaySmall: GoogleFonts.poppins(
          fontSize: 24.sp,
          fontWeight: FontWeight.w700,
          color: AppColors.textDark,
        ),
        headlineMedium: GoogleFonts.poppins(
          fontSize: 20.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.textDark,
        ),
        headlineSmall: GoogleFonts.poppins(
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.textDark,
        ),
        titleLarge: GoogleFonts.poppins(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.textDark,
        ),
        titleMedium: GoogleFonts.poppins(
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
          color: AppColors.textDark,
        ),
        bodyLarge: GoogleFonts.poppins(
          fontSize: 16.sp,
          fontWeight: FontWeight.normal,
          color: AppColors.textDark,
        ),
        bodyMedium: GoogleFonts.poppins(
          fontSize: 14.sp,
          fontWeight: FontWeight.normal,
          color: AppColors.textDark,
        ),
        bodySmall: GoogleFonts.poppins(
          fontSize: 12.sp,
          fontWeight: FontWeight.normal,
          color: AppColors.textDark.withOpacity(0.8),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputFillDark,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppColors.primary, width: 1.5.w),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppColors.error, width: 1.5.w),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppColors.error, width: 1.5.w),
        ),
        hintStyle: GoogleFonts.poppins(
          fontSize: 14.sp,
          fontWeight: FontWeight.normal,
          color: AppColors.textDark.withOpacity(0.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.black,
          minimumSize: Size(double.infinity, 52.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
          padding: EdgeInsets.symmetric(vertical: 16.h),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppColors.primary, width: 1.5.w),
          foregroundColor: AppColors.primary,
          minimumSize: Size(double.infinity, 52.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
          padding: EdgeInsets.symmetric(vertical: 16.h),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: GoogleFonts.poppins(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      cardTheme: CardTheme(
        elevation: 2,
        color: AppColors.cardDark,
        margin: EdgeInsets.symmetric(vertical: 8.h, horizontal: 0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.primary;
          }
          return Colors.transparent;
        }),
        side: BorderSide(color: AppColors.primary, width: 1.5.w),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4.r),
        ),
      ),
      radioTheme: RadioThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.primary;
          }
          return Colors.grey.shade400;
        }),
      ),
      dividerTheme: DividerThemeData(
        color: Colors.grey.shade700,
        thickness: 1.h,
        space: 24.h,
      ),
    );
  }
}