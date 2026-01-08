import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_images.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/widgets/api_image.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../controllers/authentication_controller.dart';

class PaymentView extends GetView<AuthenticationController> {
  const PaymentView({super.key});

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    // Load bank accounts when payment view is opened
    if (controller.bankAccounts.isEmpty) {
      controller.loadBankAccounts();
    }

    return AppScaffold(
      backgroundImage: AppImages.image2,
      showContentContainer: true,
      contentContainerPadding: EdgeInsets.symmetric(
        horizontal: screenSize.width * 0.05,
        vertical: screenSize.width * 0.04,
      ),
      headerChildren: [
        SizedBox(height: screenSize.height * 0.15),
        _buildHeader(context),
        SizedBox(height: screenSize.height * 0.03),
      ],
      children: [
        // Title
        FadeInDown(
          duration: const Duration(milliseconds: 600),
          child: Text(
            'subscription'.tr,
            style: AppTextStyles.sectionTitle(context).copyWith(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(height: screenSize.height * 0.01),
        // Subtitle
        FadeInDown(
          duration: const Duration(milliseconds: 600),
          delay: const Duration(milliseconds: 100),
          child: Text(
            'enter_payment_details'.tr,
            style: AppTextStyles.smallText(context).copyWith(
              color: AppColors.grey500,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(height: screenSize.height * 0.03),
        // Full Name Field
        FadeInUp(
          duration: const Duration(milliseconds: 500),
          delay: const Duration(milliseconds: 150),
          child: _buildFullNameField(context),
        ),
        SizedBox(height: screenSize.height * 0.02),
        // Phone Field
        FadeInUp(
          duration: const Duration(milliseconds: 500),
          delay: const Duration(milliseconds: 200),
          child: _buildPhoneField(context),
        ),
        SizedBox(height: screenSize.height * 0.025),
        // Payment Accounts Section
        FadeInUp(
          duration: const Duration(milliseconds: 500),
          delay: const Duration(milliseconds: 250),
          child: _buildPaymentAccountsSection(context),
        ),
        SizedBox(height: screenSize.height * 0.025),
        // Upload Section
        FadeInUp(
          duration: const Duration(milliseconds: 500),
          delay: const Duration(milliseconds: 300),
          child: _buildUploadSection(context),
        ),
        SizedBox(height: screenSize.height * 0.025),
        // Reference Number Field
        FadeInUp(
          duration: const Duration(milliseconds: 500),
          delay: const Duration(milliseconds: 312),
          child: _buildReferenceNumberField(context),
        ),
        SizedBox(height: screenSize.height * 0.025),
        // Discount Coupon Section
        FadeInUp(
          duration: const Duration(milliseconds: 500),
          delay: const Duration(milliseconds: 325),
          child: _buildDiscountCouponSection(context),
        ),
        SizedBox(height: screenSize.height * 0.025),
        // Amount Summary
        FadeInUp(
          duration: const Duration(milliseconds: 500),
          delay: const Duration(milliseconds: 350),
          child: _buildAmountSummary(context),
        ),
        SizedBox(height: screenSize.height * 0.03),
        // Complete Payment Button
        FadeInUp(
          duration: const Duration(milliseconds: 500),
          delay: const Duration(milliseconds: 400),
          child: _buildCompletePaymentButton(context),
        ),
        SizedBox(height: screenSize.height * 0.02),
      ],
    );
  }

  String _getCountryFlag(String code) {
    final Map<String, String> countryFlags = {
      '+222': '🇲🇷',
      '+966': '🇸🇦',
      '+971': '🇦🇪',
      '+20': '🇪🇬',
      '+962': '🇯🇴',
      '+965': '🇰🇼',
      '+973': '🇧🇭',
      '+974': '🇶🇦',
      '+968': '🇴🇲',
    };
    return countryFlags[code] ?? '🇲🇷';
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppDimensions.spacing(context, 0.04),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 28),
          Text(
            'subscription'.tr,
            style: AppTextStyles.sectionTitle(context).copyWith(
              color: AppColors.white,
              fontSize: 18,
            ),
          ),
          GestureDetector(
            onTap: () => Get.back(),
            child: const Icon(
              Icons.arrow_forward,
              color: AppColors.white,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullNameField(BuildContext context) {
    final isArabic = Get.locale?.languageCode == 'ar';

    return Column(
      crossAxisAlignment: isArabic ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        RichText(
          textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
          text: TextSpan(
            children: [
              TextSpan(
                text: '* ',
                style: AppTextStyles.inputLabel(context).copyWith(
                  color: AppColors.error,
                ),
              ),
              TextSpan(
                text: 'full_name'.tr,
                style: AppTextStyles.inputLabel(context),
              ),
            ],
          ),
        ),
        SizedBox(height: AppDimensions.screenHeight(context) * 0.01),
        Container(
          decoration: BoxDecoration(
            color: AppColors.grey100,
            borderRadius: BorderRadius.circular(
              AppDimensions.borderRadius(context, 0.03),
            ),
          ),
          child: TextField(
            controller: controller.usernameController,
            textAlign: TextAlign.right,
            style: AppTextStyles.bodyText(context),
            decoration: InputDecoration(
              hintText: 'full_name'.tr,
              hintStyle: AppTextStyles.inputHint(context),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: AppDimensions.spacing(context, 0.04),
                vertical: AppDimensions.spacing(context, 0.04),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneField(BuildContext context) {
    final isArabic = Get.locale?.languageCode == 'ar';

    return Column(
      crossAxisAlignment: isArabic ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        RichText(
          textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
          text: TextSpan(
            children: [
              TextSpan(
                text: '* ',
                style: AppTextStyles.inputLabel(context).copyWith(
                  color: AppColors.error,
                ),
              ),
              TextSpan(
                text: 'phone_number'.tr,
                style: AppTextStyles.inputLabel(context),
              ),
            ],
          ),
        ),
        SizedBox(height: AppDimensions.screenHeight(context) * 0.01),
        Container(
          decoration: BoxDecoration(
            color: AppColors.grey100,
            borderRadius: BorderRadius.circular(
              AppDimensions.borderRadius(context, 0.03),
            ),
          ),
          child: Row(
            children: [
              Padding(
                padding: EdgeInsets.only(
                  right: AppDimensions.spacing(context, 0.03),
                  left: AppDimensions.spacing(context, 0.02),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Obx(
                      () => Text(
                        _getCountryFlag(controller.selectedCountryCode.value),
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                    SizedBox(width: 8),
                    Obx(
                      () => Text(
                        controller.selectedCountryCode.value,
                        style: AppTextStyles.bodyText(context),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: TextField(
                  controller: controller.signUpPhoneController,
                  keyboardType: TextInputType.phone,
                  textAlign: TextAlign.right,
                  style: AppTextStyles.bodyText(context),
                  decoration: InputDecoration(
                    hintText: 'phone_number'.tr,
                    hintStyle: AppTextStyles.inputHint(context),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: AppDimensions.spacing(context, 0.04),
                      vertical: AppDimensions.spacing(context, 0.04),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentAccountsSection(BuildContext context) {
    final isArabic = Get.locale?.languageCode == 'ar';

    return Column(
      crossAxisAlignment: isArabic ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        Text(
          'select_payment_account'.tr,
          style: AppTextStyles.inputLabel(context),
        ),
        SizedBox(height: AppDimensions.screenHeight(context) * 0.015),
        Obx(() {
          if (controller.isLoadingBankAccounts.value) {
            return Container(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
            );
          }

          if (controller.bankAccounts.isEmpty) {
            return Container(
              padding: EdgeInsets.symmetric(
                vertical: AppDimensions.spacing(context, 0.04),
              ),
              child: Text(
                'no_bank_accounts'.tr,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyText(context).copyWith(
                  color: AppColors.grey500,
                ),
              ),
            );
          }

          return Column(
            children: controller.bankAccounts.map((account) => Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: _buildPaymentAccountItem(context, account),
            )).toList(),
          );
        }),
      ],
    );
  }

  Widget _buildPaymentAccountItem(BuildContext context, account) {
    return Obx(
      () {
        final isSelected = controller.selectedBankAccount.value?.id == account.id;
        return GestureDetector(
          onTap: () => controller.selectBankAccount(account),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: AppDimensions.spacing(context, 0.03),
              vertical: AppDimensions.spacing(context, 0.03),
            ),
            decoration: BoxDecoration(
              color: AppColors.grey100,
              borderRadius: BorderRadius.circular(
                AppDimensions.borderRadius(context, 0.02),
              ),
              border: isSelected
                  ? Border.all(color: AppColors.primary, width: 2)
                  : null,
            ),
            child: Row(
              children: [
                // Copy icon (left side in RTL)
                GestureDetector(
                  onTap: () {
                    // TODO: Copy account number to clipboard
                  },
                  child: Image.asset(
                    AppImages.icon49,
                    width: 20,
                    height: 20,
                  ),
                ),
                SizedBox(width: 10),
                // Expandable content area
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Bank name
                      Text(
                        account.bankName ?? 'unknown_bank'.tr,
                        style: AppTextStyles.bodyText(context),
                        textAlign: TextAlign.right,
                      ),
                      SizedBox(height: 4),
                      // Account number or IBAN
                      Text(
                        account.accountNumber ?? account.iban ?? '',
                        style: AppTextStyles.smallText(context),
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 10),
                // Bank logo (right side in RTL) - fixed width for alignment
                SizedBox(
                  width: 32,
                  height: 32,
                  child: account.logoUrl != null
                    ? ApiImage(
                        imageUrl: account.logoUrl!,
                        width: 32,
                        height: 32,
                        fit: BoxFit.contain,
                        errorWidget: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.grey200,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Icon(
                            Icons.account_balance,
                            size: 20,
                            color: AppColors.grey500,
                          ),
                        ),
                      )
                    : Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.grey200,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Icon(
                          Icons.account_balance,
                          size: 20,
                          color: AppColors.grey500,
                        ),
                      ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildUploadSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'transfer_instructions'.tr,
          style: AppTextStyles.smallText(context).copyWith(
            color: AppColors.grey600,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: AppDimensions.screenHeight(context) * 0.015),
        GestureDetector(
          onTap: controller.uploadPaymentReceipt,
          child: Obx(
            () => Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: AppDimensions.spacing(context, 0.04),
                vertical: AppDimensions.spacing(context, 0.04),
              ),
              decoration: BoxDecoration(
                color: controller.transferReceiptFile.value != null
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : AppColors.grey100,
                borderRadius: BorderRadius.circular(
                  AppDimensions.borderRadius(context, 0.03),
                ),
                border: Border.all(
                  color: controller.transferReceiptFile.value != null
                      ? AppColors.primary
                      : AppColors.grey300,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      controller.transferReceiptFile.value != null
                          ? controller.transferReceiptFileName.value
                          : 'attach_receipt'.tr,
                      style: AppTextStyles.bodyText(context).copyWith(
                        color: controller.transferReceiptFile.value != null
                            ? AppColors.primary
                            : AppColors.grey500,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 10),
                  Icon(
                    controller.transferReceiptFile.value != null
                        ? Icons.check_circle
                        : Icons.upload_file,
                    color: controller.transferReceiptFile.value != null
                        ? AppColors.primary
                        : AppColors.grey500,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReferenceNumberField(BuildContext context) {
    final isArabic = Get.locale?.languageCode == 'ar';

    return Column(
      crossAxisAlignment: isArabic ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        RichText(
          textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
          text: TextSpan(
            children: [
              TextSpan(
                text: '* ',
                style: AppTextStyles.inputLabel(context).copyWith(
                  color: AppColors.error,
                ),
              ),
              TextSpan(
                text: 'reference_number'.tr,
                style: AppTextStyles.inputLabel(context),
              ),
            ],
          ),
        ),
        SizedBox(height: AppDimensions.screenHeight(context) * 0.01),
        Container(
          decoration: BoxDecoration(
            color: AppColors.grey100,
            borderRadius: BorderRadius.circular(
              AppDimensions.borderRadius(context, 0.03),
            ),
          ),
          child: TextField(
            controller: controller.referenceNumberController,
            textAlign: TextAlign.right,
            style: AppTextStyles.bodyText(context),
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              hintText: 'enter_reference_number'.tr,
              hintStyle: AppTextStyles.inputHint(context),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: AppDimensions.spacing(context, 0.04),
                vertical: AppDimensions.spacing(context, 0.04),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDiscountCouponSection(BuildContext context) {
    final isArabic = Get.locale?.languageCode == 'ar';

    return Column(
      crossAxisAlignment: isArabic ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        Text(
          'have_coupon'.tr,
          style: AppTextStyles.inputLabel(context),
        ),
        SizedBox(height: AppDimensions.screenHeight(context) * 0.01),
        Row(
          children: [
            // Apply Button
            Obx(
              () => SizedBox(
                width: 80,
                height: 50,
                child: ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : controller.applyCoupon,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: AppColors.grey300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppDimensions.borderRadius(context, 0.03),
                      ),
                    ),
                    padding: EdgeInsets.zero,
                  ),
                  child: controller.isLoading.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          'apply'.tr,
                          style: AppTextStyles.bodyText(context).copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ),
            SizedBox(width: 10),
            // Coupon Input Field
            Expanded(
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(
                    AppDimensions.borderRadius(context, 0.03),
                  ),
                  border: Border.all(color: AppColors.grey300),
                ),
                child: TextField(
                  controller: controller.couponCodeController,
                  textAlign: TextAlign.right,
                  style: AppTextStyles.bodyText(context),
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    hintText: '25gsh20',
                    hintStyle: AppTextStyles.inputHint(context),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: AppDimensions.spacing(context, 0.04),
                      vertical: AppDimensions.spacing(context, 0.035),
                    ),
                    suffixIcon: Padding(
                      padding: const EdgeInsets.all(9),
                      child: Image.asset(
                        AppImages.icon62,
                        width: 32,
                        height: 32,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  onSubmitted: (_) {
                    FocusScope.of(context).unfocus();
                  },
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAmountSummary(BuildContext context) {
    return Obx(
      () {
        final plan = controller.selectedSubscriptionPlan.value;

        // If no plan selected, show placeholder
        if (plan == null) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildAmountRow(
                context,
                'amount'.tr,
                'MRU 0',
                AppImages.icon51,
              ),
              SizedBox(height: 10),
              _buildAmountRow(
                context,
                'discount'.tr,
                'MRU 0',
                AppImages.icon52,
              ),
              SizedBox(height: 10),
              _buildAmountRow(
                context,
                'total_amount'.tr,
                'MRU 0',
                AppImages.icon53,
              ),
            ],
          );
        }

        final originalPrice = controller.isCouponApplied.value
            ? controller.originalAmount.value
            : (plan.price ?? 0.0);
        final discount = controller.discountAmount.value;
        final total = controller.isCouponApplied.value
            ? controller.totalAmount.value
            : (plan.price ?? 0.0);

        // Extract currency from formatted price (e.g., "MRU 1500" -> "MRU")
        String getCurrency() {
          if (plan.formattedPrice != null && plan.formattedPrice!.isNotEmpty) {
            final parts = plan.formattedPrice!.split(' ');
            if (parts.isNotEmpty) return parts[0];
          }
          return 'MRU';
        }

        final currency = getCurrency();

        // Format the display prices
        String getAmountDisplay() {
          if (controller.isCouponApplied.value && originalPrice > 0) {
            return '$currency ${originalPrice.toStringAsFixed(2)}';
          }
          return plan.formattedPrice ?? '$currency ${plan.price?.toStringAsFixed(2) ?? '0'}';
        }

        String getTotalDisplay() {
          if (controller.isCouponApplied.value && total > 0) {
            return '$currency ${total.toStringAsFixed(2)}';
          }
          return plan.formattedPrice ?? '$currency ${plan.price?.toStringAsFixed(2) ?? '0'}';
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _buildAmountRow(
              context,
              'amount'.tr,
              getAmountDisplay(),
              AppImages.icon51,
            ),
            SizedBox(height: 10),
            _buildAmountRow(
              context,
              'discount'.tr,
              discount > 0
                  ? '$currency ${discount.toStringAsFixed(2)}'
                  : '$currency 0',
              AppImages.icon52,
            ),
            SizedBox(height: 10),
            _buildAmountRow(
              context,
              'total_amount'.tr,
              getTotalDisplay(),
              AppImages.icon53,
            ),
          ],
        );
      },
    );
  }

  Widget _buildAmountRow(BuildContext context, String label, String amount, String iconPath) {
    final isArabic = Get.locale?.languageCode == 'ar';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: isArabic
          ? [
              // In Arabic: icon + label on left, amount on right
              Row(
                children: [
                  Image.asset(
                    iconPath,
                    width: 20,
                    height: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    label,
                    style: AppTextStyles.bodyText(context),
                  ),
                ],
              ),
              Text(
                amount,
                style: AppTextStyles.bodyText(context),
              ),
            ]
          : [
              // In other languages: amount on left, label + icon on right
              Text(
                amount,
                style: AppTextStyles.bodyText(context),
              ),
              Row(
                children: [
                  Text(
                    label,
                    style: AppTextStyles.bodyText(context),
                  ),
                  SizedBox(width: 8),
                  Image.asset(
                    iconPath,
                    width: 20,
                    height: 20,
                  ),
                ],
              ),
            ],
    );
  }

  Widget _buildCompletePaymentButton(BuildContext context) {
    return Obx(
      () => SizedBox(
        width: double.infinity,
        height: 55,
        child: ElevatedButton(
          onPressed: controller.isLoading.value
              ? null
              : controller.completePayment,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            disabledBackgroundColor: AppColors.grey300,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: controller.isLoading.value
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  'complete_payment'.tr,
                  style: AppTextStyles.buttonText(context).copyWith(
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }
}
