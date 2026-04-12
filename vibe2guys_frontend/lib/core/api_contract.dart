enum UserRole {
  student('STUDENT', '학습자'),
  instructor('INSTRUCTOR', '교수자'),
  admin('ADMIN', '관리자');

  const UserRole(this.apiValue, this.label);
  final String apiValue;
  final String label;

  static UserRole fromApi(String value) {
    return UserRole.values.firstWhere(
      (role) => role.apiValue == value,
      orElse: () => UserRole.student,
    );
  }
}

class ApiResponse<T> {
  const ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.errorCode,
  });

  final bool success;
  final String message;
  final T? data;
  final String? errorCode;
}

class AppUser {
  const AppUser({
    required this.userId,
    required this.name,
    required this.email,
    required this.role,
  });

  final int userId;
  final String name;
  final String email;
  final UserRole role;
}

class Endpoints {
  static const String baseUrl = '/api/v1';

  static const String authRegister = '$baseUrl/auth/register';
  static const String authLogin = '$baseUrl/auth/login';
  static const String coursesMy = '$baseUrl/courses/my';
  static const String courses = '$baseUrl/courses';
  static const String dashboardStudent = '$baseUrl/dashboard/student';
  static const String reportsMe = '$baseUrl/reports/me';
  static const String teamsMe = '$baseUrl/teams/me';

  static String courseDetail(int courseId) => '$baseUrl/courses/$courseId';
  static String courseWeeks(int courseId) => '$baseUrl/courses/$courseId/weeks';
  static String weekContents(int courseId, int weekId) =>
      '$baseUrl/courses/$courseId/weeks/$weekId/contents';
  static String createContent(int weekId) => '$baseUrl/weeks/$weekId/contents';
  static String courseAssignments(int courseId) =>
      '$baseUrl/courses/$courseId/assignments';
  static String courseQuizzes(int courseId) => '$baseUrl/courses/$courseId/quizzes';
  static String contentDetail(int contentId) => '$baseUrl/contents/$contentId';
  static String contentProgress(int contentId) =>
      '$baseUrl/contents/$contentId/progress';
  static String assignmentDetail(int assignmentId) =>
      '$baseUrl/assignments/$assignmentId';
  static String assignmentSubmit(int assignmentId) =>
      '$baseUrl/assignments/$assignmentId/submissions';
  static String studentRecommendations(int studentId) =>
      '$baseUrl/students/$studentId/recommendations';
  static String teamDetail(int teamId) => '$baseUrl/teams/$teamId';
  static String courseTeams(int courseId) => '$baseUrl/courses/$courseId/teams';
  static String courseTeamAutoGrouping(int courseId) =>
      '$baseUrl/courses/$courseId/teams/auto-grouping';
  static String teamAnalytics(int teamId) => '$baseUrl/teams/$teamId/analytics';
  static String teamMemberContributions(int teamId) =>
      '$baseUrl/teams/$teamId/members/contributions';
  static String teamChatRoom(int teamId) => '$baseUrl/teams/$teamId/chat-room';
  static String chatMessages(int roomId) => '$baseUrl/chat-rooms/$roomId/messages';

  static String instructorDashboard(int courseId) =>
      '$baseUrl/dashboard/instructor/courses/$courseId';
  static String riskStudents(int courseId) =>
      '$baseUrl/instructors/courses/$courseId/students/risk';
  static String lowUnderstandingStudents(int courseId) =>
      '$baseUrl/instructors/courses/$courseId/students/understanding-low';
  static String interventions(int courseId) =>
      '$baseUrl/instructors/courses/$courseId/interventions';
}
