import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';

import '../../../core/constants/app_images.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_dialog.dart';
import '../../../core/widgets/app_loader.dart';
import '../controllers/home_controller.dart';
import '../../subjects/models/subject_model.dart';
import '../../subjects/views/subject_detail_view.dart';
import '../models/subjects_content_request_model.dart';

class FilterView extends StatefulWidget {
  const FilterView({super.key});

  @override
  State<FilterView> createState() => _FilterViewState();
}

class _FilterViewState extends State<FilterView> {
  final HomeController homeController = Get.find<HomeController>();
  final Set<int> selectedSubjectIds = {};
  String? selectedContentType;

  late final List<String> contentTypes;

  // Filter results
  bool isLoading = false;
  bool hasSearched = false;
  List<dynamic> filterResults = [];
  String? filterType;

  @override
  void initState() {
    super.initState();
    contentTypes = [
      'filter_type_videos'.tr,
      'filter_type_lessons'.tr,
      'filter_type_pdf'.tr,
    ];
  }

  bool isSubjectSelected(SubjectModel subject) {
    return selectedSubjectIds.contains(subject.id);
  }

  void toggleSubject(SubjectModel subject) {
    setState(() {
      if (selectedSubjectIds.contains(subject.id)) {
        selectedSubjectIds.remove(subject.id);
      } else {
        selectedSubjectIds.add(subject.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return AppScaffold(
      backgroundImage: AppImages.image2,
      showContentContainer: true,
      
      headerChildren: [
        SizedBox(height: screenSize.height * 0.12 + 10),
        // Top bar with back button - fixed position for all languages
        FadeInDown(
          duration: const Duration(milliseconds: 500),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenSize.width * 0.05,
            ),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 28),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: const Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: screenSize.height * 0.02),
      ],
      children: [
        // Subject section
        FadeInUp(
          duration: const Duration(milliseconds: 600),
          delay: const Duration(milliseconds: 300),
          child: Align(
            alignment: Get.locale?.languageCode == 'ar' ? Alignment.centerRight : Alignment.centerLeft,
            child: Text(
              'filter_subject_label'.tr,
              style: AppTextStyles.sectionTitle(context),
            ),
          ),
        ),
        SizedBox(height: screenSize.height * 0.02),
        // Subject chips (multi-select)
        FadeInUp(
          duration: const Duration(milliseconds: 700),
          delay: const Duration(milliseconds: 400),
          child: Obx(() {
            if (homeController.subjects.isEmpty) {
              return const Center(child: AppLoader(size: 50));
            }
            final isRtl = Get.locale?.languageCode == 'ar';
            return Wrap(
              spacing: 8,
              runSpacing: 12,
              alignment: isRtl ? WrapAlignment.end : WrapAlignment.start,
              children: homeController.subjects.map((subject) {
                final isSelected = isSubjectSelected(subject);
                return GestureDetector(
                  onTap: () => toggleSubject(subject),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.grey100,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Text(
                      subject.name,
                      style: AppTextStyles.bodyText(context).copyWith(
                        color: isSelected ? Colors.white : AppColors.textDark,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          }),
        ),
        SizedBox(height: screenSize.height * 0.04),
        // Divider
        FadeIn(
          duration: const Duration(milliseconds: 500),
          delay: const Duration(milliseconds: 500),
          child: Divider(
            color: AppColors.grey200,
            height: 1,
          ),
        ),
        SizedBox(height: screenSize.height * 0.04),
        // Content type section
        FadeInUp(
          duration: const Duration(milliseconds: 600),
          delay: const Duration(milliseconds: 600),
          child: Align(
            alignment: Get.locale?.languageCode == 'ar' ? Alignment.centerRight : Alignment.centerLeft,
            child: Text(
              'filter_type_label'.tr,
              style: AppTextStyles.sectionTitle(context),
            ),
          ),
        ),
        SizedBox(height: screenSize.height * 0.015),
        // Content type selector
        FadeInUp(
          duration: const Duration(milliseconds: 700),
          delay: const Duration(milliseconds: 700),
          child: GestureDetector(
            onTap: () => _showContentTypeBottomSheet(context),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: AppDimensions.spacing(context, 0.04),
                vertical: AppDimensions.spacing(context, 0.04),
              ),
              decoration: BoxDecoration(
                color: AppColors.grey100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.grey200,
                  width: 1,
                ),
              ),
              child: Directionality(
                textDirection: Get.locale?.languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        selectedContentType ?? 'filter_select_type'.tr,
                        style: selectedContentType != null
                            ? AppTextStyles.bodyText(context)
                            : AppTextStyles.inputHint(context),
                      ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_down,
                      color: AppColors.grey500,
                      size: 24,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: screenSize.height * 0.04),
        // Show results button
        FadeInUp(
          duration: const Duration(milliseconds: 800),
          delay: const Duration(milliseconds: 800),
          child: SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: () => _applyFilters(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                'filter_show_results_button'.tr,
                style: AppTextStyles.buttonText(context).copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: screenSize.height * 0.02),
        // Results section
        if (hasSearched) ...[
          Divider(color: AppColors.grey200, height: 1),
          SizedBox(height: screenSize.height * 0.02),
          // Results header
          Align(
            alignment: Get.locale?.languageCode == 'ar' ? Alignment.centerRight : Alignment.centerLeft,
            child: Text(
              'filter_results'.tr,
              style: AppTextStyles.sectionTitle(context),
            ),
          ),
          SizedBox(height: screenSize.height * 0.02),
          // Loading or results
          if (isLoading)
            const Center(child: AppLoader(size: 50))
          else if (filterResults.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  'filter_no_results'.tr,
                  style: AppTextStyles.bodyText(context).copyWith(
                    color: AppColors.grey500,
                  ),
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filterResults.length,
              itemBuilder: (context, index) {
                final item = filterResults[index];
                final isRtl = Get.locale?.languageCode == 'ar';
                return GestureDetector(
                  onTap: () => _onResultTap(item),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.grey100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Directionality(
                      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              item['name'] ?? '${'filter_item'.tr} ${index + 1}',
                              style: AppTextStyles.bodyText(context),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            filterType == 'video'
                                ? Icons.play_circle_outline
                                : filterType == 'lesson'
                                    ? Icons.book_outlined
                                    : Icons.picture_as_pdf_outlined,
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          SizedBox(height: screenSize.height * 0.02),
        ],
      ],
    );
  }

  void _showContentTypeBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: false,
      builder: (context) => _ContentTypeBottomSheet(
        items: contentTypes,
        selectedValue: selectedContentType,
        onSelect: (value) {
          setState(() {
            selectedContentType = value;
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  // Handle result item tap
  void _onResultTap(Map<String, dynamic> item) {
    final int subjectId = item['subject_id'] as int;

    // For videos and lessons, navigate to the subject detail page
    if (filterType == 'video' || filterType == 'lesson') {
      _navigateToSubject(subjectId);
    } else if (filterType == 'pdf') {
      // TODO: Handle PDF navigation if needed
      AppDialog.showInfo(
        message: 'filter_pdf_coming_soon'.tr,
      );
    }
  }

  // Navigate to a subject by its ID
  void _navigateToSubject(int subjectId) async {
    // Show loading dialog
    Get.dialog(
      PopScope(
        canPop: false,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const AppLoader(size: 60),
                const SizedBox(height: 16),
                Text(
                  'filter_loading_subject'.tr,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );

    try {
      // Find the subject from the home controller's subjects list
      final subject = homeController.subjects.firstWhereOrNull(
        (s) => s.id == subjectId,
      );

      // Close loading dialog
      Get.back();

      if (subject != null) {
        // Navigate to subject detail page
        Get.to(
          () => SubjectDetailView(subject: subject),
          transition: Transition.rightToLeft,
          duration: const Duration(milliseconds: 300),
        );
      } else {
        AppDialog.showError(message: 'filter_subject_not_available'.tr);
      }
    } catch (e) {
      // Close loading dialog
      Get.back();
      AppDialog.showError(message: 'filter_error_loading_content'.tr);
    }
  }

  // Apply filters and call API
  void _applyFilters(BuildContext context) async {
    // Map content type to API type
    String? apiType;
    if (selectedContentType == 'filter_type_videos'.tr) {
      apiType = 'video';
    } else if (selectedContentType == 'filter_type_lessons'.tr) {
      apiType = 'lesson';
    } else if (selectedContentType == 'filter_type_pdf'.tr) {
      apiType = 'pdf';
    }

    // Validate selections
    if (selectedSubjectIds.isEmpty || apiType == null) {
      AppDialog.showInfo(
        message: 'filter_please_select'.tr,
      );
      return;
    }

    // Call the filter API
    setState(() {
      isLoading = true;
      hasSearched = true;
    });

    try {
      final homeProvider = homeController.homeProvider;
      final response = await homeProvider.getSubjectsContent(
        request: SubjectsContentRequestModel(
          subjectIds: selectedSubjectIds.toList(),
          type: apiType,
        ),
      );

      setState(() {
        filterResults = response.items.map((item) => {
          'id': item.id,
          'name': item.name,
          'subject_id': item.subjectId,
        }).toList();
        filterType = apiType;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        filterResults = [];
      });
      AppDialog.showError(
        message: 'filter_search_error'.tr,
      );
    }
  }
}

// Content type bottom sheet widget
class _ContentTypeBottomSheet extends StatelessWidget {
  final List<String> items;
  final String? selectedValue;
  final Function(String) onSelect;

  const _ContentTypeBottomSheet({
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
                              'filter_select_type_title'.tr,
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
