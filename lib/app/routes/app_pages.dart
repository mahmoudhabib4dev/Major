import 'package:get/get.dart';

import '../modules/authentication/bindings/authentication_binding.dart';
import '../modules/authentication/views/authentication_view.dart';
import '../modules/authentication/views/subscription_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/bindings/notifications_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/home/views/notifications_view.dart';
import '../modules/parent/bindings/parent_binding.dart';
import '../modules/parent/views/parent_view.dart';
import '../modules/profile/bindings/profile_binding.dart';
import '../modules/profile/views/about_view.dart';
import '../modules/profile/views/edit_account_view.dart';
import '../modules/profile/views/edit_password_view.dart';
import '../modules/profile/views/help_view.dart';
import '../modules/profile/views/privacy_policy_view.dart';
import '../modules/profile/views/profile_view.dart';
import '../modules/profile/views/terms_view.dart';
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.AUTHENTICATION,
      page: () => const AuthenticationView(),
      binding: AuthenticationBinding(),
    ),
    GetPage(
      name: _Paths.SUBSCRIPTION,
      page: () => const SubscriptionView(),
      binding: AuthenticationBinding(),
    ),
    GetPage(
      name: _Paths.PROFILE,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: _Paths.SPLASH,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: _Paths.PARENT,
      page: () => const ParentView(),
      binding: ParentBinding(),
    ),
    GetPage(
      name: _Paths.NOTIFICATIONS,
      page: () => const NotificationsView(),
      binding: NotificationsBinding(),
    ),
    GetPage(
      name: _Paths.EDIT_ACCOUNT,
      page: () => const EditAccountView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: _Paths.EDIT_PASSWORD,
      page: () => const EditPasswordView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: _Paths.HELP,
      page: () => const HelpView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: _Paths.ABOUT,
      page: () => const AboutView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: _Paths.PRIVACY_POLICY,
      page: () => const PrivacyPolicyView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: _Paths.TERMS,
      page: () => const TermsView(),
      binding: ProfileBinding(),
    ),
  ];
}
