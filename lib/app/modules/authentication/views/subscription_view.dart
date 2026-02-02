import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_images.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_loader.dart';
import '../controllers/authentication_controller.dart';

class SubscriptionView extends GetView<AuthenticationController> {
  const SubscriptionView({super.key});

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    // Load subscription plans and current subscription when page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.subscriptionPlans.isEmpty) {
        controller.loadSubscriptionPlans();
      }
      // Refresh subscription status first to check if pending/active
      controller.refreshSubscriptionStatus();
    });

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
        SizedBox(height: screenSize.height * 0.05),
      ],
      children: [
        Obx(() {
          // Show loader while checking subscription status
          if (controller.isLoadingSubscription.value) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 50),
                child: AppLoader(size: 60),
              ),
            );
          }

          final subscription = controller.currentSubscription.value;
          final hasActiveSubscription = subscription?.hasSubscription == true && subscription?.isExpired == false;
          final hasPendingRequest = controller.hasPendingSubscription.value;

          if (hasActiveSubscription) {
            // User has valid/active plan - show only current subscription card
            return Column(
              children: [
                FadeInDown(
                  duration: const Duration(milliseconds: 500),
                  child: _buildCurrentSubscriptionCard(context),
                ),
                SizedBox(height: screenSize.height * 0.02),
              ],
            );
          } else if (hasPendingRequest) {
            // User has a pending subscription request - show pending message
            return Column(
              children: [
                FadeInDown(
                  duration: const Duration(milliseconds: 500),
                  child: _buildPendingSubscriptionCard(context),
                ),
                SizedBox(height: screenSize.height * 0.02),
              ],
            );
          } else {
            // No subscription or expired - show full subscription page
            return Column(
              children: [
                // Current Subscription Card (if exists and expired)
                if (subscription?.hasSubscription == true)
                  Column(
                    children: [
                      FadeInDown(
                        duration: const Duration(milliseconds: 500),
                        child: _buildCurrentSubscriptionCard(context),
                      ),
                      SizedBox(height: screenSize.height * 0.025),
                    ],
                  ),
                // Benefits Card
                FadeInDown(
                  duration: const Duration(milliseconds: 600),
                  child: _buildBenefitsCard(context),
                ),
                SizedBox(height: screenSize.height * 0.025),
                // Subscription Plans Section
                FadeInUp(
                  duration: const Duration(milliseconds: 500),
                  delay: const Duration(milliseconds: 200),
                  child: _buildSubscriptionPlansSection(context),
                ),
                SizedBox(height: screenSize.height * 0.025),
                // Payment Method Section
                FadeInUp(
                  duration: const Duration(milliseconds: 500),
                  delay: const Duration(milliseconds: 300),
                  child: _buildPaymentMethodSection(context),
                ),
                SizedBox(height: screenSize.height * 0.04),
                // Next Button
                FadeInUp(
                  duration: const Duration(milliseconds: 500),
                  delay: const Duration(milliseconds: 400),
                  child: _buildNextButton(context),
                ),
                SizedBox(height: screenSize.height * 0.02),
              ],
            );
          }
        }),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppDimensions.spacing(context, 0.04),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button (appears on the left in LTR, right in RTL)
          if (!isRtl)
            GestureDetector(
              onTap: () => Get.back(),
              child: const Icon(
                Icons.arrow_back,
                color: AppColors.white,
                size: 28,
              ),
            )
          else
            const SizedBox(width: 40),
          Text(
            'subscription_details'.tr,
            style: AppTextStyles.sectionTitle(context).copyWith(
              color: AppColors.white,
              fontSize: 18,
            ),
          ),
          // Back button (appears on the right in RTL, spacer in LTR)
          if (isRtl)
            GestureDetector(
              onTap: () => Get.back(),
              child: const Icon(
                Icons.arrow_forward,
                color: AppColors.white,
                size: 28,
              ),
            )
          else
            const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildBenefitsCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppDimensions.spacing(context, 0.05)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(
          image: AssetImage(AppImages.icon42),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        children: [
          Text(
            'why_choose_yearly'.tr,
            style: AppTextStyles.sectionTitle(context).copyWith(
              color: AppColors.white,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppDimensions.spacing(context, 0.03)),
          _buildBenefitItem(
            context,
            'subscription_benefit_1'.tr,
          ),
          _buildBenefitDivider(),
          _buildBenefitItem(
            context,
            'subscription_benefit_2'.tr,
          ),
          _buildBenefitDivider(),
          _buildBenefitItem(
            context,
            'subscription_benefit_3'.tr,
          ),
          _buildBenefitDivider(),
          _buildBenefitItem(
            context,
            'subscription_benefit_4'.tr,
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final dotWidth = 3.0;
          final dotSpacing = 4.0;
          final dotCount = (constraints.maxWidth / (dotWidth + dotSpacing)).floor();
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(dotCount, (index) {
              return Container(
                width: dotWidth,
                height: 1,
                margin: EdgeInsets.symmetric(horizontal: dotSpacing / 2),
                color: AppColors.white.withValues(alpha: 0.3),
              );
            }),
          );
        },
      ),
    );
  }

  Widget _buildBenefitItem(BuildContext context, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: AppDimensions.spacing(context, 0.01),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '✨',
            style: TextStyle(fontSize: 12),
          ),
          SizedBox(width: AppDimensions.spacing(context, 0.02)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.white,
                height: 1.4,
              ),
              textAlign: TextAlign.start,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionPlansSection(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                AppImages.icon41,
                width: 22,
                height: 22,
              ),
              const SizedBox(width: 8),
              Text(
                'subscription_plans'.tr,
                style: AppTextStyles.inputLabel(context),
              ),
            ],
          ),
        ),
        SizedBox(height: AppDimensions.spacing(context, 0.02)),
        // Clickable Subscription Plan Field
        GestureDetector(
          onTap: () => _showSubscriptionPlansBottomSheet(context),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: AppDimensions.spacing(context, 0.04),
              vertical: AppDimensions.spacing(context, 0.04),
            ),
            decoration: BoxDecoration(
              color: AppColors.grey100,
              borderRadius: BorderRadius.circular(
                AppDimensions.borderRadius(context, 0.03),
              ),
            ),
            child: Obx(() {
              if (controller.isLoadingPlans.value) {
                return const Center(
                  child: AppLoader(size: 20, showLogo: false,
                  ),
                );
              }

              final selectedPlan = controller.selectedSubscriptionPlan.value;
              if (selectedPlan == null) {
                return Row(
                  children: [
                    Expanded(
                      child: Text(
                        'choose_subscription_plan'.tr,
                        style: AppTextStyles.inputHint(context),
                      ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_down,
                      color: AppColors.grey400,
                    ),
                  ],
                );
              }
              // Build display text - plan name with price if available
              final planName = selectedPlan.planName ?? '';
              final priceText = selectedPlan.formattedPrice ??
                  (selectedPlan.price != null ? '${selectedPlan.price?.toStringAsFixed(0)} MRU' : '');
              final displayText = priceText.isNotEmpty
                  ? '$planName - $priceText'
                  : planName;

              return Row(
                children: [
                  // Plan name and price
                  Expanded(
                    child: Text(
                      displayText,
                      style: AppTextStyles.bodyText(context),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: AppDimensions.spacing(context, 0.02)),
                  Icon(
                    Icons.keyboard_arrow_down,
                    color: AppColors.grey400,
                  ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodSection(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            'payment_method'.tr,
            style: AppTextStyles.inputLabel(context),
          ),
        ),
        SizedBox(height: AppDimensions.spacing(context, 0.02)),
        GestureDetector(
          onTap: () => _showPaymentMethodBottomSheet(context),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: AppDimensions.spacing(context, 0.04),
              vertical: AppDimensions.spacing(context, 0.04),
            ),
            decoration: BoxDecoration(
              color: AppColors.grey100,
              borderRadius: BorderRadius.circular(
                AppDimensions.borderRadius(context, 0.03),
              ),
            ),
            child: Obx(() {
              return Row(
                children: [
                  Expanded(
                    child: Text(
                      controller.selectedPaymentMethod.value.isEmpty
                          ? 'select_payment_method'.tr
                          : controller.selectedPaymentMethod.value,
                      textAlign: TextAlign.start,
                      style: controller.selectedPaymentMethod.value.isEmpty
                          ? AppTextStyles.inputHint(context)
                          : AppTextStyles.bodyText(context),
                    ),
                  ),
                  Icon(
                    Icons.keyboard_arrow_down,
                    color: AppColors.grey500,
                    size: 24,
                  ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildNextButton(BuildContext context) {
    return Obx(
      () => SizedBox(
        width: double.infinity,
        height: 55,
        child: ElevatedButton(
          onPressed: controller.isLoading.value
              ? null
              : controller.completeSubscription,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            disabledBackgroundColor: AppColors.grey300,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: controller.isLoading.value
              ? const AppLoader(size: 24, showLogo: false)
              : Text(
                  'next'.tr,
                  style: AppTextStyles.buttonText(context).copyWith(
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }

  void _showPaymentMethodBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: false,
      builder: (context) => _PaymentMethodBottomSheet(
        items: controller.paymentMethods,
        selectedValue: controller.selectedPaymentMethod,
        onSelect: (value) {
          controller.selectPaymentMethod(value);
          Get.back();
        },
      ),
    );
  }

  void _showSubscriptionPlansBottomSheet(BuildContext context) {
    // Plans are already loaded when page opens, just show bottom sheet
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: false,
      builder: (context) => const _SubscriptionPlansBottomSheet(),
    );
  }

  Widget _buildCurrentSubscriptionCard(BuildContext context) {
    final subscription = controller.currentSubscription.value;
    if (subscription == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'your_current_subscription'.tr,
                style: const TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: subscription.isExpired ? AppColors.error : AppColors.golden,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  subscription.isExpired ? 'subscription_expired'.tr : 'subscription_active'.tr,
                  style: const TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (subscription.planName != null && subscription.planName!.isNotEmpty)
            _buildSubscriptionInfoRow(
              icon: Icons.card_membership,
              label: 'subscription_plan_label'.tr,
              value: subscription.planName!,
            ),
          if (subscription.startDate != null && subscription.startDate!.isNotEmpty)
            _buildSubscriptionInfoRow(
              icon: Icons.calendar_today,
              label: 'subscription_start_date'.tr,
              value: subscription.startDate!,
            ),
          if (subscription.endDate != null && subscription.endDate!.isNotEmpty)
            _buildSubscriptionInfoRow(
              icon: Icons.event,
              label: 'subscription_end_date'.tr,
              value: subscription.endDate!,
            ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.white.withValues(alpha: 0.9),
            size: 18,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingSubscriptionCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.golden,
            AppColors.golden.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.golden.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.hourglass_empty,
            color: Colors.white,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            'subscription_pending_title'.tr,
            style: const TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'subscription_pending_message'.tr,
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.9),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.info_outline,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'subscription_pending_note'.tr,
                  style: const TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Top curve clipper for wave effect
class _TopCurveClipper extends CustomClipper<Path> {
  final double notchRadius;

  _TopCurveClipper({required this.notchRadius});

  @override
  Path getClip(Size size) {
    final path = Path();
    final notchWidth = notchRadius * 2.5;
    final notchCenterX = size.width / 2;

    path.lineTo(0, notchRadius);
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, notchRadius);

    path.arcToPoint(
      Offset(size.width - notchRadius, 0),
      radius: Radius.circular(notchRadius),
      clockwise: false,
    );

    path.lineTo(notchCenterX + notchWidth / 2, 0);

    path.quadraticBezierTo(
      notchCenterX,
      -notchRadius * 0.5,
      notchCenterX - notchWidth / 2,
      0,
    );

    path.lineTo(notchRadius, 0);

    path.arcToPoint(
      Offset(0, notchRadius),
      radius: Radius.circular(notchRadius),
      clockwise: false,
    );

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

// Payment method bottom sheet widget
class _PaymentMethodBottomSheet extends StatelessWidget {
  final List<String> items;
  final RxString selectedValue;
  final Function(String) onSelect;

  const _PaymentMethodBottomSheet({
    required this.items,
    required this.selectedValue,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final notchRadius = screenSize.width * 0.08;

    return Transform.translate(
      offset: Offset(0, notchRadius * 0.8),
      child: ClipPath(
        clipper: _TopCurveClipper(notchRadius: notchRadius),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Transform.translate(
              offset: Offset(0, -notchRadius * 0.8),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.only(top: notchRadius * 0.8),
                decoration: const BoxDecoration(
                  color: AppColors.white,
                ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: AppDimensions.spacing(context, 0.02)),
                  // Header with close button and title
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppDimensions.spacing(context, 0.04),
                      vertical: AppDimensions.spacing(context, 0.02),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Close button
                        FadeInLeft(
                          duration: const Duration(milliseconds: 400),
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: AppColors.grey100,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: AppColors.grey600,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                        // Title
                        FadeInDown(
                          duration: const Duration(milliseconds: 500),
                          child: Text(
                            'choose_payment_method'.tr,
                            style: AppTextStyles.sectionTitle(context),
                          ),
                        ),
                        // Empty space for balance
                        const SizedBox(width: 36),
                      ],
                    ),
                  ),
                  // Divider
                  Divider(
                    color: AppColors.grey200,
                    height: 1,
                  ),
                  SizedBox(height: AppDimensions.spacing(context, 0.02)),
                  // Options
                  ...List.generate(
                    items.length,
                    (index) => FadeInUp(
                      duration: const Duration(milliseconds: 400),
                      delay: Duration(milliseconds: 100 * index),
                      child: _buildOption(
                        context: context,
                        item: items[index],
                        isLast: index == items.length - 1,
                      ),
                    ),
                  ),
                  SizedBox(height: AppDimensions.spacing(context, 0.04)),
                ],
              ),
            ),
          ),
          // Small dot at top center where curve peaks
          Positioned(
            top: -screenSize.width * 0.025 + 5,
            left: screenSize.width / 2 - screenSize.width * 0.0125,
            child: Container(
              width: screenSize.width * 0.025,
              height: screenSize.width * 0.025,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    ));
  }

  Widget _buildOption({
    required BuildContext context,
    required String item,
    required bool isLast,
  }) {
    return Obx(
      () {
        final isSelected = selectedValue.value == item;
        return Column(
          children: [
            InkWell(
              onTap: () => onSelect(item),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacing(context, 0.04),
                  vertical: AppDimensions.spacing(context, 0.03),
                ),
                child: Row(
                  children: [
                    // Radio button
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.grey400,
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? Center(
                              child: Container(
                                width: 12,
                                height: 12,
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            )
                          : null,
                    ),
                    const Spacer(),
                    // Item name
                    Text(
                      item,
                      style: AppTextStyles.bodyText(context).copyWith(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? AppColors.primary : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (!isLast)
              Divider(
                color: AppColors.grey200,
                height: 1,
                indent: AppDimensions.spacing(context, 0.04),
                endIndent: AppDimensions.spacing(context, 0.04),
              ),
          ],
        );
      },
    );
  }
}

// Subscription plans bottom sheet widget
class _SubscriptionPlansBottomSheet extends GetView<AuthenticationController> {
  const _SubscriptionPlansBottomSheet();

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final notchRadius = screenSize.width * 0.08;

    return Transform.translate(
      offset: Offset(0, notchRadius * 0.8),
      child: ClipPath(
        clipper: _TopCurveClipper(notchRadius: notchRadius),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Transform.translate(
              offset: Offset(0, -notchRadius * 0.8),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.only(top: notchRadius * 0.8),
                decoration: const BoxDecoration(
                  color: AppColors.white,
                ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: AppDimensions.spacing(context, 0.02)),
                  // Header with close button and title
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppDimensions.spacing(context, 0.04),
                      vertical: AppDimensions.spacing(context, 0.02),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Close button
                        FadeInLeft(
                          duration: const Duration(milliseconds: 400),
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: AppColors.grey100,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: AppColors.grey600,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                        // Title
                        FadeInDown(
                          duration: const Duration(milliseconds: 500),
                          child: Text(
                            'choose_subscription_plan'.tr,
                            style: AppTextStyles.sectionTitle(context),
                          ),
                        ),
                        // Empty space for balance
                        const SizedBox(width: 36),
                      ],
                    ),
                  ),
                  // Divider
                  Divider(
                    color: AppColors.grey200,
                    height: 1,
                  ),
                  SizedBox(height: AppDimensions.spacing(context, 0.02)),
                  // Plans or Loading State
                  Obx(() {
                    if (controller.isLoadingPlans.value) {
                      return Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: AppDimensions.spacing(context, 0.08),
                        ),
                        child: const Center(
                          child: AppLoader(size: 60),
                        ),
                      );
                    }

                    if (controller.subscriptionPlans.isEmpty) {
                      return Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: AppDimensions.spacing(context, 0.08),
                        ),
                        child: Text(
                          'no_plans_available'.tr,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyText(context).copyWith(
                            color: AppColors.grey500,
                          ),
                        ),
                      );
                    }

                    return Column(
                      children: [
                        ...List.generate(
                          controller.subscriptionPlans.length,
                          (index) {
                            final plan = controller.subscriptionPlans[index];
                            return FadeInUp(
                              duration: const Duration(milliseconds: 400),
                              delay: Duration(milliseconds: 100 * index),
                              child: _buildPlanOption(
                                context: context,
                                plan: plan,
                                isLast: index == controller.subscriptionPlans.length - 1,
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  }),
                  SizedBox(height: AppDimensions.spacing(context, 0.04)),
                ],
              ),
            ),
          ),
          // Small dot at top center where curve peaks
          Positioned(
            top: -screenSize.width * 0.025 + 5,
            left: screenSize.width / 2 - screenSize.width * 0.0125,
            child: Container(
              width: screenSize.width * 0.025,
              height: screenSize.width * 0.025,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    ),
    );
  }

  Widget _buildPlanOption({
    required BuildContext context,
    required plan,
    required bool isLast,
  }) {
    return Obx(() {
      final isSelected = controller.selectedSubscriptionPlan.value?.id == plan.id;
      return Column(
        children: [
          InkWell(
            onTap: () {
              controller.selectSubscriptionPlan(plan);
              Get.back();
            },
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppDimensions.spacing(context, 0.04),
                vertical: AppDimensions.spacing(context, 0.03),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Radio button
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.grey400,
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? Center(
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          )
                        : null,
                  ),
                  SizedBox(width: AppDimensions.spacing(context, 0.03)),
                  // Plan name (flexible to handle any text length)
                  Expanded(
                    child: Text(
                      plan.planName ?? '',
                      style: AppTextStyles.bodyText(context).copyWith(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? AppColors.primary : null,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: AppDimensions.spacing(context, 0.02)),
                  // Price
                  Text(
                    plan.formattedPrice ?? (plan.price != null ? '${plan.price.toStringAsFixed(0)} MRU' : ''),
                    style: AppTextStyles.bodyText(context).copyWith(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? AppColors.primary : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (!isLast)
            Divider(
              color: AppColors.grey200,
              height: 1,
              indent: AppDimensions.spacing(context, 0.04),
              endIndent: AppDimensions.spacing(context, 0.04),
            ),
        ],
      );
    });
  }
}
