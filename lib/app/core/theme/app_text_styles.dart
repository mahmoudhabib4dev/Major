import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  // Primary color
  static const Color primaryColor = Color(0xFF000D47);

  // Get responsive font size based on screen width
  static double getResponsiveFontSize(BuildContext context, double baseFontSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    // Base width is considered as 375 (standard mobile width)
    return (screenWidth / 375) * baseFontSize;
  }

  // Onboarding title style
  // Font: Tajawal, Weight: 700 (Bold), Size: 20px, Line height: 36px, Color: #000D47
  static TextStyle onboardingTitle(BuildContext context) {
    return TextStyle(
      fontFamily: 'Tajawal',
      fontSize: getResponsiveFontSize(context, 20),
      fontWeight: FontWeight.w700,
      height: 36 / 20, // Line height / font size
      color: primaryColor,
    );
  }

  // Onboarding description style
  static TextStyle onboardingDescription(BuildContext context) {
    return TextStyle(
      fontFamily: 'Tajawal',
      fontSize: getResponsiveFontSize(context, 14),
      fontWeight: FontWeight.w400,
      height: 1.6,
      color: Colors.grey[700],
    );
  }

  // Button text style
  static TextStyle buttonText(BuildContext context) {
    return TextStyle(
      fontFamily: 'Tajawal',
      fontSize: getResponsiveFontSize(context, 16),
      fontWeight: FontWeight.w600,
    );
  }

  // Page title style (for app pages)
  static TextStyle pageTitle(BuildContext context) {
    return TextStyle(
      fontFamily: 'Tajawal',
      fontSize: getResponsiveFontSize(context, 24),
      fontWeight: FontWeight.w700,
      color: primaryColor,
    );
  }

  // Login title style - "تسجيل الدخول"
  // Font: Tajawal, Weight: 700, Size: 18px, Color: #1A1A1E
  static TextStyle loginTitle(BuildContext context) {
    return TextStyle(
      fontFamily: 'Tajawal',
      fontSize: getResponsiveFontSize(context, 18),
      fontWeight: FontWeight.w700,
      height: 1.0,
      color: const Color(0xFF1A1A1E),
    );
  }

  // Login subtitle style - "من فضلك ادخل بيانات حسابك للاستمرار"
  // Font: Tajawal, Weight: 400, Size: 14px, Color: #656B78
  static TextStyle loginSubtitle(BuildContext context) {
    return TextStyle(
      fontFamily: 'Tajawal',
      fontSize: getResponsiveFontSize(context, 14),
      fontWeight: FontWeight.w400,
      height: 1.0,
      color: const Color(0xFF656B78),
    );
  }

  // Footer normal text - "جديد لدينا ؟"
  // Font: Tajawal, Weight: 400, Size: 16px, Color: #999999
  static TextStyle footerNormalText(BuildContext context) {
    return TextStyle(
      fontFamily: 'Tajawal',
      fontSize: getResponsiveFontSize(context, 16),
      fontWeight: FontWeight.w400,
      height: 1.0,
      color: const Color(0xFF999999),
    );
  }

  // Footer link text - "إنشاء حساب"
  // Font: Tajawal, Weight: 500, Size: 16px, Color: #000D47
  static TextStyle footerLinkText(BuildContext context) {
    return TextStyle(
      fontFamily: 'Tajawal',
      fontSize: getResponsiveFontSize(context, 16),
      fontWeight: FontWeight.w500,
      height: 1.0,
      color: primaryColor,
    );
  }

  // Input field label style - "رقم الجوال"
  // Font: Tajawal, Weight: 500, Size: 14px, Line height: 24px, Color: #10162E
  static TextStyle inputLabel(BuildContext context) {
    return TextStyle(
      fontFamily: 'Tajawal',
      fontSize: getResponsiveFontSize(context, 14),
      fontWeight: FontWeight.w500,
      height: 24 / 14,
      color: const Color(0xFF10162E),
    );
  }

  // Input field hint/placeholder style
  // Font: Tajawal, Weight: 400, Size: 14px, Color: #333333
  static TextStyle inputHint(BuildContext context) {
    return TextStyle(
      fontFamily: 'Tajawal',
      fontSize: getResponsiveFontSize(context, 14),
      fontWeight: FontWeight.w400,
      height: 1.0,
      color: const Color(0xFF333333),
    );
  }

  // Forgot password link style - "نسيت كلمة المرور ؟"
  // Font: Tajawal, Weight: 500, Size: 12px, Color: #FF914D
  static TextStyle forgotPasswordLink(BuildContext context) {
    return TextStyle(
      fontFamily: 'Tajawal',
      fontSize: getResponsiveFontSize(context, 12),
      fontWeight: FontWeight.w500,
      height: 1.0,
      color: const Color(0xFFFF914D),
    );
  }

  // Subtitle style
  static TextStyle subtitle(BuildContext context) {
    return TextStyle(
      fontFamily: 'Tajawal',
      fontSize: getResponsiveFontSize(context, 16),
      fontWeight: FontWeight.w500,
      color: Colors.grey[600],
    );
  }

  // Body text style
  static TextStyle bodyText(BuildContext context) {
    return TextStyle(
      fontFamily: 'Tajawal',
      fontSize: getResponsiveFontSize(context, 14),
      fontWeight: FontWeight.w400,
      color: Colors.grey[800],
      height: 1.5,
    );
  }

  // Small text style
  static TextStyle smallText(BuildContext context) {
    return TextStyle(
      fontFamily: 'Tajawal',
      fontSize: getResponsiveFontSize(context, 12),
      fontWeight: FontWeight.w400,
      color: Colors.grey[600],
    );
  }

  // Home page title style - "مرحبا بك .. !"
  // Font: Tajawal, Weight: 500 (Medium), Size: 14px, Line height: 150%, Letter spacing: 4%, Color: #FDC919
  static TextStyle homeTitle(BuildContext context) {
    return TextStyle(
      fontFamily: 'Tajawal',
      fontSize: getResponsiveFontSize(context, 14),
      fontWeight: FontWeight.w500,
      height: 1.5, // 150% line height
      letterSpacing: 0.04 * 14, // 4% of font size
      color: AppColors.golden,
    );
  }

  // Home page subtitle style - "صلاح سالم"
  // Font: Tajawal, Weight: 500 (Medium), Size: 20px, Line height: 150%, Letter spacing: 0%, Color: White
  static TextStyle homeSubtitle(BuildContext context) {
    return TextStyle(
      fontFamily: 'Tajawal',
      fontSize: getResponsiveFontSize(context, 20),
      fontWeight: FontWeight.w500,
      height: 1.5, // 150% line height
      letterSpacing: 0, // 0% letter spacing
      color: AppColors.white,
    );
  }

  // Section title style - "المواد"
  // Font: Tajawal, Weight: 500 (Medium), Size: 16px, Color: #0C092A
  static TextStyle sectionTitle(BuildContext context) {
    return TextStyle(
      fontFamily: 'Tajawal',
      fontSize: getResponsiveFontSize(context, 16),
      fontWeight: FontWeight.w500,
      color: AppColors.textNavy,
    );
  }

  // View all button style - "عرض الكل"
  // Font: Tajawal, Weight: 500 (Medium), Size: 14px, Color: #707070
  static TextStyle viewAllButton(BuildContext context) {
    return TextStyle(
      fontFamily: 'Tajawal',
      fontSize: getResponsiveFontSize(context, 14),
      fontWeight: FontWeight.w500,
      color: AppColors.textMediumGrey,
    );
  }

  // Subject card title style - "اللغة الانجليزية"
  // Font: Tajawal, Weight: 500 (Medium), Size: 12px, Color: #707070
  static TextStyle subjectCardTitle(BuildContext context) {
    return TextStyle(
      fontFamily: 'Tajawal',
      fontSize: getResponsiveFontSize(context, 12),
      fontWeight: FontWeight.w500,
      color: AppColors.textMediumGrey,
    );
  }

  // Notification page title style - "الإشعارات"
  // Font: Tajawal, Weight: 500 (Medium), Size: 18px, Line height: 140%, Color: #FFFFFF
  static TextStyle notificationPageTitle(BuildContext context) {
    return TextStyle(
      fontFamily: 'Tajawal',
      fontSize: getResponsiveFontSize(context, 18),
      fontWeight: FontWeight.w500,
      height: 1.4, // 140% line height
      letterSpacing: 0,
      color: AppColors.white,
    );
  }

  // Notification card text style
  // Font: Tajawal, Weight: 400 (Regular), Size: 14px, Line height: 140%, Color: gray/800
  static TextStyle notificationCardText(BuildContext context) {
    return TextStyle(
      fontFamily: 'Tajawal',
      fontSize: getResponsiveFontSize(context, 14),
      fontWeight: FontWeight.w400,
      height: 1.4, // 140% line height
      letterSpacing: 0,
      color: AppColors.grey800,
    );
  }

  // Notification time style
  // Font: Tajawal, Weight: 400 (Regular), Size: 12px, Color: #707070
  static TextStyle notificationTime(BuildContext context) {
    return TextStyle(
      fontFamily: 'Tajawal',
      fontSize: getResponsiveFontSize(context, 12),
      fontWeight: FontWeight.w400,
      color: AppColors.textMediumGrey,
    );
  }

  // Subject detail page title - "التشريع الإسلامي"
  // Font: Tajawal, Weight: 500 (Medium), Size: 18px, Line height: 150%, Color: White
  static TextStyle subjectDetailTitle(BuildContext context) {
    return TextStyle(
      fontFamily: 'Tajawal',
      fontSize: getResponsiveFontSize(context, 18),
      fontWeight: FontWeight.w500,
      height: 1.5, // 150% line height
      letterSpacing: 0,
      color: AppColors.white,
    );
  }

  // Test section label - "اختبار المادة"
  // Font: Tajawal, Weight: 400 (Regular), Size: 14px, Line height: 135%, Color: #000D47
  static TextStyle testSectionLabel(BuildContext context) {
    return TextStyle(
      fontFamily: 'Tajawal',
      fontSize: getResponsiveFontSize(context, 14),
      fontWeight: FontWeight.w400,
      height: 1.35, // 135% line height
      letterSpacing: 0,
      color: primaryColor,
    );
  }

  // Test yourself label - "اختبر نفسك"
  // Font: Tajawal, Weight: 500 (Medium), Size: 17px, Line height: 140%, Color: #000D47
  static TextStyle testYourselfLabel(BuildContext context) {
    return TextStyle(
      fontFamily: 'Tajawal',
      fontSize: getResponsiveFontSize(context, 17),
      fontWeight: FontWeight.w500,
      height: 1.4, // 140% line height
      letterSpacing: 0,
      color: primaryColor,
    );
  }

  // Section card title - "المحاور التعليمية"
  // Font: Tajawal, Weight: 500 (Medium), Size: 16px, Line height: 150%, Color: Black
  static TextStyle sectionCardTitle(BuildContext context) {
    return TextStyle(
      fontFamily: 'Tajawal',
      fontSize: getResponsiveFontSize(context, 16),
      fontWeight: FontWeight.w500,
      height: 1.5, // 150% line height
      letterSpacing: 0,
      color: Colors.black,
    );
  }

  // Statistics label - "عدد الطلاب"
  // Font: Tajawal, Weight: 500 (Medium), Size: 12px, Line height: 150%, Letter spacing: 4%, Color: #000D47
  static TextStyle statisticsLabel(BuildContext context) {
    return TextStyle(
      fontFamily: 'Tajawal',
      fontSize: getResponsiveFontSize(context, 12),
      fontWeight: FontWeight.w500,
      height: 1.5, // 150% line height
      letterSpacing: 0.04 * 12, // 4% of font size
      color: primaryColor,
    );
  }

  // Statistics value - "30 طالب"
  // Font: Tajawal, Weight: 500 (Medium), Size: 14px, Line height: 150%, Letter spacing: 0%, Color: #000D47
  static TextStyle statisticsValue(BuildContext context) {
    return TextStyle(
      fontFamily: 'Tajawal',
      fontSize: getResponsiveFontSize(context, 14),
      fontWeight: FontWeight.w500,
      height: 1.5, // 150% line height
      letterSpacing: 0,
      color: primaryColor,
    );
  }

  // Lesson title - "الدرس الأول"
  // Font: Tajawal, Weight: 500 (Medium), Size: 16px, Line height: 140%, Letter spacing: 0%, Color: #171717
  static TextStyle lessonTitle(BuildContext context) {
    return TextStyle(
      fontFamily: 'Tajawal',
      fontSize: getResponsiveFontSize(context, 16),
      fontWeight: FontWeight.w500,
      height: 1.4, // 140% line height
      letterSpacing: 0,
      color: const Color(0xFF171717),
    );
  }

  // Lesson subtitle - "اسم الدرس الأول"
  // Font: Tajawal, Weight: 400 (Regular), Size: 14px, Line height: 140%, Letter spacing: 0%, Color: #171717
  static TextStyle lessonSubtitle(BuildContext context) {
    return TextStyle(
      fontFamily: 'Tajawal',
      fontSize: getResponsiveFontSize(context, 14),
      fontWeight: FontWeight.w400,
      height: 1.4, // 140% line height
      letterSpacing: 0,
      color: const Color(0xFF171717),
    );
  }

  // Lesson button active - "اختبار الدرس" (active state)
  // Font: Tajawal, Weight: 500 (Medium), Size: 10px, Line height: Auto, Letter spacing: 0%, Color: #000D47
  static TextStyle lessonButtonActive(BuildContext context) {
    return TextStyle(
      fontFamily: 'Tajawal',
      fontSize: getResponsiveFontSize(context, 10),
      fontWeight: FontWeight.w500,
      letterSpacing: 0,
      color: primaryColor,
    );
  }

  // Lesson button disabled - "اختبار الدرس" (disabled state)
  // Font: Tajawal, Weight: 500 (Medium), Size: 10px, Line height: Auto, Letter spacing: 0%, Color: #858494
  static TextStyle lessonButtonDisabled(BuildContext context) {
    return TextStyle(
      fontFamily: 'Tajawal',
      fontSize: getResponsiveFontSize(context, 10),
      fontWeight: FontWeight.w500,
      letterSpacing: 0,
      color: const Color(0xFF858494),
    );
  }

  // Profile page user name - "صلاح سالم"
  // Font: Tajawal, Weight: 500 (Medium), Size: 18px, Line height: 150%, Color: White
  static TextStyle profileUserName(BuildContext context) {
    return TextStyle(
      fontFamily: 'Tajawal',
      fontSize: getResponsiveFontSize(context, 18),
      fontWeight: FontWeight.w500,
      height: 1.5,
      letterSpacing: 0,
      color: AppColors.white,
    );
  }

  // Profile menu item text - "تعديل الحساب"
  // Font: Tajawal, Weight: 400 (Regular), Size: 15px, Line height: 23px, Color: #000000
  static TextStyle profileMenuItem(BuildContext context) {
    return TextStyle(
      fontFamily: 'Tajawal',
      fontSize: getResponsiveFontSize(context, 15),
      fontWeight: FontWeight.w400,
      height: 23 / 15,
      letterSpacing: 0,
      color: const Color(0xFF000000),
    );
  }

  // Profile menu item text danger - "حذف الحساب"
  // Font: Tajawal, Weight: 500 (Medium), Size: 14px, Line height: 140%, Color: #F44336
  static TextStyle profileMenuItemDanger(BuildContext context) {
    return TextStyle(
      fontFamily: 'Tajawal',
      fontSize: getResponsiveFontSize(context, 14),
      fontWeight: FontWeight.w500,
      height: 1.4,
      letterSpacing: 0,
      color: AppColors.error,
    );
  }
}
