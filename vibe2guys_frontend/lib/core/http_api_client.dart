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
  Future<ApiResponse<Map<String, dynamic>>> getCourseDetail(int courseId) =>
      _getMap('/courses/$courseId');

  @override
  Future<ApiResponse<List<Map<String, dynamic>>>> getCourseAssignments(int courseId) =>
      _getList('/courses/$courseId/assignments');

  @override
  Future<ApiResponse<List<Map<String, dynamic>>>> getCourseQuizzes(int courseId) =>
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
  Future<ApiResponse<Map<String, dynamic>>> getAssignmentDetail(int assignmentId) =>
      _getMap('/assignments/$assignmentId');

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
  Future<ApiResponse<Map<String, dynamic>>> getMyReport() => _getMap('/reports/me');

  @override
  Future<ApiResponse<Map<String, dynamic>>> getRecommendations(int studentId) async {
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
  Future<ApiResponse<Map<String, dynamic>>> getTeamChatRoom(int teamId) =>
      _getMap('/teams/$teamId/chat-room');

  @override
  Future<ApiResponse<List<Map<String, dynamic>>>> getChatMessages(int chatRoomId) async {
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
  Future<ApiResponse<Map<String, dynamic>>> getInstructorDashboard(int courseId) =>
      _getMap('/dashboard/instructor/courses/$courseId');

  @override
  Future<ApiResponse<List<Map<String, dynamic>>>> getRiskStudents(int courseId) =>
      _getList('/instructors/courses/$courseId/students/risk');

  @override
  Future<ApiResponse<List<Map<String, dynamic>>>> getLowUnderstandingStudents(
    int courseId,
  ) =>
      _getList('/instructors/courses/$courseId/students/understanding-low');

  @override
  Future<ApiResponse<List<Map<String, dynamic>>>> getInterventions(int courseId) async {
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
      errorCode: (decoded['errorCode'] as String?) ?? _statusErrorCode(response.statusCode),
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
    if (path.startsWith('/courses/') && path.endsWith('/assignments')) {
      return _fallback.getCourseAssignments(_extractId(path));
    }
    if (path.startsWith('/courses/') && path.endsWith('/quizzes')) {
      return _fallback.getCourseQuizzes(_extractId(path));
    }
    if (path.startsWith('/courses/')) return _fallback.getCourseDetail(_extractId(path));
    if (path.startsWith('/contents/') && path.endsWith('/progress')) {
      final watchedSeconds = (body?['lastPositionSeconds'] as num?)?.toInt() ?? 0;
      final totalSeconds = (body?['totalSeconds'] as num?)?.toInt() ?? 1;
      return _fallback.saveProgress(
        contentId: _extractId(path),
        progressRate: totalSeconds <= 0 ? 0 : (watchedSeconds * 100 ~/ totalSeconds),
        watchedSeconds: watchedSeconds,
        totalSeconds: totalSeconds,
      );
    }
    if (path.startsWith('/contents/')) return _fallback.getContentDetail(_extractId(path));
    if (path.startsWith('/assignments/') && path.endsWith('/submissions')) {
      return _fallback.submitAssignment(
        assignmentId: _extractId(path),
        answerText: (body?['answerText'] as String?) ?? '',
      );
    }
    if (path.startsWith('/assignments/')) return _fallback.getAssignmentDetail(_extractId(path));
    if (path == '/dashboard/student') return _fallback.getStudentDashboard();
    if (path == '/reports/me') return _fallback.getMyReport();
    if (path == '/teams/me') return _fallback.getMyTeam();
    if (path == '/chat-rooms/4001/messages') return _fallback.getChatMessages(4001);
    if (path.startsWith('/teams/') && path.endsWith('/chat-room')) {
      return _fallback.getTeamChatRoom(_extractId(path));
    }
    if (path.startsWith('/teams/')) return _fallback.getTeamDetail(_extractId(path));
    if (path == '/dashboard/instructor/courses/101') {
      return _fallback.getInstructorDashboard(101);
    }
    if (path == '/instructors/courses/101/students/risk') return _fallback.getRiskStudents(101);
    if (path == '/instructors/courses/101/students/understanding-low') {
      return _fallback.getLowUnderstandingStudents(101);
    }
    if (path == '/instructors/courses/101/interventions') {
      return _fallback.getInterventions(101);
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
