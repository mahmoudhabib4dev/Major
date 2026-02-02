import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:proste_bezier_curve/proste_bezier_curve.dart';

import '../../../core/constants/app_images.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/widgets/app_dialog.dart';
import '../../../core/widgets/app_loader.dart';
import '../controllers/profile_controller.dart';
import '../models/complaint_types_response_model.dart';

class _TopCurveClipper extends CustomClipper<Path> {
  final double notchRadius;

  _TopCurveClipper({required this.notchRadius});

  @override
  Path getClip(Size size) {
    final path = Path();
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

class TicketTypeBottomSheet extends StatefulWidget {
  const TicketTypeBottomSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: false,
      builder: (context) => const TicketTypeBottomSheet(),
    );
  }

  @override
  State<TicketTypeBottomSheet> createState() => _TicketTypeBottomSheetState();
}

class _TicketTypeBottomSheetState extends State<TicketTypeBottomSheet> {
  final ProfileController controller = Get.find<ProfileController>();
  int? selectedTicketTypeId;

  @override
  void initState() {
    super.initState();
    // Load complaint types from API
    controller.loadComplaintTypes();
  }

  void _showProblemDialog() {
    if (selectedTicketTypeId == null) {
      AppDialog.showError(message: 'please_select_ticket_type'.tr);
      return;
    }
    final ticketTypeId = selectedTicketTypeId!; // Capture value before closing
    Navigator.pop(context); // Close bottom sheet first
    // Use Get.context to ensure a valid context after bottom sheet is closed
    _showWriteProblemDialog(Get.context!, ticketTypeId);
  }

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
                    // Space for wave
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
                              'choose_ticket_type'.tr,
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
                    // Ticket type options
                    Obx(() {
                      if (controller.isLoadingComplaintTypes.value) {
                        return Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: AppDimensions.spacing(context, 0.04),
                          ),
                          child: const Center(child: AppLoader(size: 40)),
                        );
                      }

                      final types = controller.complaintTypes;
                      if (types.isEmpty) {
                        return Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: AppDimensions.spacing(context, 0.04),
                          ),
                          child: Center(
                            child: Text(
                              'no_complaint_types'.tr,
                              style: AppTextStyles.bodyText(context).copyWith(
                                color: AppColors.grey500,
                              ),
                            ),
                          ),
                        );
                      }

                      // Auto-select first type if none selected
                      if (selectedTicketTypeId == null && types.isNotEmpty) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          setState(() {
                            selectedTicketTypeId = types.first.id;
                          });
                        });
                      }

                      return Column(
                        children: List.generate(
                          types.length,
                          (index) => FadeInUp(
                            duration: const Duration(milliseconds: 400),
                            delay: Duration(milliseconds: 100 * index),
                            child: _buildTicketTypeOption(
                              context: context,
                              ticketType: types[index],
                              isLast: index == types.length - 1,
                            ),
                          ),
                        ),
                      );
                    }),
                    SizedBox(height: AppDimensions.spacing(context, 0.04)),
                    // Confirm button
                    ElasticIn(
                      duration: const Duration(milliseconds: 800),
                      delay: const Duration(milliseconds: 400),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppDimensions.spacing(context, 0.04),
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: _showProblemDialog,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: Text(
                              'confirm'.tr,
                              style: AppTextStyles.buttonText(context).copyWith(
                                color: AppColors.white,
                              ),
                            ),
                          ),
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
      ),
    );
  }

  Widget _buildTicketTypeOption({
    required BuildContext context,
    required ComplaintType ticketType,
    required bool isLast,
  }) {
    final isSelected = selectedTicketTypeId == ticketType.id;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Column(
      children: [
        InkWell(
          onTap: () {
            setState(() {
              selectedTicketTypeId = ticketType.id;
            });
          },
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppDimensions.spacing(context, 0.04),
              vertical: AppDimensions.spacing(context, 0.03),
            ),
            child: Row(
              textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
              children: [
                // Ticket type name
                Expanded(
                  child: Text(
                    ticketType.name,
                    style: AppTextStyles.bodyText(context).copyWith(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? AppColors.primary : null,
                    ),
                    textAlign: isRtl ? TextAlign.right : TextAlign.left,
                  ),
                ),
                const SizedBox(width: 12),
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
  }
}

class _DialogTopCurveClipper extends CustomClipper<Path> {
  final double notchRadius;

  _DialogTopCurveClipper({this.notchRadius = 45});

  @override
  Path getClip(Size size) {
    final path = Path();
    final cornerRadius = 20.0;
    final notchCenterX = size.width / 2;

    // Start from bottom left
    path.moveTo(0, size.height - cornerRadius);

    // Bottom left corner
    path.quadraticBezierTo(0, size.height, cornerRadius, size.height);

    // Bottom edge
    path.lineTo(size.width - cornerRadius, size.height);

    // Bottom right corner
    path.quadraticBezierTo(size.width, size.height, size.width, size.height - cornerRadius);

    // Right edge
    path.lineTo(size.width, cornerRadius);

    // Top right corner
    path.quadraticBezierTo(size.width, 0, size.width - cornerRadius, 0);

    // Top edge to notch (right side)
    path.lineTo(notchCenterX + notchRadius * 1.2, 0);

    // Create curved notch using arcTo - centered at y=0 so it starts and ends at the top edge
    final arcRect = Rect.fromLTRB(
      notchCenterX - notchRadius * 1.2,
      -notchRadius * 1.3,
      notchCenterX + notchRadius * 1.2,
      notchRadius * 1.3,
    );
    path.arcTo(arcRect, 0, 3.14159, false);

    // Top edge to left corner
    path.lineTo(cornerRadius, 0);

    // Top left corner
    path.quadraticBezierTo(0, 0, 0, cornerRadius);

    // Left edge
    path.lineTo(0, size.height - cornerRadius);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

class _AnimatedStar extends StatefulWidget {
  final bool isSelected;
  final VoidCallback onTap;

  const _AnimatedStar({
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_AnimatedStar> createState() => _AnimatedStarState();
}

class _AnimatedStarState extends State<_AnimatedStar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.3)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.3, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 50,
      ),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    _controller.forward(from: 0);
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Icon(
            Icons.star,
            size: 40,
            color: widget.isSelected
                ? const Color(0xFFFFD964)
                : const Color(0xFFE0E0E0),
          ),
        ),
      ),
    );
  }
}

void showRatingDialog(BuildContext context) {
  int selectedRating = 4;
  final TextEditingController notesController = TextEditingController();
  final iconSize = 70.0;
  final iconRadius = iconSize / 2;
  final isRtl = Directionality.of(context) == TextDirection.rtl;

  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            // Main dialog content with curved notch
            Padding(
              padding: EdgeInsets.only(top: iconRadius),
              child: ClipPath(
                clipper: _DialogTopCurveClipper(notchRadius: iconRadius),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                  ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 40),
                    // Title
                    FadeInDown(
                      duration: const Duration(milliseconds: 500),
                      delay: const Duration(milliseconds: 200),
                      child: Text(
                        'rate_your_experience'.tr,
                        style: const TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF000D47),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Subtitle
                    FadeIn(
                      duration: const Duration(milliseconds: 500),
                      delay: const Duration(milliseconds: 400),
                      child: Text(
                        'help_us_improve'.tr,
                        style: const TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 44),
                    // Star rating
                    FadeInUp(
                      duration: const Duration(milliseconds: 600),
                      delay: const Duration(milliseconds: 500),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          return _AnimatedStar(
                            isSelected: index < selectedRating,
                            onTap: () {
                              setState(() {
                                selectedRating = index + 1;
                              });
                            },
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Notes input field
                    FadeIn(
                      duration: const Duration(milliseconds: 500),
                      delay: const Duration(milliseconds: 700),
                      child: TextField(
                        controller: notesController,
                        maxLines: 4,
                        textAlign: isRtl ? TextAlign.right : TextAlign.left,
                        textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
                        decoration: InputDecoration(
                          hintText: 'your_notes'.tr,
                          hintStyle: const TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey,
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF8F8F8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.all(16),
                        ),
                        style: const TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Confirm button
                    SlideInUp(
                      duration: const Duration(milliseconds: 600),
                      delay: const Duration(milliseconds: 800),
                      child: SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: () async {
                            // Get ProfileController
                            final profileController = Get.find<ProfileController>();

                            // Validate comment is not empty
                            if (notesController.text.trim().isEmpty) {
                              AppDialog.showError(
                                message: 'يرجى كتابة ملاحظاتك',
                              );
                              return;
                            }

                            // Close dialog first
                            Navigator.pop(context);

                            // Submit review
                            final success = await profileController.submitReview(
                              rating: selectedRating,
                              comment: notesController.text.trim(),
                            );

                            // Show success message if submitted
                            if (success) {
                              AppDialog.showSuccess(
                                message: 'rating_submitted'.tr,
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text(
                            'confirm'.tr,
                            style: AppTextStyles.buttonText(context).copyWith(
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ),
            ),
            // Icon at the top - sits in the notch
            Positioned(
              top: 0,
              child: BounceInDown(
                duration: const Duration(milliseconds: 800),
                child: Container(
                  width: iconSize,
                  height: iconSize,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F7F7),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Image.asset(
                      AppImages.icon69,
                      width: 32,
                      height: 32,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

void _showWriteProblemDialog(BuildContext context, int complaintTypeId) {
  final TextEditingController problemController = TextEditingController();
  final iconSize = 70.0;
  final iconRadius = iconSize / 2;
  final isRtl = Directionality.of(context) == TextDirection.rtl;

  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          // Main dialog content with notch
          Padding(
            padding: EdgeInsets.only(top: iconRadius),
            child: ClipPath(
              clipper: _DialogTopCurveClipper(notchRadius: iconRadius),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 40),
                // Title
                FadeInDown(
                  duration: const Duration(milliseconds: 500),
                  delay: const Duration(milliseconds: 200),
                  child: Text(
                    'write_your_problem'.tr,
                    style: const TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF000D47),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 12),
                // Subtitle
                FadeIn(
                  duration: const Duration(milliseconds: 500),
                  delay: const Duration(milliseconds: 400),
                  child: Text(
                    'problem_description_hint'.tr,
                    style: const TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 24),
                // Text input field
                FadeInUp(
                  duration: const Duration(milliseconds: 600),
                  delay: const Duration(milliseconds: 500),
                  child: TextField(
                    controller: problemController,
                    maxLines: 6,
                    textAlign: isRtl ? TextAlign.right : TextAlign.left,
                    textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
                    decoration: InputDecoration(
                      hintText: 'problem_description'.tr,
                      hintStyle: const TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF8F8F8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                    style: const TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Send button
                SlideInUp(
                  duration: const Duration(milliseconds: 600),
                  delay: const Duration(milliseconds: 700),
                  child: SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () async {
                        // Validate message is not empty
                        if (problemController.text.trim().isEmpty) {
                          AppDialog.showError(
                            message: 'please_enter_problem_description'.tr,
                          );
                          return;
                        }

                        // Capture values before closing dialog
                        final message = problemController.text.trim();
                        final typeId = complaintTypeId;

                        // Close dialog first
                        Navigator.pop(context);

                        // Get ProfileController and submit complaint
                        try {
                          final profileController = Get.find<ProfileController>();
                          final success = await profileController.submitComplaint(
                            complaintTypeId: typeId,
                            message: message,
                          );

                          // Show success message if submitted
                          if (success) {
                            AppDialog.showSuccess(
                              message: 'problem_submitted'.tr,
                            );
                          }
                        } catch (e) {
                          AppDialog.showError(
                            message: 'error_submitting_complaint'.tr,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        'send'.tr,
                        style: AppTextStyles.buttonText(context).copyWith(
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            ),
            ),
          ),
          // Icon at the top - sits in the notch
          Positioned(
            top: 0,
            child: BounceInDown(
              duration: const Duration(milliseconds: 800),
              child: Container(
                width: iconSize,
                height: iconSize,
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F7F7),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Center(
                  child: Image.asset(
                    AppImages.icon67,
                    width: 50,
                    height: 50,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
