import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:school_test_app/core/constants/constants.dart';

import '../../features/themes/app_colors.dart';


class AppTextField extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? initialValue;
  final TextEditingController? controller;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final int? maxLines;
  final int? maxLength;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final AutovalidateMode autovalidateMode;
  final BoxConstraints? prefixIconConstraints;
  final BoxConstraints? suffixIconConstraints;
  final EdgeInsetsGeometry? contentPadding;

  const AppTextField({
    Key? key,
    this.label,
    this.hint,
    this.initialValue,
    this.controller,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.maxLines = 1,
    this.maxLength,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.prefixIcon,
    this.suffixIcon,
    this.inputFormatters,
    this.focusNode,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
    this.prefixIconConstraints,
    this.suffixIconConstraints,
    this.contentPadding,
  }) : super(key: key);

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late final TextEditingController _controller;
  bool _obscureText = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController(text: widget.initialValue);
    _obscureText = widget.obscureText;
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {});
  }

  void _toggleObscureText() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
          SizedBox(height: 8.h),
        ],
        TextFormField(
          controller: _controller,
          focusNode: widget.focusNode ?? _focusNode,
          obscureText: _obscureText,
          enabled: widget.enabled,
          readOnly: widget.readOnly,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          maxLines: widget.maxLines,
          maxLength: widget.maxLength,
          validator: widget.validator,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
          inputFormatters: widget.inputFormatters,
          autovalidateMode: widget.autovalidateMode,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.normal,
            color: widget.enabled
                ? Theme.of(context).textTheme.bodyLarge?.color
                : Theme.of(context).disabledColor,
          ),
          decoration: InputDecoration(
            hintText: widget.hint,
            filled: true,
            fillColor: widget.enabled
                ? Theme.of(context).inputDecorationTheme.fillColor
                : Theme.of(context).disabledColor.customOpacity(0.1),
            contentPadding: widget.contentPadding ??
                EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            prefixIcon: widget.prefixIcon,
            prefixIconConstraints: widget.prefixIconConstraints,
            suffixIcon: widget.obscureText
                ? IconButton(
              icon: Icon(
                _obscureText ? Icons.visibility : Icons.visibility_off,
                color: AppColors.textGrey,
                size: 20.sp,
              ),
              onPressed: _toggleObscureText,
            )
                : widget.suffixIcon,
            suffixIconConstraints: widget.suffixIconConstraints,
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
          ),
        ),
      ],
    );
  }
}