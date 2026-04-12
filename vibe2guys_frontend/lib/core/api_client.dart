import 'api_contract.dart';

abstract class ApiClient {
  String? get accessToken;
  AppUser? get currentUser;

  Future<ApiResponse<Map<String, dynamic>>> register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  });

  Future<ApiResponse<Map<String, dynamic>>> login({
    required String email,
    required String password,
    required UserRole role,
  });

  Future<void> logout();

  Future<ApiResponse<List<Map<String, dynamic>>>> getMyCourses();
  Future<ApiResponse<List<Map<String, dynamic>>>> getCourses({String? keyword});
  Future<ApiResponse<Map<String, dynamic>>> createCourse({
    required String title,
    required String description,
    required String thumbnailUrl,
    required String startDate,
    required String endDate,
    required bool isSequentialRelease,
    required bool isPublic,
  });
  Future<ApiResponse<Map<String, dynamic>>> enrollCourse(
      {required int courseId});
  Future<ApiResponse<Map<String, dynamic>>> enrollCourseByCode({
    required String courseCode,
  });
  Future<ApiResponse<Map<String, dynamic>>> getCourseDetail(int courseId);
  Future<ApiResponse<List<Map<String, dynamic>>>> getMyLearningLogs(
      int courseId);
  Future<ApiResponse<List<Map<String, dynamic>>>> getCourseStudents(
      int courseId);
  Future<ApiResponse<Map<String, dynamic>>> updateCourseStudentMemo({
    required int courseId,
    required int studentId,
    required String memo,
  });
  Future<ApiResponse<Map<String, dynamic>>> createWeek({
    required int courseId,
    required int weekNumber,
    required String title,
    required String openAt,
  });
  Future<ApiResponse<List<Map<String, dynamic>>>> getWeekContents(
      int courseId, int weekId);
  Future<ApiResponse<Map<String, dynamic>>> createContent({
    required int weekId,
    required String type,
    required String title,
    required String description,
    String? videoUrl,
    String? documentUrl,
    int? durationSeconds,
    String? scheduledAt,
    required String openAt,
  });
  Future<ApiResponse<Map<String, dynamic>>> createVideoUploadUrl({
    required String fileName,
    required String contentType,
  });
  Future<ApiResponse<Map<String, dynamic>>> createUploadUrl({
    required String fileName,
    required String contentType,
    required String category,
  });
  Future<ApiResponse<Map<String, dynamic>>> getMyProfile();
  Future<ApiResponse<Map<String, dynamic>>> updateMyProfile({
    required String name,
    required String profileImageUrl,
  });
  Future<ApiResponse<List<Map<String, dynamic>>>> getCourseAssignments(
      int courseId);
  Future<ApiResponse<List<Map<String, dynamic>>>> getCourseQuizzes(
      int courseId);
  Future<ApiResponse<Map<String, dynamic>>> getContentDetail(int contentId);
  Future<ApiResponse<Map<String, dynamic>>> saveProgress({
    required int contentId,
    required int progressRate,
    required int watchedSeconds,
    required int totalSeconds,
  });
  Future<ApiResponse<Map<String, dynamic>>> getAssignmentDetail(
      int assignmentId);
  Future<ApiResponse<Map<String, dynamic>>> submitAssignment({
    required int assignmentId,
    required String answerText,
  });
  Future<ApiResponse<Map<String, dynamic>>> getStudentDashboard();
  Future<ApiResponse<Map<String, dynamic>>> getMyReport();
  Future<ApiResponse<Map<String, dynamic>>> getRecommendations(int studentId);
  Future<ApiResponse<Map<String, dynamic>>> getMyTeam();
  Future<ApiResponse<List<Map<String, dynamic>>>> getCourseTeams(int courseId);
  Future<ApiResponse<Map<String, dynamic>>> autoGroupTeams({
    required int courseId,
    required int teamSize,
  });
  Future<ApiResponse<Map<String, dynamic>>> getTeamDetail(int teamId);
  Future<ApiResponse<Map<String, dynamic>>> getTeamAnalytics(int teamId);
  Future<ApiResponse<List<Map<String, dynamic>>>> getTeamMemberContributions(
      int teamId);
  Future<ApiResponse<Map<String, dynamic>>> getTeamChatRoom(int teamId);
  Future<ApiResponse<List<Map<String, dynamic>>>> getChatMessages(
      int chatRoomId);
  Future<ApiResponse<Map<String, dynamic>>> getInstructorDashboard(
      int courseId);
  Future<ApiResponse<List<Map<String, dynamic>>>> getRiskStudents(int courseId);
  Future<ApiResponse<List<Map<String, dynamic>>>> getLowUnderstandingStudents(
    int courseId,
  );
  Future<ApiResponse<List<Map<String, dynamic>>>> getInterventions(
      int courseId);
}
