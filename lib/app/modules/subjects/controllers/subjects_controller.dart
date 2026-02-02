import 'package:get/get.dart';
import 'dart:developer' as developer;
import '../../../core/services/storage_service.dart';
import '../models/subject_model.dart';
import '../models/unit_model.dart';
import '../models/pdf_resource_model.dart';
import '../providers/subjects_provider.dart';
import '../views/subject_detail_view.dart';

class SubjectsController extends GetxController {
  final StorageService storageService = Get.find<StorageService>();
  final SubjectsProvider subjectsProvider = SubjectsProvider();

  // Subjects list
  final RxList<SubjectModel> subjects = <SubjectModel>[].obs;
  final RxBool isLoading = false.obs;

  // Selected subject's units
  final RxList<UnitModel> units = <UnitModel>[].obs;
  final RxBool isLoadingUnits = false.obs;

  // Selected subject's references
  final RxList<PDFResourceModel> references = <PDFResourceModel>[].obs;
  final RxBool isLoadingReferences = false.obs;

  // Selected subject's solved exercises
  final RxList<PDFResourceModel> solvedExercises = <PDFResourceModel>[].obs;
  final RxBool isLoadingSolvedExercises = false.obs;

  // Selected subject's quizzes
  final RxList<PDFResourceModel> quizzes = <PDFResourceModel>[].obs;
  final RxBool isLoadingQuizzes = false.obs;

  // Load subjects data from API
  Future<void> loadSubjects() async {
    try {
      isLoading.value = true;

      // Get division ID from logged in user or guest
      final divisionId = storageService.currentUser?.divisionId ?? storageService.guestDivisionId;

      if (divisionId == null) {
        developer.log('❌ No division ID found for user', name: 'SubjectsController');
        isLoading.value = false;
        return;
      }

      developer.log('📚 Loading subjects for division: $divisionId', name: 'SubjectsController');

      final response = await subjectsProvider.getSubjectsByDivision(divisionId);

      if (response.success) {
        subjects.value = response.data;
        developer.log('✅ Subjects loaded: ${subjects.length} subjects', name: 'SubjectsController');
      } else {
        developer.log('❌ Failed to load subjects', name: 'SubjectsController');
      }
    } catch (e) {
      developer.log('❌ Error loading subjects: $e', name: 'SubjectsController');
    } finally {
      isLoading.value = false;
    }
  }

  // Pull-to-refresh handler for subjects page
  Future<void> onRefresh() async {
    try {
      developer.log('🔄 Pull-to-refresh triggered on subjects page', name: 'SubjectsController');

      // Reload subjects
      await loadSubjects();

      developer.log('✅ Subjects page refreshed successfully', name: 'SubjectsController');
    } catch (e) {
      developer.log('❌ Error refreshing subjects page: $e', name: 'SubjectsController');
    }
  }

  // Load units for a specific subject
  Future<void> loadUnits(int subjectId) async {
    try {
      isLoadingUnits.value = true;

      developer.log('📖 Loading units for subject: $subjectId', name: 'SubjectsController');

      final response = await subjectsProvider.getSubjectUnits(subjectId);

      if (response.success) {
        units.value = response.data;
        developer.log('✅ Units loaded: ${units.length} units', name: 'SubjectsController');
      } else {
        developer.log('❌ Failed to load units', name: 'SubjectsController');
      }
    } catch (e) {
      developer.log('❌ Error loading units: $e', name: 'SubjectsController');
    } finally {
      isLoadingUnits.value = false;
    }
  }

  // Load references for a specific subject
  Future<void> loadReferences(int subjectId) async {
    try {
      isLoadingReferences.value = true;

      developer.log('📚 Loading references for subject: $subjectId', name: 'SubjectsController');

      final response = await subjectsProvider.getSubjectReferences(subjectId);

      if (response.success) {
        references.value = response.data;
        developer.log('✅ References loaded: ${references.length} items', name: 'SubjectsController');
      } else {
        developer.log('❌ Failed to load references', name: 'SubjectsController');
      }
    } catch (e) {
      developer.log('❌ Error loading references: $e', name: 'SubjectsController');
    } finally {
      isLoadingReferences.value = false;
    }
  }

  // Load solved exercises for a specific subject
  Future<void> loadSolvedExercises(int subjectId) async {
    try {
      isLoadingSolvedExercises.value = true;

      developer.log('📝 Loading solved exercises for subject: $subjectId', name: 'SubjectsController');

      final response = await subjectsProvider.getSubjectSolvedExercises(subjectId);

      if (response.success) {
        solvedExercises.value = response.data;
        developer.log('✅ Solved exercises loaded: ${solvedExercises.length} items', name: 'SubjectsController');
      } else {
        developer.log('❌ Failed to load solved exercises', name: 'SubjectsController');
      }
    } catch (e) {
      developer.log('❌ Error loading solved exercises: $e', name: 'SubjectsController');
    } finally {
      isLoadingSolvedExercises.value = false;
    }
  }

  // Load quizzes for a specific subject
  Future<void> loadQuizzes(int subjectId) async {
    try {
      isLoadingQuizzes.value = true;

      developer.log('🎯 Loading quizzes for subject: $subjectId', name: 'SubjectsController');

      final response = await subjectsProvider.getSubjectQuizzes(subjectId);

      if (response.success) {
        quizzes.value = response.data;
        developer.log('✅ Quizzes loaded: ${quizzes.length} items', name: 'SubjectsController');
      } else {
        developer.log('❌ Failed to load quizzes', name: 'SubjectsController');
      }
    } catch (e) {
      developer.log('❌ Error loading quizzes: $e', name: 'SubjectsController');
    } finally {
      isLoadingQuizzes.value = false;
    }
  }

  // Current subject ID
  final Rx<int?> currentSubjectId = Rx<int?>(null);

  // Handle subject tap
  void onSubjectTap(SubjectModel subject) {
    // Store current subject ID
    currentSubjectId.value = subject.id;

    // Clear previous data
    units.clear();
    references.clear();
    solvedExercises.clear();
    quizzes.clear();

    // Navigate to subject details page
    Get.to(
      () => SubjectDetailView(subject: subject),
      transition: Transition.rightToLeft,
      duration: const Duration(milliseconds: 300),
    );
  }
}
