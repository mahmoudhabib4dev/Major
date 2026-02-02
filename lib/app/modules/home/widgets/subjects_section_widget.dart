import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/services/storage_service.dart';
import '../controllers/home_controller.dart';
import '../../parent/controllers/parent_controller.dart';
import '../views/filter_view.dart';
import '../../../core/widgets/app_loader.dart';
import 'subject_card_widget.dart';

class SubjectsSectionWidget extends StatefulWidget {
  const SubjectsSectionWidget({super.key});

  @override
  State<SubjectsSectionWidget> createState() => _SubjectsSectionWidgetState();
}

class _SubjectsSectionWidgetState extends State<SubjectsSectionWidget> {
  final FocusNode _searchFocusNode = FocusNode();
  final TextEditingController _searchController = TextEditingController();
  late final HomeController controller;
  late final ParentController parentController;

  bool get isGuest => !Get.find<StorageService>().isLoggedIn;

  @override
  void initState() {
    super.initState();
    controller = Get.find<HomeController>();
    parentController = Get.find<ParentController>();
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screenSize.width * 0.05,
        vertical: screenSize.height * 0.02,
      ),
      child: Column(
        children: [
          // Section header
          // First item = Subjects (RIGHT in RTL), Second item = View All (LEFT in RTL)
          FadeInUp(
            duration: const Duration(milliseconds: 600),
            delay: const Duration(milliseconds: 300),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Subjects title - appears on RIGHT in RTL (Arabic)
                Text('subjects'.tr, style: AppTextStyles.sectionTitle(context)),
                // View All - appears on LEFT in RTL (Arabic)
                InkWell(
                  onTap: controller.onViewAllSubjectsTap,
                  child: Text(
                    'subjects_view_all'.tr,
                    style: AppTextStyles.viewAllButton(context),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: screenSize.height * 0.02),

          // Search and Filter Section - hidden for guests
          if (!isGuest) ...[
            // First item = Search (RIGHT in RTL), Second item = Filter (LEFT in RTL)
            FadeInUp(
              duration: const Duration(milliseconds: 700),
              delay: const Duration(milliseconds: 350),
              child: Row(
                children: [
                  // Search Field - appears on RIGHT in RTL (Arabic)
                  Expanded(
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.grey100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.grey200, width: 1),
                      ),
                      child: TextField(
                        controller: _searchController,
                        focusNode: _searchFocusNode,
                        textAlign: TextAlign.start,
                        style: AppTextStyles.bodyText(context),
                        textInputAction: TextInputAction.search,
                        decoration: InputDecoration(
                          hintText: 'subjects_search_placeholder'.tr,
                          hintStyle: AppTextStyles.inputHint(context),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: AppDimensions.spacing(context, 0.04),
                            vertical: AppDimensions.spacing(context, 0.035),
                          ),
                          prefixIcon: Obx(
                            () =>
                                controller.isSearching.value
                                    ? const Padding(
                                      padding: EdgeInsets.all(14.0),
                                      child: AppLoader(size: 22),
                                    )
                                    : controller.searchQuery.value.isNotEmpty
                                    ? IconButton(
                                      icon: const Icon(
                                        Icons.clear,
                                        color: AppColors.grey400,
                                      ),
                                      onPressed: () {
                                        _searchController.clear();
                                        controller.clearSearch();
                                      },
                                    )
                                    : const SizedBox.shrink(),
                          ),
                          suffixIcon: Padding(
                            padding: const EdgeInsets.only(left: 12),
                            child: Icon(
                              Icons.search_rounded,
                              color: AppColors.grey400,
                              size: 22,
                            ),
                          ),
                        ),
                        onChanged: (query) {
                          if (query.trim().isNotEmpty) {
                            controller.searchLessons(query);
                          } else {
                            controller.clearSearch();
                          }
                        },
                        onSubmitted: (_) {
                          FocusScope.of(context).unfocus();
                        },
                      ),
                    ),
                  ),
                  SizedBox(width: screenSize.width * 0.03),
                  // Filter Button - appears on LEFT in RTL (Arabic)
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Get.to(
                            () => const FilterView(),
                            transition: Transition.downToUp,
                            duration: const Duration(milliseconds: 300),
                          );
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: const Icon(
                          Icons.tune_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Search results
            Obx(() {
              if (controller.searchResults.isEmpty &&
                  controller.searchQuery.value.isEmpty) {
                return const SizedBox.shrink();
              }
              return FadeInUp(
                duration: const Duration(milliseconds: 400),
                child: Container(
                  margin: EdgeInsets.only(top: screenSize.height * 0.02),
                  constraints: BoxConstraints(
                    maxHeight: screenSize.height * 0.4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.grey200),
                  ),
                  child:
                      controller.searchResults.isEmpty
                          ? Padding(
                            padding: const EdgeInsets.all(20),
                            child: Text(
                              'home_no_search_results'.tr,
                              style: AppTextStyles.bodyText(
                                context,
                              ).copyWith(color: AppColors.grey500),
                              textAlign: TextAlign.center,
                            ),
                          )
                          : ListView.separated(
                            shrinkWrap: true,
                            padding: const EdgeInsets.all(8),
                            itemCount: controller.searchResults.length,
                            separatorBuilder:
                                (context, index) => const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final lesson = controller.searchResults[index];
                              return ListTile(
                                title: Text(
                                  lesson.name,
                                  style: AppTextStyles.bodyText(context),
                                  textAlign: TextAlign.right,
                                ),
                                leading: const Icon(
                                  Icons.play_circle_outline,
                                  color: AppColors.primary,
                                ),
                                onTap: () {
                                  _searchController.clear();
                                  controller.onSearchResultTap(lesson);
                                },
                              );
                            },
                          ),
                ),
              );
            }),
          ],

          // Subjects grid
          FadeInUp(
            duration: const Duration(milliseconds: 800),
            delay: const Duration(milliseconds: 400),
            child: Obx(() {
              // Loading state
              if (controller.isLoading.value) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 50),
                    child: AppLoader(size: 60),
                  ),
                );
              }

              // Error state - other errors
              if (controller.errorMessage.value.isNotEmpty) {
                return Container(
                  margin: const EdgeInsets.only(top: 20),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.grey100,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.grey300, width: 1),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        size: 48,
                        color: AppColors.grey500,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        controller.errorMessage.value,
                        style: AppTextStyles.bodyText(
                          context,
                        ).copyWith(color: AppColors.grey600),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      TextButton.icon(
                        onPressed: () => controller.loadSubjects(),
                        icon: const Icon(Icons.refresh_rounded),
                        label: Text('retry'.tr),
                      ),
                    ],
                  ),
                );
              }

              // Success state - show subjects
              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.only(top: 15),
                crossAxisCount: 3,
                mainAxisSpacing: 16,
                crossAxisSpacing: 12,
                childAspectRatio: 0.77,
                children:
                    controller.subjects
                        .map((subject) => SubjectCardWidget(subject: subject))
                        .toList(),
              );
            }),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}
