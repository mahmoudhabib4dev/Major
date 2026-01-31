import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_images.dart';
import '../controllers/profile_controller.dart';
import 'profile_menu_item_widget.dart';

class ProfileMenuListWidget extends GetView<ProfileController> {
  const ProfileMenuListWidget({super.key});

  List<Map<String, dynamic>> get _menuItems => [
        {
          'titleKey': 'hide_in_challenges',
          'iconPath': AppImages.icon32,
          'iconBackgroundColor': const Color(0xFF32BB71),
          'type': ProfileMenuItemType.toggle,
          'onTap': null,
          'isDanger': false,
        },
        {
          'titleKey': 'edit_account',
          'iconPath': AppImages.icon33,
          'iconBackgroundColor': const Color(0xFF000D47),
          'type': ProfileMenuItemType.navigation,
          'onTap': controller.navigateToEditAccount,
          'isDanger': false,
        },
        {
          'titleKey': 'edit_password',
          'iconPath': AppImages.icon34,
          'iconBackgroundColor': const Color(0xFFFFD964),
          'type': ProfileMenuItemType.navigation,
          'onTap': controller.navigateToEditPassword,
          'isDanger': false,
        },
        {
          'titleKey': 'subscription',
          'iconPath': AppImages.icon37,
          'iconBackgroundColor': const Color(0xFF32BB71),
          'type': ProfileMenuItemType.navigation,
          'onTap': controller.navigateToSubscription,
          'isDanger': false,
        },
        {
          'titleKey': 'language',
          'iconPath': AppImages.icon35,
          'iconBackgroundColor': const Color(0xFF000D47),
          'type': ProfileMenuItemType.navigation,
          'onTap': controller.navigateToLanguage,
          'isDanger': false,
        },
        {
          'titleKey': 'help',
          'iconPath': AppImages.icon36,
          'iconBackgroundColor': const Color(0xFFEF7B5F),
          'type': ProfileMenuItemType.navigation,
          'onTap': controller.navigateToHelp,
          'isDanger': false,
        },
        {
          'titleKey': 'about',
          'iconPath': AppImages.icon37,
          'iconBackgroundColor': const Color(0xFF000D47),
          'type': ProfileMenuItemType.navigation,
          'onTap': controller.navigateToAbout,
          'isDanger': false,
        },
        {
          'titleKey': 'rate_app',
          'iconPath': AppImages.icon37,
          'iconBackgroundColor': const Color(0xFF000D47),
          'type': ProfileMenuItemType.navigation,
          'onTap': controller.rateApp,
          'isDanger': false,
        },
        {
          'titleKey': 'share_app',
          'iconPath': AppImages.icon37,
          'iconBackgroundColor': const Color(0xFF000D47),
          'type': ProfileMenuItemType.navigation,
          'onTap': controller.shareApp,
          'isDanger': false,
        },
        {
          'titleKey': 'logout',
          'iconPath': AppImages.icon38,
          'iconBackgroundColor': const Color(0xFF6B81DB),
          'type': ProfileMenuItemType.navigation,
          'onTap': controller.logout,
          'isDanger': false,
        },
        {
          'titleKey': 'delete_account',
          'iconPath': AppImages.icon39,
          'iconBackgroundColor': const Color(0xFFEF7B5F),
          'type': ProfileMenuItemType.navigation,
          'onTap': controller.deleteAccount,
          'isDanger': true,
        },
      ];

  @override
  Widget build(BuildContext context) {
    return FadeInUp(
      duration: const Duration(milliseconds: 500),
      child: Column(
        children: [
          ..._menuItems.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return ProfileMenuItemWidget(
              title: (item['titleKey'] as String).tr,
              iconPath: item['iconPath'] as String,
              iconBackgroundColor: item['iconBackgroundColor'] as Color,
              type: item['type'] as ProfileMenuItemType,
              onTap: item['onTap'] as VoidCallback?,
              isDanger: item['isDanger'] as bool,
              animationDelay: index * 50,
            );
          }),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}

/// Sliver version of ProfileMenuListWidget for better scroll performance
class ProfileMenuSliverList extends GetView<ProfileController> {
  const ProfileMenuSliverList({super.key});

  List<Map<String, dynamic>> _getMenuItems() {
    // If guest user, show only basic items + login button
    if (controller.isGuest) {
      return [
        {
          'titleKey': 'login',
          'iconPath': AppImages.icon38,
          'iconBackgroundColor': const Color(0xFF32BB71),
          'type': ProfileMenuItemType.navigation,
          'onTap': controller.navigateToLogin,
          'isDanger': false,
        },
        {
          'titleKey': 'language',
          'iconPath': AppImages.icon35,
          'iconBackgroundColor': const Color(0xFF000D47),
          'type': ProfileMenuItemType.navigation,
          'onTap': controller.navigateToLanguage,
          'isDanger': false,
        },
        {
          'titleKey': 'about',
          'iconPath': AppImages.icon37,
          'iconBackgroundColor': const Color(0xFF000D47),
          'type': ProfileMenuItemType.navigation,
          'onTap': controller.navigateToAbout,
          'isDanger': false,
        },
        {
          'titleKey': 'share_app',
          'iconPath': AppImages.icon37,
          'iconBackgroundColor': const Color(0xFF000D47),
          'type': ProfileMenuItemType.navigation,
          'onTap': controller.shareApp,
          'isDanger': false,
        },
      ];
    }

    // For logged-in users, show menu items based on subscription status
    final items = [
      {
        'titleKey': 'hide_in_challenges',
        'iconPath': AppImages.icon32,
        'iconBackgroundColor': const Color(0xFF32BB71),
        'type': ProfileMenuItemType.toggle,
        'onTap': null,
        'isDanger': false,
      },
      {
        'titleKey': 'edit_account',
        'iconPath': AppImages.icon33,
        'iconBackgroundColor': const Color(0xFF000D47),
        'type': ProfileMenuItemType.navigation,
        'onTap': controller.navigateToEditAccount,
        'isDanger': false,
      },
      {
        'titleKey': 'edit_password',
        'iconPath': AppImages.icon34,
        'iconBackgroundColor': const Color(0xFFFFD964),
        'type': ProfileMenuItemType.navigation,
        'onTap': controller.navigateToEditPassword,
        'isDanger': false,
      },
      {
        'titleKey': 'subscription',
        'iconPath': AppImages.icon37,
        'iconBackgroundColor': const Color(0xFF32BB71),
        'type': ProfileMenuItemType.navigation,
        'onTap': controller.navigateToSubscription,
        'isDanger': false,
      },
      {
        'titleKey': 'language',
        'iconPath': AppImages.icon35,
        'iconBackgroundColor': const Color(0xFF000D47),
        'type': ProfileMenuItemType.navigation,
        'onTap': controller.navigateToLanguage,
        'isDanger': false,
      },
      {
        'titleKey': 'help',
        'iconPath': AppImages.icon36,
        'iconBackgroundColor': const Color(0xFFEF7B5F),
        'type': ProfileMenuItemType.navigation,
        'onTap': controller.navigateToHelp,
        'isDanger': false,
      },
      {
        'titleKey': 'about',
        'iconPath': AppImages.icon37,
        'iconBackgroundColor': const Color(0xFF000D47),
        'type': ProfileMenuItemType.navigation,
        'onTap': controller.navigateToAbout,
        'isDanger': false,
      },
      {
        'titleKey': 'share_app',
        'iconPath': AppImages.icon37,
        'iconBackgroundColor': const Color(0xFF000D47),
        'type': ProfileMenuItemType.navigation,
        'onTap': controller.shareApp,
        'isDanger': false,
      },
      {
        'titleKey': 'logout',
        'iconPath': AppImages.icon38,
        'iconBackgroundColor': const Color(0xFF6B81DB),
        'type': ProfileMenuItemType.navigation,
        'onTap': controller.logout,
        'isDanger': false,
      },
      {
        'titleKey': 'delete_account',
        'iconPath': AppImages.icon39,
        'iconBackgroundColor': const Color(0xFFEF7B5F),
        'type': ProfileMenuItemType.navigation,
        'onTap': controller.deleteAccount,
        'isDanger': true,
      },
    ];

    // Only add rate_app for users with active subscription
    if (controller.hasActiveSubscription) {
      items.insert(7, {
        'titleKey': 'rate_app',
        'iconPath': AppImages.icon37,
        'iconBackgroundColor': const Color(0xFF000D47),
        'type': ProfileMenuItemType.navigation,
        'onTap': controller.rateApp,
        'isDanger': false,
      });
    }

    return items;
  }

  @override
  Widget build(BuildContext context) {
    final menuItems = _getMenuItems();
    final Size screenSize = MediaQuery.of(context).size;

    return SliverPadding(
      padding: EdgeInsets.all(screenSize.width * 0.05),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index == menuItems.length) {
              // Bottom spacing
              return const SizedBox(height: 100);
            }
            final item = menuItems[index];
            return ProfileMenuItemWidget(
              title: (item['titleKey'] as String).tr,
              iconPath: item['iconPath'] as String,
              iconBackgroundColor: item['iconBackgroundColor'] as Color,
              type: item['type'] as ProfileMenuItemType,
              onTap: item['onTap'] as VoidCallback?,
              isDanger: item['isDanger'] as bool,
              animationDelay: index * 50,
            );
          },
          childCount: menuItems.length + 1, // +1 for bottom spacing
        ),
      ),
    );
  }
}
