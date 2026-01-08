import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';

import '../../../core/constants/app_images.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_dialog.dart';
import '../widgets/ticket_type_bottom_sheet.dart';
import '../controllers/profile_controller.dart';

class HelpView extends GetView<ProfileController> {
  const HelpView({super.key});

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    // Load support center data when view opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadSupportCenter();
    });

    // Set status bar to white icons
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      extendBody: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppImages.image3),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            // Header with title and back button
            SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  top: screenSize.height * 0.05,
                  bottom: screenSize.height * 0.02,
                  left: screenSize.width * 0.05,
                  right: screenSize.width * 0.05,
                ),
                child: Column(
                  children: [
                    // Back button and title
                    FadeIn(
                      duration: const Duration(milliseconds: 800),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const SizedBox(width: 48),
                          Text(
                            'help_center'.tr,
                            style: AppTextStyles.notificationPageTitle(context),
                          ),
                          IconButton(
                            onPressed: () => Get.back(),
                            icon: const Icon(
                              Icons.arrow_forward,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: screenSize.height * 0.02),
                    // Subtitle
                    FadeIn(
                      duration: const Duration(milliseconds: 800),
                      delay: const Duration(milliseconds: 200),
                      child: Text(
                        'help_subtitle'.tr,
                        style: const TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 24,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFFFFFFFF),
                          height: 1.3,
                          letterSpacing: 0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // White container with content
            Expanded(
              child: ClipPath(
                clipper: _TopCurveClipper(),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      top: -(screenSize.width * 0.08) * 0.8,
                      left: 0,
                      right: 0,
                      bottom: -(screenSize.width * 0.08) * 0.8,
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.only(
                          top: (screenSize.width * 0.08) * 0.8,
                        ),
                        color: Colors.white,
                        child: SingleChildScrollView(
                          physics: const ClampingScrollPhysics(),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: screenSize.width * 0.05,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                SizedBox(height: screenSize.height * 0.03),
                                // Support numbers section
                                FadeInUp(
                                  duration: const Duration(milliseconds: 800),
                                  delay: const Duration(milliseconds: 200),
                                  child: _buildSupportNumbers(context),
                                ),
                                SizedBox(height: screenSize.height * 0.04),
                                // FAQs section
                                FadeInUp(
                                  duration: const Duration(milliseconds: 800),
                                  delay: const Duration(milliseconds: 300),
                                  child: _buildFaqsSection(context),
                                ),
                                SizedBox(height: screenSize.height * 0.04),
                                // Contact section
                                FadeInUp(
                                  duration: const Duration(milliseconds: 800),
                                  delay: const Duration(milliseconds: 400),
                                  child: _buildContactSection(context),
                                ),
                                SizedBox(height: screenSize.height * 0.15),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Small dot at top center below the wave
                    Positioned(
                      top: -screenSize.width * 0.025 + 5,
                      left: screenSize.width / 2 - screenSize.width * 0.0125,
                      child: Container(
                        width: screenSize.width * 0.025,
                        height: screenSize.width * 0.025,
                        decoration: const BoxDecoration(
                          color: Color(0xFF000D47),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportNumbers(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'support_numbers'.tr,
          style: const TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF10162E),
            height: 1.71,
            letterSpacing: 0,
          ),
          textAlign: TextAlign.right,
        ),
        const SizedBox(height: 16),
        // Mobile number
        Obx(
          () => _buildContactItem(
            iconPath: AppImages.icon64,
            label: 'mobile'.tr,
            value:
                controller.mobileNumber.value.isNotEmpty
                    ? controller.mobileNumber.value
                    : '...',
            onTap:
                () =>
                    controller.mobileNumber.value.isNotEmpty
                        ? _makePhoneCall(controller.mobileNumber.value)
                        : null,
          ),
        ),
        const Divider(height: 24),
        // WhatsApp number
        Obx(
          () => _buildContactItem(
            iconPath: AppImages.icon65,
            label: 'whatsapp_number'.tr,
            value:
                controller.whatsappNumber.value.isNotEmpty
                    ? controller.whatsappNumber.value
                    : '...',
            onTap:
                () =>
                    controller.whatsappNumber.value.isNotEmpty
                        ? _openWhatsApp(controller.whatsappNumber.value)
                        : null,
          ),
        ),
      ],
    );
  }

  Widget _buildContactItem({
    required String iconPath,
    required String label,
    required String value,
    required VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          RichText(
            textAlign: TextAlign.right,
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$label : ',
                  style: const TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey,
                    height: 2.0,
                    letterSpacing: 0,
                  ),
                ),
                TextSpan(
                  text: value,
                  style: const TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF000D47),
                    height: 2.0,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Image.asset(iconPath, width: 21, height: 21),
        ],
      ),
    );
  }

  Widget _buildFaqsSection(BuildContext context) {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            'some_faqs'.tr,
            style: const TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF10162E),
              height: 1.71,
              letterSpacing: 0,
            ),
            textAlign: TextAlign.right,
          ),
          const SizedBox(height: 16),
          if (controller.isLoadingSupportCenter.value)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              ),
            )
          else
            ...List.generate(controller.faqs.length, (index) {
              final faq = controller.faqs[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _FaqItem(
                  question: faq.question,
                  answer: faq.answer,
                  index: index,
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildContactSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Telescope icon
          Image.asset(AppImages.icon66, width: 32, height: 32),
          const SizedBox(height: 4),
          Text(
            'didnt_find_what_looking_for'.tr,
            style: const TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF000D47),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          // Contact buttons
          Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildContactButton(
                  iconPath: AppImages.icon67,
                  label: 'contact_support_team'.tr,
                  onTap: () {
                    TicketTypeBottomSheet.show(context);
                  },
                ),
                const SizedBox(width: 12),
                _buildContactButton(
                  iconPath: AppImages.icon68,
                  label: 'call_us'.tr,
                  onTap:
                      controller.mobileNumber.value.isNotEmpty
                          ? () => _makePhoneCall(controller.mobileNumber.value)
                          : () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactButton({
    required String iconPath,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Image.asset(iconPath, width: 32, height: 32),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFF000000),
              height: 1.43,
              letterSpacing: 0,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _makePhoneCall(String phoneNumber) {
    AppDialog.showInfo(
      message: '${'calling_phone_number'.tr} $phoneNumber',
    );
  }

  void _openWhatsApp(String phoneNumber) {
    AppDialog.showInfo(
      message: '${'opening_whatsapp'.tr} $phoneNumber',
    );
  }
}

// Custom clipper for the wavy top edge
class _TopCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final notchRadius = size.width * 0.08;
    final notchWidth = notchRadius * 2.5;
    final notchCenterX = size.width / 2;

    // Start from top left
    path.lineTo(0, notchRadius);

    // Left side going down
    path.lineTo(0, size.height);

    // Bottom
    path.lineTo(size.width, size.height);

    // Right side going up
    path.lineTo(size.width, notchRadius);

    // Top right corner curve
    path.arcToPoint(
      Offset(size.width - notchRadius, 0),
      radius: Radius.circular(notchRadius),
      clockwise: false,
    );

    // Line to notch start (right side)
    path.lineTo(notchCenterX + notchWidth / 2, 0);

    // Create ONE wavy curve in the middle
    path.quadraticBezierTo(
      notchCenterX, // control point x (center)
      -notchRadius * 0.5, // control point y (depth of wave)
      notchCenterX - notchWidth / 2, // end point x
      0, // end point y
    );

    // Line to top left corner
    path.lineTo(notchRadius, 0);

    // Top left corner curve
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

// Stateful FAQ item widget
class _FaqItem extends StatefulWidget {
  final String question;
  final String answer;
  final int index;

  const _FaqItem({
    required this.question,
    required this.answer,
    required this.index,
  });

  @override
  State<_FaqItem> createState() => _FaqItemState();
}

class _FaqItemState extends State<_FaqItem> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEAEAEA), width: 1),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                isExpanded = !isExpanded;
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    isExpanded ? Icons.remove : Icons.add,
                    color: const Color(0xFF000D47),
                    size: 24,
                  ),
                  const Spacer(),
                  Expanded(
                    flex: 10,
                    child: Text(
                      widget.question,
                      style: const TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF000D47),
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: Text(
                widget.answer,
                style: const TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey,
                  height: 1.6,
                ),
                textAlign: TextAlign.right,
              ),
            ),
        ],
      ),
    );
  }
}
