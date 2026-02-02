import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_images.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_loader.dart';
import '../controllers/profile_controller.dart';
import '../widgets/profile_page_header_widget.dart';

class LeaderboardView extends GetView<ProfileController> {
  const LeaderboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    // Load leaderboard when page is built
    controller.loadLeaderboard();

    return AppScaffold(
      backgroundImage: AppImages.image3,
      showContentContainer: true,
      onRefresh: () => controller.loadLeaderboard(),
      headerChildren: [
        SafeArea(
          child: ProfilePageHeaderWidget(
            title: 'لوحة المتصدرين',
            onBack: () => Get.back(),
          ),
        ),
      ],
      sliverChildren: [
        SliverPadding(
          padding: EdgeInsets.all(screenSize.width * 0.05),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              SizedBox(height: screenSize.height * 0.02),

              // Week Info Card
              Obx(() {
                final leaderboard = controller.leaderboard.value;
                if (leaderboard == null) {
                  return const SizedBox.shrink();
                }

                return FadeInDown(
                  duration: const Duration(milliseconds: 500),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primary, const Color(0xFF000933)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildInfoItem(
                          context,
                          icon: Icons.calendar_today,
                          label: 'الأسبوع',
                          value: leaderboard.weekKey,
                        ),
                        _buildInfoItem(
                          context,
                          icon: Icons.people,
                          label: 'المشاركون',
                          value: '${leaderboard.participants}',
                        ),
                      ],
                    ),
                  ),
                );
              }),

              SizedBox(height: screenSize.height * 0.03),

              // Current Student Rank Card (if not hidden)
              Obx(() {
                final student = controller.leaderboard.value?.student;
                if (student == null || student.hidden) {
                  return const SizedBox.shrink();
                }

                return FadeInUp(
                  duration: const Duration(milliseconds: 500),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.golden,
                          AppColors.golden.withValues(alpha: 0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.golden.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '#${student.rank}',
                              style: const TextStyle(
                                fontFamily: 'Tajawal',
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.golden,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'ترتيبك',
                                style: TextStyle(
                                  fontFamily: 'Tajawal',
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${student.score} نقطة',
                                    style: const TextStyle(
                                      fontFamily: 'Tajawal',
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),

              SizedBox(height: screenSize.height * 0.03),

              // Top Players Title
              FadeInUp(
                duration: const Duration(milliseconds: 500),
                delay: const Duration(milliseconds: 100),
                child: Row(
                  children: [
                    const Icon(
                      Icons.emoji_events,
                      color: AppColors.golden,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'أفضل المتسابقين',
                      style: AppTextStyles.sectionTitle(context),
                    ),
                  ],
                ),
              ),

              SizedBox(height: screenSize.height * 0.02),

              // Top Players List
              Obx(() {
                if (controller.isLoadingLeaderboard.value) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: AppLoader(size: 60),
                    ),
                  );
                }

                final topPlayers = controller.leaderboard.value?.top ?? [];
                if (topPlayers.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Text(
                        'لا يوجد متسابقون حاليًا',
                        style: AppTextStyles.bodyText(context).copyWith(
                          color: AppColors.grey500,
                        ),
                      ),
                    ),
                  );
                }

                return Column(
                  children: List.generate(
                    topPlayers.length,
                    (index) {
                      final player = topPlayers[index];
                      return FadeInUp(
                        duration: const Duration(milliseconds: 400),
                        delay: Duration(milliseconds: 150 + (index * 100)),
                        child: _buildLeaderboardItem(
                          context,
                          player,
                          index,
                        ),
                      );
                    },
                  ),
                );
              }),

              SizedBox(height: screenSize.height * 0.02),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 12,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardItem(
    BuildContext context,
    dynamic player,
    int index,
  ) {
    final isTop3 = index < 3;
    final rankColors = [
      AppColors.golden,
      const Color(0xFFC0C0C0), // Silver
      const Color(0xFFCD7F32), // Bronze
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isTop3 ? rankColors[index] : AppColors.grey200,
          width: isTop3 ? 2 : 1,
        ),
        boxShadow: [
          if (isTop3)
            BoxShadow(
              color: rankColors[index].withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Row(
        children: [
          // Rank Badge
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isTop3 ? rankColors[index] : AppColors.grey300,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '#${player.rank}',
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isTop3 ? Colors.white : AppColors.grey700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Profile Picture
          ClipOval(
            child: player.pictureUrl != null
                ? CachedNetworkImage(
                    imageUrl: player.pictureUrl!,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: AppColors.grey200,
                      child: const Center(
                        child: AppLoader(size: 30),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: AppColors.grey200,
                      child: const Icon(
                        Icons.person,
                        color: AppColors.grey500,
                        size: 30,
                      ),
                    ),
                  )
                : Container(
                    width: 50,
                    height: 50,
                    color: AppColors.grey200,
                    child: const Icon(
                      Icons.person,
                      color: AppColors.grey500,
                      size: 30,
                    ),
                  ),
          ),
          const SizedBox(width: 12),

          // Name and Score
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player.name,
                  style: AppTextStyles.bodyText(context).copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.star,
                      color: isTop3 ? rankColors[index] : AppColors.grey500,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${player.score} نقطة',
                      style: AppTextStyles.smallText(context).copyWith(
                        color: AppColors.grey600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Trophy Icon for top 3
          if (isTop3)
            Icon(
              Icons.emoji_events,
              color: rankColors[index],
              size: 28,
            ),
        ],
      ),
    );
  }
}
