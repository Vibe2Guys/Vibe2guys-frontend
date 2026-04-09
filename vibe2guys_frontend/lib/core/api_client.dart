import 'api_contract.dart';

abstract class ApiClient {
  String? get accessToken;
  AppUser? get currentUser;

  Future<ApiResponse<Map<String, dynamic>>> login({
    required String email,
    required String password,
    required UserRole role,
  });

  void logout();

  Future<ApiResponse<List<Map<String, dynamic>>>> getMyCourses();
  Future<ApiResponse<Map<String, dynamic>>> getCourseDetail(int courseId);
  Future<ApiResponse<List<Map<String, dynamic>>>> getCourseAssignments(int courseId);
  Future<ApiResponse<List<Map<String, dynamic>>>> getCourseQuizzes(int courseId);
  Future<ApiResponse<Map<String, dynamic>>> getContentDetail(int contentId);
  Future<ApiResponse<Map<String, dynamic>>> saveProgress({
    required int contentId,
    required int progressRate,
    required int watchedSeconds,
  });
  Future<ApiResponse<Map<String, dynamic>>> getAssignmentDetail(int assignmentId);
  Future<ApiResponse<Map<String, dynamic>>> submitAssignment({
    required int assignmentId,
    required String answerText,
  });
  Future<ApiResponse<Map<String, dynamic>>> getStudentDashboard();
  Future<ApiResponse<Map<String, dynamic>>> getMyReport();
  Future<ApiResponse<Map<String, dynamic>>> getRecommendations(int studentId);
  Future<ApiResponse<Map<String, dynamic>>> getMyTeam();
  Future<ApiResponse<Map<String, dynamic>>> getTeamDetail(int teamId);
  Future<ApiResponse<Map<String, dynamic>>> getTeamChatRoom(int teamId);
  Future<ApiResponse<List<Map<String, dynamic>>>> getChatMessages(int chatRoomId);
  Future<ApiResponse<Map<String, dynamic>>> getInstructorDashboard(int courseId);
  Future<ApiResponse<List<Map<String, dynamic>>>> getRiskStudents(int courseId);
  Future<ApiResponse<List<Map<String, dynamic>>>> getLowUnderstandingStudents(
    int courseId,
  );
  Future<ApiResponse<List<Map<String, dynamic>>>> getInterventions(int courseId);
}
