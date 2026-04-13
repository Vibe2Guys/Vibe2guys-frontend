import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_client.dart';
import 'api_contract.dart';
import 'mock_api_client.dart';

class HttpApiClient implements ApiClient {
  HttpApiClient({http.Client? client})
      : _client = client ?? http.Client(),
        _fallback = MockApiClient();

  static const bool _allowFallback = bool.fromEnvironment(
    'ALLOW_API_FALLBACK',
    defaultValue: false,
  );

  final http.Client _client;
  final MockApiClient _fallback;

  String? _accessToken;
  String? _refreshToken;
  AppUser? _currentUser;

  @override
  String? get accessToken => _accessToken;

  @override
  AppUser? get currentUser => _currentUser;

  String get _baseUrl {
    const raw = String.fromEnvironment('API_BASE_URL', defaultValue: '/api/v1');
    return raw.endsWith('/') ? raw.substring(0, raw.length - 1) : raw;
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    final response = await _post(
      '/auth/register',
      body: {
        'name': name,
        'email': email,
        'password': password,
        'role': role.apiValue,
      },
      withAuth: false,
    );
    return ApiResponse(
      success: response.success,
      message: response.message,
      data: _extractMap(response.data),
      errorCode: response.errorCode,
    );
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> login({
    required String email,
    required String password,
    required UserRole role,
  }) async {
    final response = await _post(
      '/auth/login',
      body: {'email': email, 'password': password},
      withAuth: false,
    );
    if (!response.success) {
      return ApiResponse(
        success: response.success,
        message: response.message,
        data: null,
        errorCode: response.errorCode,
      );
    }

    final data = response.data as Map<String, dynamic>? ?? {};
    final userMap = data['user'] as Map<String, dynamic>? ?? {};
    _accessToken = data['accessToken'] as String?;
    _refreshToken = data['refreshToken'] as String?;
    _currentUser = AppUser(
      userId: (userMap['userId'] as num?)?.toInt() ?? 0,
      name: (userMap['name'] as String?) ?? '',
      email: (userMap['email'] as String?) ?? email,
      role: UserRole.fromApi((userMap['role'] as String?) ?? role.apiValue),
      profileImageUrl: userMap['profileImageUrl'] as String?,
    );
    return ApiResponse(
      success: response.success,
      message: response.message,
      data: {
        'accessToken': _accessToken,
        'refreshToken': _refreshToken,
        'user': _currentUser,
      },
      errorCode: response.errorCode,
    );
  }

  @override
  Future<void> logout() async {
    if (_refreshToken != null && _accessToken != null) {
      try {
        await _post(
          '/auth/logout',
          body: {'refreshToken': _refreshToken},
          withAuth: true,
        );
      } catch (_) {
        // Ignore network/logout failures and clear the local session anyway.
      }
    }
    _accessToken = null;
    _refreshToken = null;
    _currentUser = null;
  }

  @override
  Future<ApiResponse<List<Map<String, dynamic>>>> getMyCourses() =>
      _getList('/courses/my');

  @override
  Future<ApiResponse<List<Map<String, dynamic>>>> getCourses(
      {String? keyword}) {
    final normalized = keyword?.trim() ?? '';
    final path = normalized.isEmpty
        ? '/courses'
        : '/courses?keyword=${Uri.encodeQueryComponent(normalized)}';
    return _getList(path);
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> createCourse({
    required String title,
    required String description,
    required String thumbnailUrl,
    required String startDate,
    required String endDate,
    required bool isSequentialRelease,
    required bool isPublic,
  }) {
    return _postMap(
      '/courses',
      body: {
        'title': title,
        'description': description,
        'thumbnailUrl': thumbnailUrl,
        'startDate': startDate,
        'endDate': endDate,
        'isSequentialRelease': isSequentialRelease,
        'isPublic': isPublic,
      },
    );
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> enrollCourse({
    required int courseId,
  }) {
    return _postMap('/courses/$courseId/enrollments', body: const {});
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> enrollCourseByCode({
    required String courseCode,
  }) {
    return _postMap(
      '/courses/enroll-by-code',
      body: {'courseCode': courseCode},
    );
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> getCourseDetail(int courseId) =>
      _getMap('/courses/$courseId');

  @override
  Future<ApiResponse<Map<String, dynamic>>> getCourseHome(int courseId) =>
      _getMap('/courses/$courseId/home');

  @override
  Future<ApiResponse<List<Map<String, dynamic>>>> getCourseAnnouncements(
          int courseId) =>
      _getList('/courses/$courseId/announcements');

  @override
  Future<ApiResponse<Map<String, dynamic>>> createCourseAnnouncement({
    required int courseId,
    required String title,
    required String body,
    required bool pinned,
  }) {
    return _postMap(
      '/courses/$courseId/announcements',
      body: {'title': title, 'body': body, 'pinned': pinned},
    );
  }

  @override
  Future<ApiResponse<List<Map<String, dynamic>>>> getMyLearningLogs(
          int courseId) =>
      _getList('/courses/$courseId/learning-logs/me');

  @override
  Future<ApiResponse<Map<String, dynamic>>> getMyCourseGradebook(
          int courseId) =>
      _getMap('/courses/$courseId/gradebook/me');

  @override
  Future<ApiResponse<List<Map<String, dynamic>>>> getCourseStudents(
          int courseId) =>
      _getList('/courses/$courseId/students');

  @override
  Future<ApiResponse<Map<String, dynamic>>> updateCourseStudentMemo({
    required int courseId,
    required int studentId,
    required String memo,
  }) {
    return _patchMap(
      '/courses/$courseId/students/$studentId/memo',
      body: {'memo': memo},
    );
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> createWeek({
    required int courseId,
    required int weekNumber,
    required String title,
    required String openAt,
  }) {
    return _postMap(
      '/courses/$courseId/weeks',
      body: {
        'weekNumber': weekNumber,
        'title': title,
        'openAt': openAt,
      },
    );
  }

  @override
  Future<ApiResponse<List<Map<String, dynamic>>>> getWeekContents(
          int courseId, int weekId) =>
      _getList('/courses/$courseId/weeks/$weekId/contents');

  @override
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
  }) {
    return _postMap(
      '/weeks/$weekId/contents',
      body: {
        'type': type,
        'title': title,
        'description': description,
        'videoUrl': videoUrl,
        'documentUrl': documentUrl,
        'durationSeconds': durationSeconds,
        'scheduledAt': scheduledAt,
        'openAt': openAt,
      },
    );
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> createVideoUploadUrl({
    required String fileName,
    required String contentType,
  }) {
    return _postMap(
      '/uploads/videos/presigned-url',
      body: {
        'fileName': fileName,
        'contentType': contentType,
      },
    );
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> createUploadUrl({
    required String fileName,
    required String contentType,
    required String category,
  }) {
    return _postMap(
      '/uploads/presigned-url',
      body: {
        'fileName': fileName,
        'contentType': contentType,
        'category': category,
      },
    );
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> getMyProfile() =>
      _getMap('/users/me');

  @override
  Future<ApiResponse<List<Map<String, dynamic>>>> getMyNotifications() =>
      _getList('/notifications/me');

  @override
  Future<ApiResponse<Map<String, dynamic>>> readNotification(
          int notificationId) =>
      _patchMap('/notifications/$notificationId/read', body: const {});

  @override
  Future<ApiResponse<Map<String, dynamic>>> updateMyProfile({
    required String name,
    required String profileImageUrl,
  }) async {
    final response = await _patchMap(
      '/users/me',
      body: {
        'name': name,
        'profileImageUrl': profileImageUrl,
      },
    );
    if (response.success && response.data != null && _currentUser != null) {
      final data = response.data!;
      _currentUser = AppUser(
        userId: (data['userId'] as num?)?.toInt() ?? _currentUser!.userId,
        name: (data['name'] as String?) ?? _currentUser!.name,
        email: (data['email'] as String?) ?? _currentUser!.email,
        role: UserRole.fromApi(
            (data['role'] as String?) ?? _currentUser!.role.apiValue),
        profileImageUrl: data['profileImageUrl'] as String?,
      );
    }
    return response;
  }

  @override
  Future<ApiResponse<List<Map<String, dynamic>>>> getCourseAssignments(
          int courseId) =>
      _getList('/courses/$courseId/assignments');

  @override
  Future<ApiResponse<Map<String, dynamic>>> createAssignment({
    required int courseId,
    required String title,
    required String description,
    required String type,
    required String dueAt,
    required int maxScore,
    required bool teamAssignment,
  }) {
    return _postMap(
      '/courses/$courseId/assignments',
      body: {
        'title': title,
        'description': description,
        'type': type,
        'dueAt': dueAt,
        'maxScore': maxScore,
        'teamAssignment': teamAssignment,
      },
    );
  }

  @override
  Future<ApiResponse<List<Map<String, dynamic>>>> getCourseQuizzes(
          int courseId) =>
      _getList('/courses/$courseId/quizzes');

  @override
  Future<ApiResponse<Map<String, dynamic>>> getContentDetail(int contentId) =>
      _getMap('/contents/$contentId');

  @override
  Future<ApiResponse<Map<String, dynamic>>> saveProgress({
    required int contentId,
    required int progressRate,
    required int watchedSeconds,
    required int totalSeconds,
  }) {
    return _postMap(
      '/contents/$contentId/progress',
      body: {
        'watchedSeconds': watchedSeconds,
        'totalSeconds': totalSeconds,
        'lastPositionSeconds': watchedSeconds,
        'replayCount': 0,
        'eventType': progressRate >= 100 ? 'ENDED' : 'PAUSE',
      },
    );
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> getAssignmentDetail(
          int assignmentId) =>
      _getMap('/assignments/$assignmentId');

  @override
  Future<ApiResponse<List<Map<String, dynamic>>>> getAssignmentSubmissions(
          int assignmentId) =>
      _getList('/assignments/$assignmentId/submissions');

  @override
  Future<ApiResponse<Map<String, dynamic>>> gradeAssignmentSubmission({
    required int assignmentId,
    required int submissionId,
    required int score,
    required String feedback,
  }) {
    return _patchMap(
      '/assignments/$assignmentId/submissions/$submissionId/grade',
      body: {'score': score, 'feedback': feedback},
    );
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> submitAssignment({
    required int assignmentId,
    required String answerText,
  }) {
    return _postMap(
      '/assignments/$assignmentId/submissions',
      body: {'answerText': answerText},
    );
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> getStudentDashboard() =>
      _getMap('/dashboard/student');

  @override
  Future<ApiResponse<Map<String, dynamic>>> getMyReport() =>
      _getMap('/reports/me');

  @override
  Future<ApiResponse<Map<String, dynamic>>> getRecommendations(
      int studentId) async {
    final response = await _get('/students/$studentId/recommendations');
    final data = _extractMap(response.data);
    return ApiResponse(
      success: response.success,
      message: response.message,
      data: {
        'recommendedActions': _extractStringList(data['recommendations']),
      },
      errorCode: response.errorCode,
    );
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> getMyTeam() async {
    final response = await _get('/teams/me');
    final teams = _extractList(response.data);
    final first = teams.isEmpty ? <String, dynamic>{} : teams.first;
    return ApiResponse(
      success: response.success,
      message: response.message,
      data: {
        'teamId': first['teamId'],
        'teamName': first['name'],
        'memberCount': first['memberCount'],
        'status': first['status'],
      },
      errorCode: response.errorCode,
    );
  }

  @override
  Future<ApiResponse<List<Map<String, dynamic>>>> getTeamTasks(int teamId) =>
      _getList('/teams/$teamId/tasks');

  @override
  Future<ApiResponse<Map<String, dynamic>>> createTeamTask({
    required int teamId,
    required String title,
    required String description,
    int? assigneeUserId,
    String? dueAt,
  }) {
    return _postMap(
      '/teams/$teamId/tasks',
      body: {
        'title': title,
        'description': description,
        'assigneeUserId': assigneeUserId,
        'dueAt': dueAt,
      },
    );
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> updateTeamTaskStatus({
    required int teamId,
    required int taskId,
    required String status,
  }) {
    return _patchMap(
      '/teams/$teamId/tasks/$taskId/status',
      body: {'status': status},
    );
  }

  @override
  Future<ApiResponse<List<Map<String, dynamic>>>> getTeamMeetingNotes(
          int teamId) =>
      _getList('/teams/$teamId/meeting-notes');

  @override
  Future<ApiResponse<Map<String, dynamic>>> createTeamMeetingNote({
    required int teamId,
    required String title,
    required String noteBody,
  }) {
    return _postMap(
      '/teams/$teamId/meeting-notes',
      body: {'title': title, 'noteBody': noteBody},
    );
  }

  @override
  Future<ApiResponse<List<Map<String, dynamic>>>> getCourseTeams(
          int courseId) =>
      _getList('/courses/$courseId/teams');

  @override
  Future<ApiResponse<Map<String, dynamic>>> autoGroupTeams({
    required int courseId,
    required int teamSize,
  }) {
    return _postMap(
      '/courses/$courseId/teams/auto-grouping',
      body: {'teamSize': teamSize},
    );
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> getTeamDetail(int teamId) async {
    final response = await _get('/teams/$teamId');
    final data = _extractMap(response.data);
    return ApiResponse(
      success: response.success,
      message: response.message,
      data: {
        ...data,
        'teamName': data['name'],
      },
      errorCode: response.errorCode,
    );
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> getTeamAnalytics(int teamId) =>
      _getMap('/teams/$teamId/analytics');

  @override
  Future<ApiResponse<List<Map<String, dynamic>>>> getTeamMemberContributions(
          int teamId) =>
      _getList('/teams/$teamId/members/contributions');

  @override
  Future<ApiResponse<Map<String, dynamic>>> getTeamChatRoom(int teamId) =>
      _getMap('/teams/$teamId/chat-room');

  @override
  Future<ApiResponse<List<Map<String, dynamic>>>> getChatMessages(
      int chatRoomId) async {
    final response = await _get('/chat-rooms/$chatRoomId/messages');
    final data = _extractList(response.data)
        .map(
          (item) => {
            ...item,
            'message': item['messageBody'],
          },
        )
        .toList();
    return ApiResponse(
      success: response.success,
      message: response.message,
      data: data,
      errorCode: response.errorCode,
    );
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> getInstructorDashboard(
          int courseId) =>
      _getMap('/dashboard/instructor/courses/$courseId');

  @override
  Future<ApiResponse<Map<String, dynamic>>> getInstructorGradebook(
          int courseId) =>
      _getMap('/courses/$courseId/gradebook/instructor');

  @override
  Future<ApiResponse<List<Map<String, dynamic>>>> getRiskStudents(
          int courseId) =>
      _getList('/instructors/courses/$courseId/students/risk');

  @override
  Future<ApiResponse<List<Map<String, dynamic>>>> getLowUnderstandingStudents(
    int courseId,
  ) =>
      _getList('/instructors/courses/$courseId/students/understanding-low');

  @override
  Future<ApiResponse<List<Map<String, dynamic>>>> getInterventions(
      int courseId) async {
    final response = await _get('/instructors/courses/$courseId/interventions');
    final data = _extractList(response.data)
        .map(
          (item) => {
            ...item,
            'recommendedAction': item['title'] ?? item['message'],
          },
        )
        .toList();
    return ApiResponse(
      success: response.success,
      message: response.message,
      data: data,
      errorCode: response.errorCode,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> _getMap(String path) async {
    final response = await _get(path);
    final data = _extractMap(response.data);
    if (path == '/reports/me') {
      final dashboard = _extractMap(data['dashboard']);
      return ApiResponse(
        success: response.success,
        message: response.message,
        data: {
          'weeklySummary': dashboard['coachingMessage'] ?? response.message,
          'todayTodos': _extractStringList(dashboard['todayTodos']),
          'riskLevel': dashboard['riskLevel'],
        },
        errorCode: response.errorCode,
      );
    }
    return ApiResponse(
      success: response.success,
      message: response.message,
      data: data,
      errorCode: response.errorCode,
    );
  }

  Future<ApiResponse<List<Map<String, dynamic>>>> _getList(String path) async {
    final response = await _get(path);
    return ApiResponse(
      success: response.success,
      message: response.message,
      data: _extractList(response.data),
      errorCode: response.errorCode,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> _postMap(
    String path, {
    required Map<String, dynamic> body,
  }) async {
    final response = await _post(path, body: body);
    return ApiResponse(
      success: response.success,
      message: response.message,
      data: _extractMap(response.data),
      errorCode: response.errorCode,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> _patchMap(
    String path, {
    required Map<String, dynamic> body,
  }) async {
    final response = await _patch(path, body: body);
    return ApiResponse(
      success: response.success,
      message: response.message,
      data: _extractMap(response.data),
      errorCode: response.errorCode,
    );
  }

  Future<ApiResponse<dynamic>> _get(String path) async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl$path'),
        headers: _headers(withAuth: true),
      );
      return _parse(response);
    } catch (_) {
      if (!_allowFallback) {
        return const ApiResponse(
          success: false,
          message: 'Network error',
          errorCode: 'NETWORK_ERROR',
        );
      }
      return _fallbackFor(path);
    }
  }

  Future<ApiResponse<dynamic>> _post(
    String path, {
    required Map<String, dynamic> body,
    bool withAuth = true,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('$_baseUrl$path'),
        headers: _headers(withAuth: withAuth),
        body: jsonEncode(body),
      );
      return _parse(response);
    } catch (_) {
      if (!_allowFallback) {
        return const ApiResponse(
          success: false,
          message: 'Network error',
          errorCode: 'NETWORK_ERROR',
        );
      }
      return _fallbackFor(path, body: body);
    }
  }

  Future<ApiResponse<dynamic>> _patch(
    String path, {
    required Map<String, dynamic> body,
  }) async {
    try {
      final response = await _client.patch(
        Uri.parse('$_baseUrl$path'),
        headers: _headers(withAuth: true),
        body: jsonEncode(body),
      );
      return _parse(response);
    } catch (_) {
      if (!_allowFallback) {
        return const ApiResponse(
          success: false,
          message: 'Network error',
          errorCode: 'NETWORK_ERROR',
        );
      }
      return _fallbackFor(path, body: body);
    }
  }

  Map<String, String> _headers({required bool withAuth}) {
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (withAuth && _accessToken != null) {
      headers['Authorization'] = 'Bearer $_accessToken';
    }
    return headers;
  }

  ApiResponse<dynamic> _parse(http.Response response) {
    dynamic decoded;
    try {
      decoded = jsonDecode(response.body);
    } catch (_) {
      return ApiResponse(
        success: false,
        message: 'Invalid JSON response (${response.statusCode})',
        errorCode: 'INVALID_JSON',
      );
    }
    if (decoded is! Map<String, dynamic>) {
      return const ApiResponse(
        success: false,
        message: 'Invalid API response format',
        errorCode: 'INVALID_RESPONSE',
      );
    }
    return ApiResponse(
      success: decoded['success'] == true,
      message: (decoded['message'] as String?) ?? 'No message',
      data: decoded['data'],
      errorCode: (decoded['errorCode'] as String?) ??
          _statusErrorCode(response.statusCode),
    );
  }

  String? _statusErrorCode(int statusCode) {
    if (statusCode >= 200 && statusCode < 300) return null;
    if (statusCode == 401) return 'UNAUTHORIZED';
    if (statusCode == 403) return 'FORBIDDEN';
    if (statusCode == 404) return 'NOT_FOUND';
    if (statusCode >= 500) return 'SERVER_ERROR';
    return 'REQUEST_FAILED';
  }

  Map<String, dynamic> _extractMap(dynamic raw) {
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) {
      return Map<String, dynamic>.from(raw.map((k, v) => MapEntry('$k', v)));
    }
    return <String, dynamic>{};
  }

  List<Map<String, dynamic>> _extractList(dynamic raw) {
    if (raw is List) return _castList(raw);
    final map = _extractMap(raw);
    final content = map['content'];
    if (content is List) return _castList(content);
    final messages = map['messages'];
    if (messages is List) return _castList(messages);
    return <Map<String, dynamic>>[];
  }

  List<Map<String, dynamic>> _castList(List<dynamic> values) {
    return values
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  List<String> _extractStringList(dynamic raw) {
    if (raw is List) {
      return raw.map((value) => '$value').toList();
    }
    return const <String>[];
  }

  Future<ApiResponse<dynamic>> _fallbackFor(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    if (path == '/courses/my') return _fallback.getMyCourses();
    if (path == '/courses') return _fallback.getCourses();
    if (path.startsWith('/courses?')) {
      final uri = Uri.parse('http://localhost$path');
      return _fallback.getCourses(keyword: uri.queryParameters['keyword']);
    }
    if (path == '/courses/enroll-by-code') {
      return _fallback.enrollCourseByCode(
        courseCode: (body?['courseCode'] as String?) ?? '',
      );
    }
    if (path.startsWith('/courses/') && path.endsWith('/assignments')) {
      if (body != null) {
        return _fallback.createAssignment(
          courseId: _extractId(path),
          title: (body['title'] as String?) ?? '',
          description: (body['description'] as String?) ?? '',
          type: (body['type'] as String?) ?? 'SUBJECTIVE',
          dueAt: (body['dueAt'] as String?) ?? '',
          maxScore: (body['maxScore'] as num?)?.toInt() ?? 100,
          teamAssignment: body['teamAssignment'] == true,
        );
      }
      return _fallback.getCourseAssignments(_extractId(path));
    }
    if (path.startsWith('/courses/') && path.endsWith('/learning-logs/me')) {
      return _fallback.getMyLearningLogs(_extractId(path));
    }
    if (path.startsWith('/courses/') && path.endsWith('/quizzes')) {
      return _fallback.getCourseQuizzes(_extractId(path));
    }
    if (path.startsWith('/courses/') && path.endsWith('/enrollments')) {
      return _fallback.enrollCourse(courseId: _extractId(path));
    }
    if (path.startsWith('/courses/') && path.endsWith('/students')) {
      return _fallback.getCourseStudents(_extractId(path));
    }
    if (path.startsWith('/courses/') && path.endsWith('/home')) {
      return _fallback.getCourseHome(_extractId(path));
    }
    if (path.startsWith('/courses/') && path.endsWith('/announcements')) {
      if (body != null) {
        return _fallback.createCourseAnnouncement(
          courseId: _extractId(path),
          title: (body['title'] as String?) ?? '',
          body: (body['body'] as String?) ?? '',
          pinned: body['pinned'] == true,
        );
      }
      return _fallback.getCourseAnnouncements(_extractId(path));
    }
    if (path.startsWith('/courses/') && path.endsWith('/gradebook/me')) {
      return _fallback.getMyCourseGradebook(_extractId(path));
    }
    if (path.startsWith('/courses/') &&
        path.endsWith('/gradebook/instructor')) {
      return _fallback.getInstructorGradebook(_extractId(path));
    }
    if (RegExp(r'^/courses/\d+/students/\d+/memo$').hasMatch(path)) {
      final ids = RegExp(r'(\d+)')
          .allMatches(path)
          .map((match) => int.parse(match.group(1)!))
          .toList();
      return _fallback.updateCourseStudentMemo(
        courseId: ids.isNotEmpty ? ids[0] : 0,
        studentId: ids.length > 1 ? ids[1] : 0,
        memo: (body?['memo'] as String?) ?? '',
      );
    }
    if (path.startsWith('/courses/')) {
      return _fallback.getCourseDetail(_extractId(path));
    }
    if (path.startsWith('/contents/') && path.endsWith('/progress')) {
      final watchedSeconds =
          (body?['lastPositionSeconds'] as num?)?.toInt() ?? 0;
      final totalSeconds = (body?['totalSeconds'] as num?)?.toInt() ?? 1;
      return _fallback.saveProgress(
        contentId: _extractId(path),
        progressRate:
            totalSeconds <= 0 ? 0 : (watchedSeconds * 100 ~/ totalSeconds),
        watchedSeconds: watchedSeconds,
        totalSeconds: totalSeconds,
      );
    }
    if (path.startsWith('/contents/')) {
      return _fallback.getContentDetail(_extractId(path));
    }
    if (RegExp(r'^/assignments/\d+/submissions/\d+/grade$').hasMatch(path)) {
      final ids = RegExp(r'(\d+)')
          .allMatches(path)
          .map((match) => int.parse(match.group(1)!))
          .toList();
      return _fallback.gradeAssignmentSubmission(
        assignmentId: ids.isNotEmpty ? ids[0] : 0,
        submissionId: ids.length > 1 ? ids[1] : 0,
        score: (body?['score'] as num?)?.toInt() ?? 0,
        feedback: (body?['feedback'] as String?) ?? '',
      );
    }
    if (path.startsWith('/assignments/') && path.endsWith('/submissions')) {
      if (body == null) {
        return _fallback.getAssignmentSubmissions(_extractId(path));
      }
      return _fallback.submitAssignment(
        assignmentId: _extractId(path),
        answerText: (body['answerText'] as String?) ?? '',
      );
    }
    if (path.startsWith('/assignments/')) {
      return _fallback.getAssignmentDetail(_extractId(path));
    }
    if (path == '/dashboard/student') return _fallback.getStudentDashboard();
    if (path == '/reports/me') return _fallback.getMyReport();
    if (path == '/notifications/me') return _fallback.getMyNotifications();
    if (RegExp(r'^/notifications/\d+/read$').hasMatch(path)) {
      return _fallback.readNotification(_extractId(path));
    }
    if (path == '/users/me' && body == null) return _fallback.getMyProfile();
    if (path == '/users/me' && body != null) {
      return _fallback.updateMyProfile(
        name: (body['name'] as String?) ?? '',
        profileImageUrl: (body['profileImageUrl'] as String?) ?? '',
      );
    }
    if (path == '/teams/me') return _fallback.getMyTeam();
    if (path.startsWith('/teams/') && path.endsWith('/tasks')) {
      if (body != null) {
        return _fallback.createTeamTask(
          teamId: _extractId(path),
          title: (body['title'] as String?) ?? '',
          description: (body['description'] as String?) ?? '',
          assigneeUserId: (body['assigneeUserId'] as num?)?.toInt(),
          dueAt: body['dueAt'] as String?,
        );
      }
      return _fallback.getTeamTasks(_extractId(path));
    }
    if (RegExp(r'^/teams/\d+/tasks/\d+/status$').hasMatch(path)) {
      final ids = RegExp(r'(\d+)')
          .allMatches(path)
          .map((match) => int.parse(match.group(1)!))
          .toList();
      return _fallback.updateTeamTaskStatus(
        teamId: ids.isNotEmpty ? ids[0] : 0,
        taskId: ids.length > 1 ? ids[1] : 0,
        status: (body?['status'] as String?) ?? 'TODO',
      );
    }
    if (path.startsWith('/teams/') && path.endsWith('/meeting-notes')) {
      if (body != null) {
        return _fallback.createTeamMeetingNote(
          teamId: _extractId(path),
          title: (body['title'] as String?) ?? '',
          noteBody: (body['noteBody'] as String?) ?? '',
        );
      }
      return _fallback.getTeamMeetingNotes(_extractId(path));
    }
    if (RegExp(r'^/chat-rooms/\d+/messages$').hasMatch(path)) {
      return _fallback.getChatMessages(_extractId(path));
    }
    if (path.startsWith('/teams/') && path.endsWith('/chat-room')) {
      return _fallback.getTeamChatRoom(_extractId(path));
    }
    if (path.startsWith('/teams/')) {
      return _fallback.getTeamDetail(_extractId(path));
    }
    if (path.startsWith('/dashboard/instructor/courses/')) {
      return _fallback.getInstructorDashboard(_extractId(path));
    }
    if (path.startsWith('/instructors/courses/') &&
        path.endsWith('/students/risk')) {
      return _fallback.getRiskStudents(_extractId(path));
    }
    if (path.startsWith('/instructors/courses/') &&
        path.endsWith('/students/understanding-low')) {
      return _fallback.getLowUnderstandingStudents(_extractId(path));
    }
    if (path.startsWith('/instructors/courses/') &&
        path.endsWith('/interventions')) {
      return _fallback.getInterventions(_extractId(path));
    }
    if (path.startsWith('/students/') && path.endsWith('/recommendations')) {
      return _fallback.getRecommendations(_extractId(path));
    }
    return const ApiResponse(
      success: false,
      message: 'Network error and no mock fallback for endpoint',
      errorCode: 'NETWORK_ERROR',
    );
  }

  int _extractId(String path) {
    final matches = RegExp(r'(\d+)').allMatches(path);
    if (matches.isEmpty) return 0;
    return int.parse(matches.first.group(1)!);
  }
}
