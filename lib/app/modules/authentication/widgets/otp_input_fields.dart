import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../controllers/authentication_controller.dart';

class OtpInputFields extends GetView<AuthenticationController> {
  const OtpInputFields({super.key});

  @override
  Widget build(BuildContext context) {
    final focusNode1 = FocusNode();
    final focusNode2 = FocusNode();
    final focusNode3 = FocusNode();
    final focusNode4 = FocusNode();

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _OtpBox(
            controller: controller.otp1Controller,
            focusNode: focusNode1,
            nextFocusNode: focusNode2,
            onChanged: (value) {
              if (value.isNotEmpty) {
                FocusScope.of(context).requestFocus(focusNode2);
              }
              if (controller.otpError.value.isNotEmpty) {
                controller.otpError.value = '';
              }
            },
          ),
          SizedBox(width: AppDimensions.spacing(context, 0.03)),
          _OtpBox(
            controller: controller.otp2Controller,
            focusNode: focusNode2,
            previousFocusNode: focusNode1,
            nextFocusNode: focusNode3,
            onChanged: (value) {
              if (value.isNotEmpty) {
                FocusScope.of(context).requestFocus(focusNode3);
              } else {
                FocusScope.of(context).requestFocus(focusNode1);
              }
              if (controller.otpError.value.isNotEmpty) {
                controller.otpError.value = '';
              }
            },
          ),
          SizedBox(width: AppDimensions.spacing(context, 0.03)),
          _OtpBox(
            controller: controller.otp3Controller,
            focusNode: focusNode3,
            previousFocusNode: focusNode2,
            nextFocusNode: focusNode4,
            onChanged: (value) {
              if (value.isNotEmpty) {
                FocusScope.of(context).requestFocus(focusNode4);
              } else {
                FocusScope.of(context).requestFocus(focusNode2);
              }
              if (controller.otpError.value.isNotEmpty) {
                controller.otpError.value = '';
              }
            },
          ),
          SizedBox(width: AppDimensions.spacing(context, 0.03)),
          _OtpBox(
            controller: controller.otp4Controller,
            focusNode: focusNode4,
            previousFocusNode: focusNode3,
            isLastField: true,
            onChanged: (value) {
              if (value.isEmpty) {
                FocusScope.of(context).requestFocus(focusNode3);
              } else {
                // Dismiss keyboard when last OTP digit is entered
                FocusScope.of(context).unfocus();
              }
              if (controller.otpError.value.isNotEmpty) {
                controller.otpError.value = '';
              }
            },
          ),
        ],
      ),
    );
  }
}

class _OtpBox extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final FocusNode? previousFocusNode;
  final FocusNode? nextFocusNode;
  final ValueChanged<String>? onChanged;
  final bool isLastField;

  const _OtpBox({
    required this.controller,
    required this.focusNode,
    this.previousFocusNode,
    this.nextFocusNode,
    this.onChanged,
    this.isLastField = false,
  });

  @override
  State<_OtpBox> createState() => _OtpBoxState();
}

class _OtpBoxState extends State<_OtpBox> {
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocusChange);
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = widget.focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = AppDimensions.screenWidth(context) * 0.15;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(
          AppDimensions.borderRadius(context, 0.02),
        ),
        border: Border.all(
          color: _isFocused ? AppColors.primary : Colors.transparent,
          width: 2,
        ),
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: widget.focusNode,
        textAlign: TextAlign.center,
        style: AppTextStyles.bodyText(context).copyWith(
          fontSize: AppDimensions.fontSize(context, 0.05),
          fontWeight: FontWeight.w600,
        ),
        keyboardType: TextInputType.number,
        textInputAction: widget.isLastField ? TextInputAction.done : TextInputAction.next,
        maxLength: 1,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        onChanged: widget.onChanged,
        decoration: const InputDecoration(
          counterText: '',
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }
}
