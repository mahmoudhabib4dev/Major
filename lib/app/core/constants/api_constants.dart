class ApiConstants {
  // Base URL
  static const String baseUrl = 'https://api.majorclass.net/api';

  // Storage URL (for PDFs, images, etc.)
  static const String storageUrl = 'https://api.majorclass.net/storage';

  // Auth Endpoints
  static const String login = '$baseUrl/auth/login';
  static const String logout = '$baseUrl/auth/logout';
  static const String register = '$baseUrl/auth/register';
  static const String deleteAccount = '$baseUrl/auth/delete-account';
  static const String stages = '$baseUrl/auth/stages';
  static String divisions(int stageId) => '$baseUrl/auth/divisions/$stageId';

  // New auth endpoints
  static const String verifyOtp = '$baseUrl/auth/verify-otp';
  static const String setPassword = '$baseUrl/auth/set-password';
  static const String resetPassword = '$baseUrl/auth/reset-password';
  static const String resendOtp = '$baseUrl/auth/resend-otp';
  static const String verifyOtpForgetPassword = '$baseUrl/auth/verify-otp-forget-password';
  static const String forgetPassword = '$baseUrl/auth/forget-password';

  // Old password endpoints (for backward compatibility - deprecated)
  static const String forgotPassword = '$baseUrl/password/forgot';

  // Info Endpoints
  static const String about = '$baseUrl/about';
  static const String terms = '$baseUrl/terms';
  static const String policies = '$baseUrl/policies';
  static const String socialLinks = '$baseUrl/social-links';

  // Home Endpoints
  static String homeOffers(int divisionId) => '$baseUrl/home/offers/$divisionId';
  static const String homeSubjectsContent = '$baseUrl/home/subjects/content';
  static String homeLessonsSearch(String query) => '$baseUrl/home/lessons-search?q=$query';

  // Profile Endpoints
  static const String profile = '$baseUrl/profile';
  static const String updatePassword = '$baseUrl/profile/update-password';
  static const String profileSubscription = '$baseUrl/profile/subscription';
  static const String appReview = '$baseUrl/app-review';
  static const String leaderboard = '$baseUrl/profile/leaderboard';
  static const String leaderboardPrivacy = '$baseUrl/profile/leaderboard-privacy';
  static const String leaderboardPrivacyToggle = '$baseUrl/profile/leaderboard-privacy/toggle';
  static const String supportCenter = '$baseUrl/support-center';
  static const String studentComplaints = '$baseUrl/student-complaints';

  // Favorites Endpoints
  static const String favorites = '$baseUrl/favorites';
  static const String toggleFavorite = '$baseUrl/favorites/toggle';

  // Subscription Endpoints
  static const String subscriptionPlans = '$baseUrl/subscription/plans';
  static const String bankAccounts = '$baseUrl/subscription/bank-accounts';
  static const String applyCoupon = '$baseUrl/subscription/apply-coupon';
  static const String subscriptionStore = '$baseUrl/subscription/store';
  static const String subscriptionRefresh = '$baseUrl/subscription/refresh';

  // Subjects Endpoints
  static String subjectsByDivision(int divisionId) => '$baseUrl/subjects/by-division/$divisionId';
  static String subjectUnits(int subjectId) => '$baseUrl/subjects/$subjectId/units';
  static String subjectReferences(int subjectId) => '$baseUrl/subjects/$subjectId/references';
  static String subjectSolvedExercises(int subjectId) => '$baseUrl/subjects/$subjectId/solved-exercises';
  static String subjectQuizzes(int subjectId) => '$baseUrl/subjects/$subjectId/exams';
  static String unitLessons(int unitId) => '$baseUrl/lessons/$unitId';
  static String lessonVideo(int lessonId) => '$baseUrl/lessons/$lessonId/video';
  static String lessonTest(int lessonId) => '$baseUrl/lessons/$lessonId/test';
  static String lessonSummary(int lessonId) => '$baseUrl/lessons/$lessonId/summary';

  // Notification Endpoints
  static const String notifications = '$baseUrl/student/notifications';
  static String markNotificationRead(int notificationId) => '$baseUrl/student/notifications/$notificationId/read';

  // Device Endpoints
  static const String registerDevice = '$baseUrl/student/devices';

  // Guest Endpoints (for unauthenticated users)
  static String guestSubjects(int divisionId) => '$baseUrl/guest/subjects?division_id=$divisionId';
  static String guestUnits(int subjectId) => '$baseUrl/guest/units?subject_id=$subjectId';
  static String guestLessons(int unitId, int divisionId) => '$baseUrl/guest/lessons?unit_id=$unitId&division_id=$divisionId';
  static String guestVideo(int lessonId) => '$baseUrl/guest/video/$lessonId';
  static String guestTest(int lessonId) => '$baseUrl/guest/test/$lessonId';
  static String guestReferences(int subjectId) => '$baseUrl/guest/references?subject_id=$subjectId';
  static String guestExams(int subjectId) => '$baseUrl/guest/exams?subject_id=$subjectId';
  static String guestSolvedExercises(int subjectId) => '$baseUrl/guest/solved-exercises?subject_id=$subjectId';
}
