import 'package:get/get.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'ar': {
          // Profile Menu
          'hide_in_challenges': 'إخفاء ظهوري في التحديات',
          'edit_account': 'تعديل الحساب',
          'edit_password': 'تعديل كلمة المرور',
          'language': 'اللغة',
          'help': 'المساعدة',
          'privacy_policy': 'سياسة الخصوصية',
          'about': 'عن التطبيق',
          'rate_app': 'تقييم التطبيق',
          'share_app': 'مشاركة التطبيق',
          'logout': 'تسجيل الخروج',
          'delete_account': 'حذف الحساب',

          // Language Selection
          'select_language': 'اختر اللغة',
          'confirm': 'تأكيد',
          'save': 'حفظ',
          'arabic': 'اللغة العربية',
          'english': 'اللغة الانجليزية',
          'french': 'اللغة الفرنسية',

          // Dialog Messages
          'language_changed_success': 'تم تغيير اللغة بنجاح',
          'logout_confirm_title': 'هل انت متأكد من تسجيل الخروج ؟؟',
          'logout_confirm_message':
              'الان انت علي وشك تسجيل خروجك .. يمكنك\nتسجيل الدخول مرة اخري بكل سهولة',
          'delete_account_confirm_title': 'هل انت متأكد من حذف حسابك ؟؟',
          'delete_account_confirm_message':
              'الان انت علي وشك حذف حسابك .. لن تستطيع\nاسترجاع بيانات حسابك مرة اخري',
          'delete_reason_title': 'سبب حذف الحساب',
          'delete_reason_subtitle': 'من فضلك أخبرنا لماذا تريد حذف حسابك',
          'delete_reason_hint': 'اكتب السبب هنا...',
          'delete_reason_required': 'من فضلك أدخل سبب الحذف',
          'delete_request_sent': 'تم إرسال طلبك بنجاح',
          'submit': 'إرسال',
          'cancel': 'الغاء',
          'logout_success': 'تم تسجيل الخروج بنجاح',
          'account_changes_saved': 'تم حفظ التغييرات بنجاح',
          'password_changed_success': 'تم تغيير كلمة المرور بنجاح',

          // Validation Messages
          'please_enter_name': 'الرجاء إدخال الاسم',
          'please_enter_email': 'الرجاء إدخال البريد الإلكتروني',
          'please_enter_phone': 'الرجاء إدخال رقم الجوال',
          'please_enter_current_password': 'الرجاء إدخال كلمة المرور الحالية',
          'please_enter_new_password': 'الرجاء إدخال كلمة المرور الجديدة',
          'password_min_length': 'كلمة المرور يجب أن تكون 6 أحرف على الأقل',
          'passwords_not_match': 'كلمة المرور غير متطابقة',

          // Educational Stages
          'primary_stage': 'المرحلة الابتدائية',
          'middle_stage': 'المرحلة المتوسطة',
          'secondary_stage': 'المرحلة الثانوية',
          'university_stage': 'المرحلة الجامعية',

          // Divisions
          'scientific': 'علمي',
          'literary': 'أدبي',
          'technical': 'تقني',

          // FAQ Questions
          'faq_change_password_q': 'كيف يمكنني تغيير كلمة المرور؟',
          'faq_change_password_a':
              'يمكنك تغيير كلمة المرور من خلال الذهاب إلى الملف الشخصي ثم الضغط على تعديل كلمة المرور.',
          'faq_contact_support_q': 'كيف يمكنني التواصل مع الدعم؟',
          'faq_contact_support_a':
              'يمكنك التواصل معنا عبر البريد الإلكتروني أو الهاتف أو واتساب المتوفرين في أسفل هذه الصفحة.',
          'faq_update_account_q': 'كيف يمكنني تحديث بيانات حسابي؟',
          'faq_update_account_a':
              'يمكنك تحديث بياناتك من خلال الذهاب إلى الملف الشخصي ثم الضغط على تعديل الحساب.',
          'faq_is_free_q': 'هل التطبيق مجاني؟',
          'faq_is_free_a':
              'نعم، التطبيق مجاني بالكامل مع إمكانية الاشتراك في الباقات المميزة للحصول على مزايا إضافية.',
          'faq_delete_account_q': 'كيف يمكنني حذف حسابي؟',
          'faq_delete_account_a':
              'يمكنك حذف حسابك من خلال الذهاب إلى الملف الشخصي ثم الضغط على حذف الحساب في أسفل الصفحة.',

          // Splash & Loading
          'loading': 'جاري التحميل',

          // Onboarding
          'skip': 'تخطي',
          'previous': 'السابق',
          'next': 'التالي',
          'continue_as_guest': 'المتابعة كزائر',
          'select_preferences': 'اختر تفضيلاتك',
          'select_educational_stage_first': 'اختر المرحلة الدراسية أولاً',

          // Login
          'login': 'تسجيل الدخول',
          'login_subtitle': 'من فضلك ادخل بيانات حسابك للاستمرار',
          'phone_number': 'رقم الجوال',
          'password': 'كلمة المرور',
          'forgot_password': 'نسيت كلمة المرور؟',
          'new_here': 'جديد لدينا؟ ',
          'create_account': 'إنشاء حساب',

          // Sign Up
          'sign_up': 'إنشاء حساب جديد',
          'sign_up_subtitle': 'من فضلك ادخل بيانات حسابك للاستمرار',
          'username': 'اسم المستخدم',
          'email': 'البريد الالكتروني',
          'birth_date': 'تاريخ الميلاد',
          'educational_stage': 'المرحلة الدراسية',
          'select_educational_stage': 'قم باختيار المرحلة الدراسية',
          'division': 'الشعبة',
          'select_division': 'قم باختيار الشعبة',
          'gender': 'الجنس',
          'male': 'ذكر',
          'female': 'أنثى',
          'choose_gender': 'اختر الجنس',
          'profile_picture': 'الصورة الشخصية',
          'add_profile_picture': 'إضافة صورة شخصية',
          'change_picture': 'تغيير الصورة',
          'terms_and_conditions': 'الشروط والأحكام',
          'i_agree_to': ' لقد قرأت و وافقت على ',
          'have_account': ' لديك حساب ؟ ',
          'choose_educational_stage': 'اختر المرحلة الدراسية',
          'choose_division': 'اختر الشعبة',
          'wilaya': 'الولاية / المحافظة',
          'select_wilaya': 'قم باختيار الولاية',
          'choose_wilaya': 'اختر الولاية',

          // Mauritanian Wilayas
          'hodh_ech_chargui': 'الحوض الشرقي',
          'hodh_el_gharbi': 'الحوض الغربي',
          'assaba': 'العصابة',
          'gorgol': 'كوركول',
          'brakna': 'البراكنة',
          'trarza': 'الترارزة',
          'adrar': 'أدرار',
          'dakhlet_nouadhibou': 'داخلت نواذيبو',
          'tagant': 'تكانت',
          'guidimagha': 'غيديماغا',
          'tiris_zemmour': 'تيرس زمور',
          'inchiri': 'إينشيري',
          'nouakchott_north': 'نواكشوط الشمالية',
          'nouakchott_west': 'نواكشوط الغربية',
          'nouakchott_south': 'نواكشوط الجنوبية',

          // Forgot Password
          'forgot_password_title': 'نسيت كلمة المرور',
          'forgot_password_subtitle': 'من فضلك ادخل بريدك الالكتروني',
          'send_code': 'إرسال الرمز',

          // Restore Password / OTP
          'activate_account': 'تفعيل الحساب',
          'restore_password': 'استرجاع كلمة المرور',
          'enter_code_sent_to': 'ادخل الكود الذي تم ارساله إلى البريد الالكتروني ',
          'to_activate_account': ' لتفعيل حسابك',
          'to_restore_password': ' لإسترجاع كلمة المرور الخاصة بك',
          'didnt_receive_message': 'لم تستلم رسالة بعد ؟',
          'resend': 'إعادة الإرسال',
          'resend_after': 'إعادة الإرسال بعد ',
          'otp_sent_success': 'تم إرسال رمز التحقق إلى بريدك الإلكتروني',
          'otp_resent_success': 'تم إرسال الرمز مرة أخرى',
          'otp_resend_error': 'حدث خطأ أثناء إعادة إرسال الرمز',

          // New Password
          'create_password': 'انشئ كلمة المرور 🔒',
          'enter_new_password': 'ادخل كلمة المرور الجديدة 🔒',
          'password_requirements': 'ادخل كلمة مرور قوية تحتوي علي الاقل\n8احرف و ارقام و رموز',
          'new_password': 'كلمة المرور الجديدة',
          'confirm_password': 'تأكيد كلمة المرور',
          'password_req_length': 'من 8 الي 20 حرف',
          'password_req_case': 'علي الاقل حرف كبير و حرف صغير',
          'password_req_special': 'علي الاقل رمز واحد خاص',
          'password_req_number': 'علي الاقل رقم واحد',
          'passwords_must_match': 'يجب ان تكون كلمتا المرور متطابقان',

          // Subscription
          'subscription': 'الاشتراك',
          'subscription_details': 'تفاصيل الاشتراك',
          'why_choose_yearly': 'لماذا يجب أن تختار الاشتراك السنوي؟',
          'subscription_benefit_1': 'الوصول الكامل لجميع برامج البكالوريا بالصوت والصورة',
          'subscription_benefit_2': 'مشاهدة وتحليل اختبارات وامتحانات سابقة مع حلولها التفصيلية',
          'subscription_benefit_3': 'متابعة مباشرة للبثوث مع نخبة من أفضل الأساتذة',
          'subscription_benefit_4': 'تحديات واختبارات إضافية لتنمية مهاراتك وضمان استعدادك الكامل',
          'subscription_plans': 'خطط الاشتراك',
          'payment_method': 'طريقة الدفع',
          'select_payment_method': 'قم باختيار طريقة الدفع',
          'choose_subscription_plan': 'اختر خطة الاشتراك',
          'choose_payment_method': 'اختر طريقة الدفع',
          'no_plans_available': 'لا توجد خطط اشتراك متاحة حالياً',
          'subscription_for': 'اشتراك ',
          'annual_subscription': 'اشتراك سنوي',

          // Payment
          'enter_payment_details': 'من فضلك أدخل البيانات التالية لإتمام اشتراكك',
          'full_name': 'الاسم الكامل',
          'select_payment_account': 'اختر حساب الدفع',
          'no_bank_accounts': 'لا توجد حسابات بنكية متاحة حالياً',
          'unknown_bank': 'Unknown Bank',
          'transfer_instructions': 'يرجى تحويل مبلغ الاشتراك وإرفاق صورة الحوالة في الأسفل',
          'attach_receipt': 'اضغط هنا لإرفاق صورة الحوالة',
          'reference_number': 'رقم الحساب الذي تم الدفع منه',
          'enter_reference_number': 'أدخل رقم المرجع للتحويل',
          'have_coupon': 'لديك كوبون خصم ؟',
          'apply': 'تطبيق',
          'amount': 'المبلغ',
          'discount': 'الخصم',
          'total_amount': 'المبلغ الاجمالي',
          'complete_payment': 'إتمام الدفع',

          // Country Selection
          'mauritania': 'موريتانيا',
          'select_country_code': 'اختر كود الدولة',

          // Image Picker
          'choose_image_source': 'اختر مصدر الصورة',
          'camera': 'الكاميرا',
          'gallery': 'المعرض',

          // Ticket Bottom Sheet
          'choose_ticket_type': 'اختر نوع التذكرة',
          'technical_issue': 'مشكلة تقنية',
          'academic_issue': 'مشكلة أكاديمية',
          'educational_issue': 'مشكلة تعليمية',

          // Rating Dialog
          'rate_your_experience': 'قيم تجربتك لنا',
          'help_us_improve': 'ساعدنا في تحسين خدمتنا في تقييمك لنا',
          'your_notes': 'ملاحظاتك...',
          'thank_you': 'شكراً لك',
          'rating_submitted': 'تم إرسال تقييمك بنجاح',

          // Write Problem Dialog
          'write_your_problem': 'اكتب مشكلتك هنا',
          'problem_description_hint': 'قم بكتابة مشكلتك وسنقوم بالرد في أقرب وقت',
          'problem_description': 'وصف المشكلة',
          'send': 'إرسال',
          'sent': 'تم الإرسال',
          'problem_submitted': 'تم إرسال مشكلتك بنجاح، سنقوم بالرد في أقرب وقت',
          'please_enter_problem_description': 'الرجاء إدخال وصف المشكلة',
          'error_submitting_complaint': 'حدث خطأ أثناء إرسال الشكوى',

          // Help Center
          'help_center': 'مركز المساعدة',
          'help_subtitle': 'أخبرنا كيف يمكننا\nمساعدتك ؟',
          'support_numbers': 'أرقام الدعم',
          'mobile': 'الموبايل',
          'whatsapp_number': 'رقم واتساب',
          'some_faqs': 'بعض الأسئلة الشائعة',
          'didnt_find_what_looking_for': 'لم تجد ما كنت تبحث عنه ؟',
          'contact_support_team': 'تواصل مع فريق الدعم',
          'call_us': 'اتصل بنا',
          'calling': 'اتصال',
          'calling_phone_number': 'جاري الاتصال بـ',
          'whatsapp': 'واتساب',
          'opening_whatsapp': 'جاري فتح واتساب',
          'cannot_make_call': 'لا يمكن إجراء المكالمة',
          'cannot_open_whatsapp': 'لا يمكن فتح واتساب',
          'faq_join_subscription_q': 'كيفية الانضمام الي اشتراك معين ؟',
          'faq_join_subscription_a': 'يمكنك الاشتراك من خلال الذهاب إلى صفحة الاشتراكات واختيار الخطة المناسبة لك، ثم إتمام عملية الدفع.',
          'faq_guest_login_q': 'هل يمكنني الدخول كزائر؟',
          'faq_guest_login_a': 'نعم، يمكنك المتابعة كزائر من خلال الضغط على زر "المتابعة كزائر" في صفحة تسجيل الدخول.',

          // About View
          'app_name': 'ماجور',
          'version': 'الإصدار',
          'app_description': 'تطبيق ماجور هو منصة تعليمية متكاملة تهدف إلى تقديم محتوى تعليمي عالي الجودة للطلاب في مختلف المراحل الدراسية. يوفر التطبيق دروساً تفاعلية واختبارات ذاتية وتحديات تنافسية لتحفيز الطلاب على التعلم والتميز.',
          'follow_us': 'تابعنا على',
          'copyright': '© 2024 ماجور. جميع الحقوق محفوظة',

          // Edit Account View
          'edit_profile': 'تعديل الملف الشخصي',
          'save_changes': 'حفظ التغييرات',

          // Edit Password View
          'current_password': 'كلمة المرور الحالية',

          // Privacy Policy View
          'last_updated_january_2024': 'آخر تحديث: 1 يناير 2024',
          'introduction': 'مقدمة',
          'privacy_introduction_content': 'نحن في تطبيق ماجور نحترم خصوصيتك ونلتزم بحماية بياناتك الشخصية. توضح سياسة الخصوصية هذه كيفية جمع واستخدام وحماية معلوماتك عند استخدام تطبيقنا.',
          'data_we_collect': 'البيانات التي نجمعها',
          'data_we_collect_content': '• المعلومات الشخصية: الاسم، البريد الإلكتروني، رقم الهاتف\n• معلومات الحساب: اسم المستخدم، كلمة المرور\n• بيانات الاستخدام: سجل الدروس، نتائج الاختبارات\n• معلومات الجهاز: نوع الجهاز، نظام التشغيل',
          'how_we_use_data': 'كيف نستخدم بياناتك',
          'how_we_use_data_content': '• تقديم الخدمات التعليمية المطلوبة\n• تحسين تجربة المستخدم\n• إرسال إشعارات مهمة\n• تحليل أداء التطبيق\n• الدعم الفني',
          'data_protection': 'حماية البيانات',
          'data_protection_content': 'نستخدم تقنيات تشفير متقدمة لحماية بياناتك. لن نشارك معلوماتك الشخصية مع أطراف ثالثة دون موافقتك الصريحة.',
          'your_rights': 'حقوقك',
          'your_rights_content': '• الوصول إلى بياناتك الشخصية\n• تصحيح البيانات غير الدقيقة\n• حذف حسابك وبياناتك\n• الاعتراض على معالجة البيانات',
          'contact_us_privacy': 'إذا كان لديك أي أسئلة حول سياسة الخصوصية، يرجى التواصل معنا عبر:\nالبريد الإلكتروني: privacy@maajor.com',

          // Terms View
          'acceptance_of_terms': 'قبول الشروط',
          'acceptance_of_terms_content': 'باستخدامك لتطبيق ماجور، فإنك توافق على الالتزام بهذه الشروط والأحكام. إذا كنت لا توافق على أي من هذه الشروط، يرجى عدم استخدام التطبيق.',
          'account_registration': 'تسجيل الحساب',
          'account_registration_content': '• يجب أن تكون المعلومات المقدمة صحيحة ودقيقة\n• أنت مسؤول عن الحفاظ على سرية حسابك\n• يجب إبلاغنا فوراً عن أي استخدام غير مصرح به\n• يحق لنا تعليق أو إنهاء حسابك في حالة مخالفة الشروط',
          'usage_rules': 'قواعد الاستخدام',
          'usage_rules_content': '• استخدام التطبيق للأغراض التعليمية فقط\n• عدم مشاركة محتوى التطبيق بدون إذن\n• عدم محاولة اختراق أو تعطيل التطبيق\n• احترام حقوق الملكية الفكرية',
          'intellectual_property': 'الملكية الفكرية',
          'intellectual_property_content': 'جميع المحتويات والمواد التعليمية في التطبيق محمية بموجب قوانين حقوق الطبع والنشر. لا يجوز نسخ أو توزيع أي محتوى دون إذن كتابي مسبق.',
          'subscriptions_and_payment': 'الاشتراكات والدفع',
          'subscriptions_and_payment_content': '• الأسعار قابلة للتغيير مع إشعار مسبق\n• لا يمكن استرداد المبالغ المدفوعة\n• يتم التجديد التلقائي للاشتراكات\n• يمكن إلغاء الاشتراك في أي وقت',
          'disclaimer': 'إخلاء المسؤولية',
          'disclaimer_content': 'نقدم التطبيق "كما هو" دون أي ضمانات. لا نتحمل المسؤولية عن أي أضرار ناتجة عن استخدام التطبيق.',
          'modifications': 'التعديلات',
          'modifications_content': 'نحتفظ بالحق في تعديل هذه الشروط في أي وقت. سيتم إخطارك بأي تغييرات جوهرية.',

          // Challenges
          'student_challenges': 'تحديات الطلاب',
          'congratulations_close': 'تهانينا ... لقد اقتربت !',
          'your_rank_among': 'ترتيبك هو الـ @rank من بين @total',
          'points': 'نقطة',

          // Favorites
          'favorites': 'المفضلة',
          'favorites_tab': 'المفضلة',
          'saved_videos_tab': 'الدروس المحفوظة',
          'added_to_favorites': 'تمت الإضافة للمفضلة',
          'removed_from_favorites': 'تم الحذف من المفضلة',
          'lesson_test': 'اختبار الدرس',
          'no_test_available': 'لا يوجد اختبار متاح لهذا الدرس',
          'error_loading_test': 'حدث خطأ أثناء تحميل الاختبار',

          // Subjects
          'subjects': 'المواد',
          'educational_topics': 'المحاور التعليمية',
          'notes': 'مذكرات',
          'solved_exercises': 'تمارين محلولة',
          'pdf_references': 'مراجع PDF',
          'subject_test': 'اختبار المادة',
          'test_yourself': 'اختبر نفسك',
          'no_data_available': 'لا توجد بيانات متاحة',
          'number_of_students': 'عدد الطلاب',
          'number_of_hours': 'عدد الساعات',
          'number_of_topics': 'عدد المحاور',
          'students_count': '@count طالب',
          'hours_count': '@count ساعة',
          'topics_count': '@count محاور',
          'lessons_count': '@count درس',
          'live_time': 'موعد اللايف',
          'ongoing': 'جاري',
          'number_of_lessons': 'عدد الدروس',
          'teacher': 'المدرس',
          'lesson_summary': 'ملخص الدرس',
          'open_file': 'فتح الملف',
          'check_answer': 'تحقق من الإجابة',

          // Home & Notifications
          'notifications_title': 'الإشعارات',
          'notifications_empty_title': 'لا توجد إشعارات',
          'notifications_empty_description': 'سيتم عرض جميع إشعاراتك هنا',
          'subjects_view_all': 'عرض الكل',
          'subjects_search_placeholder': 'ابحث عن درس...',

          // Filter
          'filter_all': 'الكل',
          'filter_subject_label': 'المادة',
          'filter_lesson_number_label': 'رقم الدرس',
          'filter_choose_lesson_placeholder': 'اختر رقم الدرس',
          'filter_choose_lesson_title': 'اختر رقم الدرس',
          'filter_show_results_button': 'عرض النتائج',

          // Subject Names
          'subject_arabic': 'اللغة العربية',
          'subject_philosophy': 'الفلسفة',
          'subject_mathematics': 'الرياضيات',
          'subject_french': 'اللغة الفرنسية',
          'subject_english': 'اللغة الانجليزية',
          'subject_islamic_education': 'التربية الاسلامية',
          'subject_history_geography': 'التاريخ والجغرافيا',

          // Lesson Numbers
          'lesson_number_template': 'الدرس @number',
        },
        'en': {
          // Profile Menu
          'hide_in_challenges': 'Hide my appearance in challenges',
          'edit_account': 'Edit Account',
          'edit_password': 'Edit Password',
          'language': 'Language',
          'help': 'Help',
          'privacy_policy': 'Privacy Policy',
          'about': 'About',
          'rate_app': 'Rate App',
          'share_app': 'Share App',
          'logout': 'Logout',
          'delete_account': 'Delete Account',

          // Language Selection
          'select_language': 'Select Language',
          'confirm': 'Confirm',
          'save': 'Save',
          'arabic': 'Arabic',
          'english': 'English',
          'french': 'French',

          // Dialog Messages
          'language_changed_success': 'Language changed successfully',
          'logout_confirm_title': 'Are you sure you want to logout?',
          'logout_confirm_message':
              'You are about to logout. You can\nlogin again easily',
          'delete_account_confirm_title': 'Are you sure you want to delete your account?',
          'delete_account_confirm_message':
              'You are about to delete your account. You will not\nbe able to recover your account data again',
          'delete_reason_title': 'Reason for Account Deletion',
          'delete_reason_subtitle': 'Please tell us why you want to delete your account',
          'delete_reason_hint': 'Write the reason here...',
          'delete_reason_required': 'Please enter a reason for deletion',
          'delete_request_sent': 'Your request has been sent successfully',
          'submit': 'Submit',
          'cancel': 'Cancel',
          'logout_success': 'Logged out successfully',
          'account_changes_saved': 'Changes saved successfully',
          'password_changed_success': 'Password changed successfully',

          // Validation Messages
          'please_enter_name': 'Please enter name',
          'please_enter_email': 'Please enter email',
          'please_enter_phone': 'Please enter phone number',
          'please_enter_current_password': 'Please enter current password',
          'please_enter_new_password': 'Please enter new password',
          'password_min_length': 'Password must be at least 6 characters',
          'passwords_not_match': 'Passwords do not match',

          // Educational Stages
          'primary_stage': 'Primary Stage',
          'middle_stage': 'Middle Stage',
          'secondary_stage': 'Secondary Stage',
          'university_stage': 'University Stage',

          // Divisions
          'scientific': 'Scientific',
          'literary': 'Literary',
          'technical': 'Technical',

          // FAQ Questions
          'faq_change_password_q': 'How can I change my password?',
          'faq_change_password_a':
              'You can change your password by going to Profile then clicking on Edit Password.',
          'faq_contact_support_q': 'How can I contact support?',
          'faq_contact_support_a':
              'You can contact us via email, phone, or WhatsApp available at the bottom of this page.',
          'faq_update_account_q': 'How can I update my account information?',
          'faq_update_account_a':
              'You can update your information by going to Profile then clicking on Edit Account.',
          'faq_is_free_q': 'Is the app free?',
          'faq_is_free_a':
              'Yes, the app is completely free with the option to subscribe to premium packages for additional features.',
          'faq_delete_account_q': 'How can I delete my account?',
          'faq_delete_account_a':
              'You can delete your account by going to Profile then clicking on Delete Account at the bottom of the page.',

          // Splash & Loading
          'loading': 'Loading',

          // Onboarding
          'skip': 'Skip',
          'previous': 'Previous',
          'next': 'Next',
          'continue_as_guest': 'Continue as Guest',
          'select_preferences': 'Select your preferences',
          'select_educational_stage_first': 'Select educational stage first',

          // Login
          'login': 'Login',
          'login_subtitle': 'Please enter your account details to continue',
          'phone_number': 'Phone Number',
          'password': 'Password',
          'forgot_password': 'Forgot Password?',
          'new_here': 'New here? ',
          'create_account': 'Create Account',

          // Sign Up
          'sign_up': 'Create New Account',
          'sign_up_subtitle': 'Please enter your account details to continue',
          'username': 'Username',
          'email': 'Email',
          'birth_date': 'Birth Date',
          'educational_stage': 'Educational Stage',
          'select_educational_stage': 'Please select educational stage',
          'division': 'Division',
          'select_division': 'Please select division',
          'gender': 'Gender',
          'male': 'Male',
          'female': 'Female',
          'choose_gender': 'Choose Gender',
          'profile_picture': 'Profile Picture',
          'add_profile_picture': 'Add Profile Picture',
          'change_picture': 'Change Picture',
          'terms_and_conditions': 'Terms and Conditions',
          'i_agree_to': ' I have read and agreed to ',
          'have_account': ' Have an account? ',
          'choose_educational_stage': 'Choose Educational Stage',
          'choose_division': 'Choose Division',
          'wilaya': 'Wilaya / Governorate',
          'select_wilaya': 'Please select wilaya',
          'choose_wilaya': 'Choose Wilaya',

          // Mauritanian Wilayas
          'hodh_ech_chargui': 'Hodh Ech Chargui',
          'hodh_el_gharbi': 'Hodh El Gharbi',
          'assaba': 'Assaba',
          'gorgol': 'Gorgol',
          'brakna': 'Brakna',
          'trarza': 'Trarza',
          'adrar': 'Adrar',
          'dakhlet_nouadhibou': 'Dakhlet Nouadhibou',
          'tagant': 'Tagant',
          'guidimagha': 'Guidimagha',
          'tiris_zemmour': 'Tiris Zemmour',
          'inchiri': 'Inchiri',
          'nouakchott_north': 'Nouakchott North',
          'nouakchott_west': 'Nouakchott West',
          'nouakchott_south': 'Nouakchott South',

          // Forgot Password
          'forgot_password_title': 'Forgot Password',
          'forgot_password_subtitle': 'Please enter your email',
          'send_code': 'Send Code',

          // Restore Password / OTP
          'activate_account': 'Activate Account',
          'restore_password': 'Restore Password',
          'enter_code_sent_to': 'Enter the code sent to the email ',
          'to_activate_account': ' to activate your account',
          'to_restore_password': ' to restore your password',
          'didnt_receive_message': 'Didn\'t receive a message?',
          'resend': 'Resend',
          'resend_after': 'Resend after ',
          'otp_sent_success': 'Verification code sent to your email',
          'otp_resent_success': 'Code resent successfully',
          'otp_resend_error': 'Error resending the code',

          // New Password
          'create_password': 'Create Password 🔒',
          'enter_new_password': 'Enter New Password 🔒',
          'password_requirements': 'Enter a strong password containing at least\n8 characters, numbers and symbols',
          'new_password': 'New Password',
          'confirm_password': 'Confirm Password',
          'password_req_length': '8 to 20 characters',
          'password_req_case': 'At least one uppercase and one lowercase letter',
          'password_req_special': 'At least one special character',
          'password_req_number': 'At least one number',
          'passwords_must_match': 'Passwords must match',

          // Subscription
          'subscription': 'Subscription',
          'subscription_details': 'Subscription Details',
          'why_choose_yearly': 'Why should you choose the annual subscription?',
          'subscription_benefit_1': 'Full access to all baccalaureate programs with audio and video',
          'subscription_benefit_2': 'View and analyze past tests and exams with detailed solutions',
          'subscription_benefit_3': 'Live follow-up broadcasts with elite professors',
          'subscription_benefit_4': 'Additional challenges and tests to develop your skills and ensure full preparation',
          'subscription_plans': 'Subscription Plans',
          'payment_method': 'Payment Method',
          'select_payment_method': 'Please select payment method',
          'choose_subscription_plan': 'Choose Subscription Plan',
          'choose_payment_method': 'Choose Payment Method',
          'no_plans_available': 'No subscription plans available currently',
          'subscription_for': 'Subscription ',
          'annual_subscription': 'Annual Subscription',

          // Payment
          'enter_payment_details': 'Please enter the following details to complete your subscription',
          'full_name': 'Full Name',
          'select_payment_account': 'Select Payment Account',
          'no_bank_accounts': 'No bank accounts available currently',
          'unknown_bank': 'Unknown Bank',
          'transfer_instructions': 'Please transfer the subscription amount and attach a photo of the transfer below',
          'attach_receipt': 'Click here to attach transfer photo',
          'reference_number': 'Payment Account Number',
          'enter_reference_number': 'Enter reference number for transfer',
          'have_coupon': 'Have a discount coupon?',
          'apply': 'Apply',
          'amount': 'Amount',
          'discount': 'Discount',
          'total_amount': 'Total Amount',
          'complete_payment': 'Complete Payment',

          // Country Selection
          'mauritania': 'Mauritania',
          'select_country_code': 'Select Country Code',

          // Image Picker
          'choose_image_source': 'Choose Image Source',
          'camera': 'Camera',
          'gallery': 'Gallery',

          // Ticket Bottom Sheet
          'choose_ticket_type': 'Choose Ticket Type',
          'technical_issue': 'Technical Issue',
          'academic_issue': 'Academic Issue',
          'educational_issue': 'Educational Issue',

          // Rating Dialog
          'rate_your_experience': 'Rate Your Experience',
          'help_us_improve': 'Help us improve our service with your rating',
          'your_notes': 'Your notes...',
          'thank_you': 'Thank You',
          'rating_submitted': 'Your rating has been submitted successfully',

          // Write Problem Dialog
          'write_your_problem': 'Write Your Problem Here',
          'problem_description_hint': 'Write your problem and we will respond as soon as possible',
          'problem_description': 'Problem Description',
          'send': 'Send',
          'sent': 'Sent',
          'problem_submitted': 'Your problem has been submitted successfully, we will respond as soon as possible',
          'please_enter_problem_description': 'Please enter problem description',
          'error_submitting_complaint': 'Error submitting complaint',

          // Help Center
          'help_center': 'Help Center',
          'help_subtitle': 'Tell us how we can\nhelp you?',
          'support_numbers': 'Support Numbers',
          'mobile': 'Mobile',
          'whatsapp_number': 'WhatsApp Number',
          'some_faqs': 'Some Frequently Asked Questions',
          'didnt_find_what_looking_for': 'Didn\'t find what you were looking for?',
          'contact_support_team': 'Contact Support Team',
          'call_us': 'Call Us',
          'calling': 'Calling',
          'calling_phone_number': 'Calling',
          'whatsapp': 'WhatsApp',
          'opening_whatsapp': 'Opening WhatsApp',
          'cannot_make_call': 'Cannot make call',
          'cannot_open_whatsapp': 'Cannot open WhatsApp',
          'faq_join_subscription_q': 'How to join a specific subscription?',
          'faq_join_subscription_a': 'You can subscribe by going to the subscriptions page and choosing the plan that suits you, then completing the payment process.',
          'faq_guest_login_q': 'Can I login as a guest?',
          'faq_guest_login_a': 'Yes, you can continue as a guest by clicking the "Continue as Guest" button on the login page.',

          // About View
          'app_name': 'Maajor',
          'version': 'Version',
          'app_description': 'Maajor is a comprehensive educational platform aimed at delivering high-quality educational content to students at various educational stages. The app provides interactive lessons, self-tests, and competitive challenges to motivate students to learn and excel.',
          'follow_us': 'Follow Us',
          'copyright': '© 2024 Maajor. All Rights Reserved',

          // Edit Account View
          'edit_profile': 'Edit Profile',
          'save_changes': 'Save Changes',

          // Edit Password View
          'current_password': 'Current Password',

          // Privacy Policy View
          'last_updated_january_2024': 'Last Updated: January 1, 2024',
          'introduction': 'Introduction',
          'privacy_introduction_content': 'At Maajor, we respect your privacy and are committed to protecting your personal data. This privacy policy explains how we collect, use, and protect your information when you use our app.',
          'data_we_collect': 'Data We Collect',
          'data_we_collect_content': '• Personal Information: Name, email, phone number\n• Account Information: Username, password\n• Usage Data: Lesson history, test results\n• Device Information: Device type, operating system',
          'how_we_use_data': 'How We Use Your Data',
          'how_we_use_data_content': '• Provide requested educational services\n• Improve user experience\n• Send important notifications\n• Analyze app performance\n• Technical support',
          'data_protection': 'Data Protection',
          'data_protection_content': 'We use advanced encryption technologies to protect your data. We will not share your personal information with third parties without your explicit consent.',
          'your_rights': 'Your Rights',
          'your_rights_content': '• Access your personal data\n• Correct inaccurate data\n• Delete your account and data\n• Object to data processing',
          'contact_us_privacy': 'If you have any questions about our privacy policy, please contact us at:\nEmail: privacy@maajor.com',

          // Terms View
          'acceptance_of_terms': 'Acceptance of Terms',
          'acceptance_of_terms_content': 'By using the Maajor app, you agree to comply with these terms and conditions. If you do not agree with any of these terms, please do not use the app.',
          'account_registration': 'Account Registration',
          'account_registration_content': '• Information provided must be accurate and truthful\n• You are responsible for maintaining account confidentiality\n• You must notify us immediately of any unauthorized use\n• We reserve the right to suspend or terminate your account for violations',
          'usage_rules': 'Usage Rules',
          'usage_rules_content': '• Use the app for educational purposes only\n• Do not share app content without permission\n• Do not attempt to hack or disrupt the app\n• Respect intellectual property rights',
          'intellectual_property': 'Intellectual Property',
          'intellectual_property_content': 'All content and educational materials in the app are protected under copyright laws. No content may be copied or distributed without prior written permission.',
          'subscriptions_and_payment': 'Subscriptions and Payment',
          'subscriptions_and_payment_content': '• Prices are subject to change with prior notice\n• Payments are non-refundable\n• Subscriptions auto-renew automatically\n• You can cancel your subscription at any time',
          'disclaimer': 'Disclaimer',
          'disclaimer_content': 'We provide the app "as is" without any warranties. We are not liable for any damages resulting from use of the app.',
          'modifications': 'Modifications',
          'modifications_content': 'We reserve the right to modify these terms at any time. You will be notified of any substantial changes.',

          // Challenges
          'student_challenges': 'Student Challenges',
          'congratulations_close': 'Congratulations... You\'re close!',
          'your_rank_among': 'Your rank is @rank out of @total',
          'points': 'points',

          // Favorites
          'favorites': 'Favorites',
          'favorites_tab': 'Favorites',
          'saved_videos_tab': 'Saved Videos',
          'added_to_favorites': 'Added to favorites',
          'removed_from_favorites': 'Removed from favorites',
          'lesson_test': 'Lesson Test',
          'no_test_available': 'No test available for this lesson',
          'error_loading_test': 'Error loading test',

          // Subjects
          'subjects': 'Subjects',
          'educational_topics': 'Educational Topics',
          'notes': 'Notes',
          'solved_exercises': 'Solved Exercises',
          'pdf_references': 'PDF References',
          'subject_test': 'Subject Test',
          'test_yourself': 'Test Yourself',
          'no_data_available': 'No data available',
          'number_of_students': 'Number of Students',
          'number_of_hours': 'Number of Hours',
          'number_of_topics': 'Number of Topics',
          'students_count': '@count students',
          'hours_count': '@count hours',
          'topics_count': '@count topics',
          'lessons_count': '@count lessons',
          'live_time': 'Live Time',
          'ongoing': 'Ongoing',
          'number_of_lessons': 'Number of Lessons',
          'teacher': 'Teacher',
          'lesson_summary': 'Lesson Summary',
          'open_file': 'Open File',
          'check_answer': 'Check Answer',

          // Home & Notifications
          'notifications_title': 'Notifications',
          'notifications_empty_title': 'No Notifications',
          'notifications_empty_description': 'All your notifications will be displayed here',
          'subjects_view_all': 'View All',
          'subjects_search_placeholder': 'Search for a lesson...',

          // Filter
          'filter_all': 'All',
          'filter_subject_label': 'Subject',
          'filter_lesson_number_label': 'Lesson Number',
          'filter_choose_lesson_placeholder': 'Choose lesson number',
          'filter_choose_lesson_title': 'Choose Lesson Number',
          'filter_show_results_button': 'Show Results',

          // Subject Names
          'subject_arabic': 'Arabic Language',
          'subject_philosophy': 'Philosophy',
          'subject_mathematics': 'Mathematics',
          'subject_french': 'French Language',
          'subject_english': 'English Language',
          'subject_islamic_education': 'Islamic Education',
          'subject_history_geography': 'History and Geography',

          // Lesson Numbers
          'lesson_number_template': 'Lesson @number',
        },
        'fr': {
          // Profile Menu
          'hide_in_challenges': 'Masquer mon apparence dans les défis',
          'edit_account': 'Modifier le compte',
          'edit_password': 'Modifier le mot de passe',
          'language': 'Langue',
          'help': 'Aide',
          'privacy_policy': 'Politique de confidentialité',
          'about': 'À propos',
          'rate_app': 'Évaluer l\'application',
          'share_app': 'Partager l\'application',
          'logout': 'Déconnexion',
          'delete_account': 'Supprimer le compte',

          // Language Selection
          'select_language': 'Choisir la langue',
          'confirm': 'Confirmer',
          'save': 'Enregistrer',
          'arabic': 'Arabe',
          'english': 'Anglais',
          'french': 'Français',

          // Dialog Messages
          'language_changed_success': 'Langue changée avec succès',
          'logout_confirm_title': 'Êtes-vous sûr de vouloir vous déconnecter?',
          'logout_confirm_message':
              'Vous êtes sur le point de vous déconnecter. Vous pouvez\nvous reconnecter facilement',
          'delete_account_confirm_title':
              'Êtes-vous sûr de vouloir supprimer votre compte?',
          'delete_account_confirm_message':
              'Vous êtes sur le point de supprimer votre compte. Vous ne pourrez\npas récupérer vos données de compte',
          'delete_reason_title': 'Raison de la suppression du compte',
          'delete_reason_subtitle': 'Veuillez nous dire pourquoi vous voulez supprimer votre compte',
          'delete_reason_hint': 'Écrivez la raison ici...',
          'delete_reason_required': 'Veuillez entrer une raison pour la suppression',
          'delete_request_sent': 'Votre demande a été envoyée avec succès',
          'submit': 'Soumettre',
          'cancel': 'Annuler',
          'logout_success': 'Déconnexion réussie',
          'account_changes_saved': 'Modifications enregistrées avec succès',
          'password_changed_success': 'Mot de passe modifié avec succès',

          // Validation Messages
          'please_enter_name': 'Veuillez entrer le nom',
          'please_enter_email': 'Veuillez entrer l\'email',
          'please_enter_phone': 'Veuillez entrer le numéro de téléphone',
          'please_enter_current_password':
              'Veuillez entrer le mot de passe actuel',
          'please_enter_new_password':
              'Veuillez entrer le nouveau mot de passe',
          'password_min_length':
              'Le mot de passe doit comporter au moins 6 caractères',
          'passwords_not_match': 'Les mots de passe ne correspondent pas',

          // Educational Stages
          'primary_stage': 'Primaire',
          'middle_stage': 'Collège',
          'secondary_stage': 'Lycée',
          'university_stage': 'Université',

          // Divisions
          'scientific': 'Scientifique',
          'literary': 'Littéraire',
          'technical': 'Technique',

          // FAQ Questions
          'faq_change_password_q':
              'Comment puis-je changer mon mot de passe?',
          'faq_change_password_a':
              'Vous pouvez changer votre mot de passe en allant dans Profil puis en cliquant sur Modifier le mot de passe.',
          'faq_contact_support_q': 'Comment puis-je contacter le support?',
          'faq_contact_support_a':
              'Vous pouvez nous contacter par email, téléphone ou WhatsApp disponibles en bas de cette page.',
          'faq_update_account_q':
              'Comment puis-je mettre à jour mes informations de compte?',
          'faq_update_account_a':
              'Vous pouvez mettre à jour vos informations en allant dans Profil puis en cliquant sur Modifier le compte.',
          'faq_is_free_q': 'L\'application est-elle gratuite?',
          'faq_is_free_a':
              'Oui, l\'application est entièrement gratuite avec la possibilité de souscrire à des forfaits premium pour des fonctionnalités supplémentaires.',
          'faq_delete_account_q': 'Comment puis-je supprimer mon compte?',
          'faq_delete_account_a':
              'Vous pouvez supprimer votre compte en allant dans Profil puis en cliquant sur Supprimer le compte en bas de la page.',

          // Splash & Loading
          'loading': 'Chargement',

          // Onboarding
          'skip': 'Passer',
          'previous': 'Précédent',
          'next': 'Suivant',
          'continue_as_guest': 'Continuer en tant qu\'invité',
          'select_preferences': 'Sélectionnez vos préférences',
          'select_educational_stage_first': 'Sélectionnez d\'abord le niveau d\'études',

          // Login
          'login': 'Connexion',
          'login_subtitle': 'Veuillez entrer vos informations de compte pour continuer',
          'phone_number': 'Numéro de téléphone',
          'password': 'Mot de passe',
          'forgot_password': 'Mot de passe oublié?',
          'new_here': 'Nouveau ici? ',
          'create_account': 'Créer un compte',

          // Sign Up
          'sign_up': 'Créer un nouveau compte',
          'sign_up_subtitle': 'Veuillez entrer vos informations de compte pour continuer',
          'username': 'Nom d\'utilisateur',
          'email': 'Email',
          'birth_date': 'Date de naissance',
          'educational_stage': 'Niveau d\'études',
          'select_educational_stage': 'Veuillez sélectionner le niveau d\'études',
          'division': 'Division',
          'select_division': 'Veuillez sélectionner la division',
          'gender': 'Genre',
          'male': 'Masculin',
          'female': 'Féminin',
          'choose_gender': 'Choisir le genre',
          'profile_picture': 'Photo de profil',
          'add_profile_picture': 'Ajouter une photo de profil',
          'change_picture': 'Changer la photo',
          'terms_and_conditions': 'Conditions générales',
          'i_agree_to': ' J\'ai lu et accepté les ',
          'have_account': ' Vous avez un compte? ',
          'choose_educational_stage': 'Choisir le niveau d\'études',
          'choose_division': 'Choisir la division',
          'wilaya': 'Wilaya / Gouvernorat',
          'select_wilaya': 'Veuillez sélectionner la wilaya',
          'choose_wilaya': 'Choisir la Wilaya',

          // Mauritanian Wilayas
          'hodh_ech_chargui': 'Hodh Ech Chargui',
          'hodh_el_gharbi': 'Hodh El Gharbi',
          'assaba': 'Assaba',
          'gorgol': 'Gorgol',
          'brakna': 'Brakna',
          'trarza': 'Trarza',
          'adrar': 'Adrar',
          'dakhlet_nouadhibou': 'Dakhlet Nouadhibou',
          'tagant': 'Tagant',
          'guidimagha': 'Guidimagha',
          'tiris_zemmour': 'Tiris Zemmour',
          'inchiri': 'Inchiri',
          'nouakchott_north': 'Nouakchott Nord',
          'nouakchott_west': 'Nouakchott Ouest',
          'nouakchott_south': 'Nouakchott Sud',

          // Forgot Password
          'forgot_password_title': 'Mot de passe oublié',
          'forgot_password_subtitle': 'Veuillez entrer votre email',
          'send_code': 'Envoyer le code',

          // Restore Password / OTP
          'activate_account': 'Activer le compte',
          'restore_password': 'Récupérer le mot de passe',
          'enter_code_sent_to': 'Entrez le code envoyé à l\'email ',
          'to_activate_account': ' pour activer votre compte',
          'to_restore_password': ' pour récupérer votre mot de passe',
          'didnt_receive_message': 'Vous n\'avez pas reçu de message?',
          'resend': 'Renvoyer',
          'resend_after': 'Renvoyer après ',
          'otp_sent_success': 'Code de vérification envoyé à votre email',
          'otp_resent_success': 'Code renvoyé avec succès',
          'otp_resend_error': 'Erreur lors du renvoi du code',

          // New Password
          'create_password': 'Créer un mot de passe 🔒',
          'enter_new_password': 'Entrer un nouveau mot de passe 🔒',
          'password_requirements': 'Entrez un mot de passe fort contenant au moins\n8 caractères, chiffres et symboles',
          'new_password': 'Nouveau mot de passe',
          'confirm_password': 'Confirmer le mot de passe',
          'password_req_length': '8 à 20 caractères',
          'password_req_case': 'Au moins une majuscule et une minuscule',
          'password_req_special': 'Au moins un caractère spécial',
          'password_req_number': 'Au moins un chiffre',
          'passwords_must_match': 'Les mots de passe doivent correspondre',

          // Subscription
          'subscription': 'Abonnement',
          'subscription_details': 'Détails de l\'abonnement',
          'why_choose_yearly': 'Pourquoi choisir l\'abonnement annuel?',
          'subscription_benefit_1': 'Accès complet à tous les programmes de baccalauréat avec audio et vidéo',
          'subscription_benefit_2': 'Visionner et analyser les tests et examens passés avec des solutions détaillées',
          'subscription_benefit_3': 'Suivi en direct avec des professeurs d\'élite',
          'subscription_benefit_4': 'Défis et tests supplémentaires pour développer vos compétences et assurer une préparation complète',
          'subscription_plans': 'Plans d\'abonnement',
          'payment_method': 'Méthode de paiement',
          'select_payment_method': 'Veuillez sélectionner la méthode de paiement',
          'choose_subscription_plan': 'Choisir le plan d\'abonnement',
          'choose_payment_method': 'Choisir la méthode de paiement',
          'no_plans_available': 'Aucun plan d\'abonnement disponible actuellement',
          'subscription_for': 'Abonnement ',
          'annual_subscription': 'Abonnement annuel',

          // Payment
          'enter_payment_details': 'Veuillez entrer les détails suivants pour compléter votre abonnement',
          'full_name': 'Nom complet',
          'select_payment_account': 'Sélectionner le compte de paiement',
          'no_bank_accounts': 'Aucun compte bancaire disponible actuellement',
          'unknown_bank': 'Banque inconnue',
          'transfer_instructions': 'Veuillez transférer le montant de l\'abonnement et joindre une photo du transfert ci-dessous',
          'attach_receipt': 'Cliquez ici pour joindre la photo du transfert',
          'reference_number': 'Numéro de compte de paiement',
          'enter_reference_number': 'Entrez le numéro de référence du transfert',
          'have_coupon': 'Vous avez un coupon de réduction?',
          'apply': 'Appliquer',
          'amount': 'Montant',
          'discount': 'Réduction',
          'total_amount': 'Montant total',
          'complete_payment': 'Finaliser le paiement',

          // Country Selection
          'mauritania': 'Mauritanie',
          'select_country_code': 'Sélectionner le code pays',

          // Image Picker
          'choose_image_source': 'Choisir la source de l\'image',
          'camera': 'Caméra',
          'gallery': 'Galerie',

          // Ticket Bottom Sheet
          'choose_ticket_type': 'Choisir le type de ticket',
          'technical_issue': 'Problème technique',
          'academic_issue': 'Problème académique',
          'educational_issue': 'Problème éducatif',

          // Rating Dialog
          'rate_your_experience': 'Évaluez votre expérience',
          'help_us_improve': 'Aidez-nous à améliorer notre service avec votre évaluation',
          'your_notes': 'Vos notes...',
          'thank_you': 'Merci',
          'rating_submitted': 'Votre évaluation a été soumise avec succès',

          // Write Problem Dialog
          'write_your_problem': 'Écrivez votre problème ici',
          'problem_description_hint': 'Écrivez votre problème et nous répondrons dès que possible',
          'problem_description': 'Description du problème',
          'send': 'Envoyer',
          'sent': 'Envoyé',
          'problem_submitted': 'Votre problème a été soumis avec succès, nous répondrons dès que possible',
          'please_enter_problem_description': 'Veuillez entrer la description du problème',
          'error_submitting_complaint': 'Erreur lors de l\'envoi de la plainte',

          // Help Center
          'help_center': 'Centre d\'aide',
          'help_subtitle': 'Dites-nous comment nous pouvons\nvous aider?',
          'support_numbers': 'Numéros de support',
          'mobile': 'Mobile',
          'whatsapp_number': 'Numéro WhatsApp',
          'some_faqs': 'Questions fréquemment posées',
          'didnt_find_what_looking_for': 'Vous n\'avez pas trouvé ce que vous cherchiez?',
          'contact_support_team': 'Contacter l\'équipe de support',
          'call_us': 'Appelez-nous',
          'calling': 'Appel',
          'calling_phone_number': 'Appel en cours',
          'whatsapp': 'WhatsApp',
          'opening_whatsapp': 'Ouverture de WhatsApp',
          'cannot_make_call': 'Impossible de passer l\'appel',
          'cannot_open_whatsapp': 'Impossible d\'ouvrir WhatsApp',
          'faq_join_subscription_q': 'Comment rejoindre un abonnement spécifique?',
          'faq_join_subscription_a': 'Vous pouvez vous abonner en vous rendant sur la page des abonnements et en choisissant le plan qui vous convient, puis en complétant le processus de paiement.',
          'faq_guest_login_q': 'Puis-je me connecter en tant qu\'invité?',
          'faq_guest_login_a': 'Oui, vous pouvez continuer en tant qu\'invité en cliquant sur le bouton "Continuer en tant qu\'invité" sur la page de connexion.',

          // About View
          'app_name': 'Maajor',
          'version': 'Version',
          'app_description': 'Maajor est une plateforme éducative complète visant à fournir un contenu éducatif de haute qualité aux étudiants de différents niveaux. L\'application propose des leçons interactives, des tests autonomes et des défis compétitifs pour motiver les étudiants à apprendre et exceller.',
          'follow_us': 'Suivez-nous',
          'copyright': '© 2024 Maajor. Tous droits réservés',

          // Edit Account View
          'edit_profile': 'Modifier le profil',
          'save_changes': 'Enregistrer les modifications',

          // Edit Password View
          'current_password': 'Mot de passe actuel',

          // Privacy Policy View
          'last_updated_january_2024': 'Dernière mise à jour: 1er janvier 2024',
          'introduction': 'Introduction',
          'privacy_introduction_content': 'Chez Maajor, nous respectons votre vie privée et nous nous engageons à protéger vos données personnelles. Cette politique de confidentialité explique comment nous collectons, utilisons et protégeons vos informations lorsque vous utilisez notre application.',
          'data_we_collect': 'Données que nous collectons',
          'data_we_collect_content': '• Informations personnelles: Nom, e-mail, numéro de téléphone\n• Informations de compte: Nom d\'utilisateur, mot de passe\n• Données d\'utilisation: Historique des leçons, résultats des tests\n• Informations sur l\'appareil: Type d\'appareil, système d\'exploitation',
          'how_we_use_data': 'Comment nous utilisons vos données',
          'how_we_use_data_content': '• Fournir les services éducatifs demandés\n• Améliorer l\'expérience utilisateur\n• Envoyer des notifications importantes\n• Analyser les performances de l\'application\n• Support technique',
          'data_protection': 'Protection des données',
          'data_protection_content': 'Nous utilisons des technologies de cryptage avancées pour protéger vos données. Nous ne partagerons pas vos informations personnelles avec des tiers sans votre consentement explicite.',
          'your_rights': 'Vos droits',
          'your_rights_content': '• Accéder à vos données personnelles\n• Corriger les données inexactes\n• Supprimer votre compte et vos données\n• S\'opposer au traitement des données',
          'contact_us_privacy': 'Si vous avez des questions concernant notre politique de confidentialité, veuillez nous contacter à:\nE-mail: privacy@maajor.com',

          // Terms View
          'acceptance_of_terms': 'Acceptation des conditions',
          'acceptance_of_terms_content': 'En utilisant l\'application Maajor, vous acceptez de vous conformer à ces termes et conditions. Si vous n\'êtes pas d\'accord avec l\'un de ces termes, veuillez ne pas utiliser l\'application.',
          'account_registration': 'Inscription au compte',
          'account_registration_content': '• Les informations fournies doivent être exactes et véridiques\n• Vous êtes responsable du maintien de la confidentialité du compte\n• Vous devez nous informer immédiatement de toute utilisation non autorisée\n• Nous nous réservons le droit de suspendre ou de résilier votre compte en cas de violations',
          'usage_rules': 'Règles d\'utilisation',
          'usage_rules_content': '• Utiliser l\'application uniquement à des fins éducatives\n• Ne pas partager le contenu de l\'application sans autorisation\n• Ne pas tenter de pirater ou de perturber l\'application\n• Respecter les droits de propriété intellectuelle',
          'intellectual_property': 'Propriété intellectuelle',
          'intellectual_property_content': 'Tout le contenu et les matériels éducatifs de l\'application sont protégés par les lois sur le droit d\'auteur. Aucun contenu ne peut être copié ou distribué sans autorisation écrite préalable.',
          'subscriptions_and_payment': 'Abonnements et paiement',
          'subscriptions_and_payment_content': '• Les prix sont sujets à changement avec préavis\n• Les paiements ne sont pas remboursables\n• Les abonnements se renouvellent automatiquement\n• Vous pouvez annuler votre abonnement à tout moment',
          'disclaimer': 'Déni de responsabilité',
          'disclaimer_content': 'Nous fournissons l\'application "telle quelle" sans aucune garantie. Nous ne sommes pas responsables des dommages résultant de l\'utilisation de l\'application.',
          'modifications': 'Modifications',
          'modifications_content': 'Nous nous réservons le droit de modifier ces conditions à tout moment. Vous serez informé de tout changement substantiel.',

          // Challenges
          'student_challenges': 'Défis des étudiants',
          'congratulations_close': 'Félicitations... Vous êtes proche!',
          'your_rank_among': 'Votre rang est @rank sur @total',
          'points': 'points',

          // Favorites
          'favorites': 'Favoris',
          'favorites_tab': 'Favoris',
          'saved_videos_tab': 'Vidéos enregistrées',
          'added_to_favorites': 'Ajouté aux favoris',
          'removed_from_favorites': 'Supprimé des favoris',
          'lesson_test': 'Test de leçon',
          'no_test_available': 'Aucun test disponible pour cette leçon',
          'error_loading_test': 'Erreur lors du chargement du test',

          // Subjects
          'subjects': 'Matières',
          'educational_topics': 'Sujets éducatifs',
          'notes': 'Notes',
          'solved_exercises': 'Exercices résolus',
          'pdf_references': 'Références PDF',
          'subject_test': 'Test de matière',
          'test_yourself': 'Testez-vous',
          'no_data_available': 'Aucune donnée disponible',
          'number_of_students': 'Nombre d\'étudiants',
          'number_of_hours': 'Nombre d\'heures',
          'number_of_topics': 'Nombre de sujets',
          'students_count': '@count étudiants',
          'hours_count': '@count heures',
          'topics_count': '@count sujets',
          'lessons_count': '@count leçons',
          'live_time': 'Heure du direct',
          'ongoing': 'En cours',
          'number_of_lessons': 'Nombre de leçons',
          'teacher': 'Enseignant',
          'lesson_summary': 'Résumé de la leçon',
          'open_file': 'Ouvrir le fichier',
          'check_answer': 'Vérifier la réponse',

          // Home & Notifications
          'notifications_title': 'Notifications',
          'notifications_empty_title': 'Aucune notification',
          'notifications_empty_description': 'Toutes vos notifications seront affichées ici',
          'subjects_view_all': 'Voir tout',
          'subjects_search_placeholder': 'Rechercher une leçon...',

          // Filter
          'filter_all': 'Tout',
          'filter_subject_label': 'Matière',
          'filter_lesson_number_label': 'Numéro de leçon',
          'filter_choose_lesson_placeholder': 'Choisir le numéro de leçon',
          'filter_choose_lesson_title': 'Choisir le numéro de leçon',
          'filter_show_results_button': 'Afficher les résultats',

          // Subject Names
          'subject_arabic': 'Langue arabe',
          'subject_philosophy': 'Philosophie',
          'subject_mathematics': 'Mathématiques',
          'subject_french': 'Langue française',
          'subject_english': 'Langue anglaise',
          'subject_islamic_education': 'Éducation islamique',
          'subject_history_geography': 'Histoire et géographie',

          // Lesson Numbers
          'lesson_number_template': 'Leçon @number',
        },
      };
}
