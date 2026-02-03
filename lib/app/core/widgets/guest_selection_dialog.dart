import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_dimensions.dart';
import '../../modules/authentication/models/stage_model.dart';
import '../../modules/authentication/models/division_model.dart';

class GuestSelectionDialog extends StatefulWidget {
  final List<StageModel> stages;
  final Function(int stageId, String stageName, int divisionId, String divisionName) onConfirm;
  final Future<List<DivisionModel>> Function(int stageId) loadDivisions;

  const GuestSelectionDialog({
    super.key,
    required this.stages,
    required this.onConfirm,
    required this.loadDivisions,
  });

  @override
  State<GuestSelectionDialog> createState() => _GuestSelectionDialogState();
}

class _GuestSelectionDialogState extends State<GuestSelectionDialog> {
  String selectedStageName = '';
  int selectedStageId = 0;
  String selectedDivisionName = '';
  int selectedDivisionId = 0;
  List<DivisionModel> divisions = [];
  bool isLoadingDivisions = false;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: EdgeInsets.all(AppDimensions.spacing(context, 0.05)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Text(
              'continue_as_guest'.tr,
              style: AppTextStyles.sectionTitle(context).copyWith(
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppDimensions.spacing(context, 0.02)),

            // Subtitle
            Text(
              'select_preferences'.tr,
              style: AppTextStyles.bodyText(context).copyWith(
                color: AppColors.grey600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppDimensions.spacing(context, 0.04)),

            // Educational Stage Field
            _buildSelectionField(
              context: context,
              label: 'educational_stage'.tr,
              hint: 'choose_educational_stage'.tr,
              value: selectedStageName,
              onTap: () => _showStageBottomSheet(context),
            ),
            SizedBox(height: AppDimensions.spacing(context, 0.03)),

            // Division Field
            _buildSelectionField(
              context: context,
              label: 'division'.tr,
              hint: isLoadingDivisions
                  ? 'loading'.tr
                  : selectedStageId == 0
                      ? 'select_educational_stage_first'.tr
                      : 'choose_division'.tr,
              value: selectedDivisionName,
              onTap: selectedStageId == 0 || isLoadingDivisions
                  ? null
                  : () => _showDivisionBottomSheet(context),
            ),
            SizedBox(height: AppDimensions.spacing(context, 0.04)),

            // Buttons
            Row(
              children: [
                // Cancel button
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        vertical: AppDimensions.spacing(context, 0.035),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      side: BorderSide(color: AppColors.grey400),
                    ),
                    child: Text(
                      'cancel'.tr,
                      style: AppTextStyles.buttonText(context).copyWith(
                        color: AppColors.grey600,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: AppDimensions.spacing(context, 0.03)),
                // Confirm button
                Expanded(
                  child: ElevatedButton(
                    onPressed: selectedStageId > 0 && selectedDivisionId > 0
                        ? () {
                            widget.onConfirm(
                              selectedStageId,
                              selectedStageName,
                              selectedDivisionId,
                              selectedDivisionName,
                            );
                            Get.back();
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      disabledBackgroundColor: AppColors.grey300,
                      padding: EdgeInsets.symmetric(
                        vertical: AppDimensions.spacing(context, 0.035),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      'confirm'.tr,
                      style: AppTextStyles.buttonText(context).copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionField({
    required BuildContext context,
    required String label,
    required String hint,
    required String value,
    required VoidCallback? onTap,
  }) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return Column(
      crossAxisAlignment: isRtl ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Align(
          alignment: isRtl ? Alignment.centerRight : Alignment.centerLeft,
          child: Text(
            label,
            style: AppTextStyles.inputLabel(context),
          ),
        ),
        SizedBox(height: AppDimensions.spacing(context, 0.01)),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: AppDimensions.spacing(context, 0.04),
              vertical: AppDimensions.spacing(context, 0.04),
            ),
            decoration: BoxDecoration(
              color: onTap == null ? AppColors.grey100.withValues(alpha: 0.5) : AppColors.grey100,
              borderRadius: BorderRadius.circular(
                AppDimensions.borderRadius(context, 0.03),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value.isEmpty ? hint : value,
                    textAlign: TextAlign.start,
                    style: value.isEmpty
                        ? AppTextStyles.inputHint(context)
                        : AppTextStyles.bodyText(context),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down,
                  color: onTap == null ? AppColors.grey400 : AppColors.grey500,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showStageBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _SelectionBottomSheet(
        title: 'choose_educational_stage'.tr,
        items: widget.stages.map((s) => s.name).toList(),
        selectedValue: selectedStageName,
        onSelect: (value) async {
          final stage = widget.stages.firstWhere((s) => s.name == value);

          // Close bottom sheet first
          Navigator.pop(context);

          // Update state and show loading
          setState(() {
            selectedStageName = value;
            selectedStageId = stage.id;
            selectedDivisionName = '';
            selectedDivisionId = 0;
            divisions.clear();
            isLoadingDivisions = true;
          });

          // Load divisions for selected stage
          try {
            await _loadDivisions(stage.id);
          } catch (e) {
            print('Error loading divisions: $e');
          } finally {
            setState(() {
              isLoadingDivisions = false;
            });
          }
        },
      ),
    );
  }

  void _showDivisionBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _SelectionBottomSheet(
        title: 'choose_division'.tr,
        items: divisions.map((d) => d.name).toList(),
        selectedValue: selectedDivisionName,
        onSelect: (value) {
          final division = divisions.firstWhere((d) => d.name == value);
          setState(() {
            selectedDivisionName = value;
            selectedDivisionId = division.id;
          });
          Get.back();
        },
      ),
    );
  }

  Future<void> _loadDivisions(int stageId) async {
    try {
      print('🔄 Loading divisions for stage $stageId...');
      final divisionsList = await widget.loadDivisions(stageId);
      print('✅ Loaded ${divisionsList.length} divisions');
      if (mounted) {
        setState(() {
          divisions = divisionsList;
        });
      }
    } catch (e) {
      print('❌ Error loading divisions: $e');
      // Error loading divisions
      if (mounted) {
        setState(() {
          divisions = [];
        });
      }
    }
  }
}

// Selection bottom sheet widget
class _SelectionBottomSheet extends StatelessWidget {
  final String title;
  final List<String> items;
  final String selectedValue;
  final Function(String) onSelect;

  const _SelectionBottomSheet({
    required this.title,
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
                              title,
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
                    // Options (Scrollable)
                    Flexible(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: screenSize.height * 0.6,
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: items.length,
                          itemBuilder: (context, index) => FadeInUp(
                            duration: const Duration(milliseconds: 400),
                            delay: Duration(milliseconds: 100 * index),
                            child: _buildOption(
                              context: context,
                              item: items[index],
                              isLast: index == items.length - 1,
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

  Widget _buildOption({
    required BuildContext context,
    required String item,
    required bool isLast,
  }) {
    final isSelected = selectedValue == item;
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
