import 'dart:async';

import 'api_client.dart';
import 'api_contract.dart';

class MockApiClient implements ApiClient {
  String? _accessToken;
  AppUser? _currentUser;

  @override
  String? get accessToken => _accessToken;
  @override
  AppUser? get currentUser => _currentUser;

  @override
  Future<ApiResponse<Map<String, dynamic>>> register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    if (name.trim().isEmpty ||
        email.trim().isEmpty ||
        password.trim().length < 8) {
      return const ApiResponse(
        success: false,
        message: '이름, 이메일, 비밀번호를 올바르게 입력해주세요.',
        errorCode: 'INVALID_INPUT',
      );
    }
    return ApiResponse(
      success: true,
      message: '회원가입 완료',
      data: {
        'userId': 1,
        'name': name.trim(),
        'email': email.trim(),
        'role': role.apiValue,
      },
    );
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> login({
    required String email,
    required String password,
    required UserRole role,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    if (email.isEmpty || password.isEmpty) {
      return const ApiResponse(
        success: false,
        message: '이메일/비밀번호를 입력해주세요.',
        errorCode: 'INVALID_CREDENTIALS',
      );
    }

    _currentUser = AppUser(
      userId: role == UserRole.student ? 1 : 20,
      name: role == UserRole.student ? '홍길동' : '김교수',
      email: email,
      role: role,
      profileImageUrl: role == UserRole.student
          ? 'https://cdn.example.com/profile/student-1.png'
          : 'https://cdn.example.com/profile/instructor-20.png',
    );
    _accessToken = 'mock-jwt-token-${DateTime.now().millisecondsSinceEpoch}';
    return ApiResponse(
      success: true,
      message: '로그인 성공',
      data: {
        'accessToken': _accessToken,
        'user': _currentUser,
      },
    );
  }

  @override
  Future<void> logout() async {
    _accessToken = null;
    _currentUser = null;
  }

  @override
  Future<ApiResponse<List<Map<String, dynamic>>>> getMyCourses() async {
    final unauthorized = _unauthorized<List<Map<String, dynamic>>>();
    if (unauthorized != null) return unauthorized;
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return const ApiResponse(
      success: true,
      message: '내 강의 목록 조회 성공',
      data: [
        {
          'courseId': 101,
          'title': 'AI 기초',
          'description': 'AI 개론 수업',
          'thumbnailUrl': 'https://images.example.com/course-101',
          'instructorName': '김교수',
          'courseCode': 'CRS-AI000101',
          'isPublic': true,
          'progressRate': 72,
          'attendanceRate': 85,
          'assignmentPendingCount': 2,
        },
        {
          'courseId': 102,
          'title': '데이터 사고법',
          'description': '문제 해결을 위한 데이터 사고 훈련',
          'thumbnailUrl': 'https://images.example.com/course-102',
          'instructorName': '이교수',
          'courseCode': 'CRS-DT000102',
          'isPublic': false,
          'progressRate': 41,
          'attendanceRate': 66,
          'assignmentPendingCount': 1,
        },
      ],
    );
  }

  @override
  Future<ApiResponse<List<Map<String, dynamic>>>> getCourses(
      {String? keyword}) async {
    final unauthorized = _unauthorized<List<Map<String, dynamic>>>();
    if (unauthorized != null) return unauthorized;
    await Future<void>.delayed(const Duration(milliseconds: 180));
    final normalized = (keyword ?? '').trim().toLowerCase();
    const courses = [
      {
        'courseId': 301,
        'title': '생성형 AI 입문',
        'description': '생성형 AI의 개념과 활용 사례를 다룹니다.',
        'thumbnailUrl': 'https://images.example.com/course-301',
        'instructorName': '김교수',
        'courseCode': 'CRS-A1B2C3D4',
        'isPublic': true,
        'isEnrolled': false,
      },
      {
        'courseId': 302,
        'title': '데이터 사고법',
        'description': '데이터로 문제를 정의하고 해결하는 방법을 배웁니다.',
        'thumbnailUrl': 'https://images.example.com/course-302',
        'instructorName': '이교수',
        'courseCode': 'CRS-E5F6G7H8',
        'isPublic': true,
        'isEnrolled': false,
      },
    ];
    final filtered = normalized.isEmpty
        ? courses
        : courses
            .where((course) =>
                '${course['title']}'.toLowerCase().contains(normalized))
            .toList();
    return ApiResponse(
      success: true,
      message: '강의 목록 조회 성공',
      data: filtered,
    );
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
  }) async {
    final unauthorized = _unauthorized<Map<String, dynamic>>();
    if (unauthorized != null) return unauthorized;
    await Future<void>.delayed(const Duration(milliseconds: 220));
    return ApiResponse(
      success: true,
      message: '강의 생성 완료',
      data: {
        'courseId': 201,
        'title': title,
        'courseCode': 'CRS-Z9Y8X7W6',
        'isPublic': isPublic,
      },
    );
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> enrollCourse({
    required int courseId,
  }) async {
    final unauthorized = _unauthorized<Map<String, dynamic>>();
    if (unauthorized != null) return unauthorized;
    await Future<void>.delayed(const Duration(milliseconds: 160));
    return ApiResponse(
      success: true,
      message: '수강 신청 완료',
      data: {
        'courseId': courseId,
        'userId': _currentUser!.userId,
        'status': 'ENROLLED'
      },
    );
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> enrollCourseByCode({
    required String courseCode,
  }) async {
    final unauthorized = _unauthorized<Map<String, dynamic>>();
    if (unauthorized != null) return unauthorized;
    await Future<void>.delayed(const Duration(milliseconds: 160));
    if (courseCode.trim().isEmpty) {
      return const ApiResponse(
        success: false,
        message: '강의 코드를 입력해주세요.',
        errorCode: 'INVALID_INPUT',
      );
    }
    return ApiResponse(
      success: true,
      message: '강의 코드 등록 완료',
      data: {
        'courseId': 303,
        'userId': _currentUser!.userId,
        'status': 'ENROLLED'
      },
    );
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> getCourseDetail(
      int courseId) async {
    final unauthorized = _unauthorized<Map<String, dynamic>>();
    if (unauthorized != null) return unauthorized;
    await Future<void>.delayed(const Duration(milliseconds: 180));
    return ApiResponse(
      success: true,
      message: '강의 상세 조회 성공',
      data: {
        'courseId': courseId,
        'title': 'AI 기초',
        'description': 'AI 개론 수업입니다.',
        'courseCode': 'CRS-AI000101',
        'isPublic': true,
        'instructor': {'userId': 20, 'name': '김교수'},
        'startDate': '2026-04-10',
        'endDate': '2026-06-30',
        'weeks': [
          {
            'weekId': 1001,
            'weekNumber': 1,
            'title': 'AI란 무엇인가',
            'isOpened': true
          },
          {
            'weekId': 1002,
            'weekNumber': 2,
            'title': '지도학습 기초',
            'isOpened': true
          },
          {
            'weekId': 1003,
            'weekNumber': 3,
            'title': '과적합과 일반화',
            'isOpened': false
          },
        ],
      },
    );
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> getCourseHome(int courseId) async {
    final unauthorized = _unauthorized<Map<String, dynamic>>();
    if (unauthorized != null) return unauthorized;
    await Future<void>.delayed(const Duration(milliseconds: 180));
    return const ApiResponse(
      success: true,
      message: '강의 홈 조회 성공',
      data: {
        'courseId': 101,
        'title': 'AI 기초',
        'description': 'AI 개론 수업입니다.',
        'courseCode': 'CRS-AI000101',
        'isPublic': true,
        'instructorName': '김교수',
        'progressRate': 72,
        'attendanceRate': 85,
        'pendingTaskCount': 3,
        'recentLearningTitle': '2주차 강의 영상',
        'recentLearningAt': '2026-04-12T10:30:00+09:00',
        'announcements': [
          {
            'announcementId': 1,
            'title': '중간 프로젝트 안내',
            'body': '이번 주 안에 팀별 주제를 확정해 주세요.',
            'pinned': true,
            'createdByName': '김교수',
            'createdAt': '2026-04-11T09:00:00+09:00',
          },
          {
            'announcementId': 2,
            'title': '2주차 보강 자료 업로드',
            'body': '개념 정리 PDF를 강의 자료에 추가했습니다.',
            'pinned': false,
            'createdByName': '김교수',
            'createdAt': '2026-04-10T18:20:00+09:00',
          },
        ],
        'todos': [
          {
            'category': 'ASSIGNMENT',
            'referenceId': 7001,
            'title': '1주차 요약 과제',
            'status': '제출 필요',
            'scheduleAt': '2026-04-15T23:59:59+09:00',
            'summary': '과제',
          },
          {
            'category': 'QUIZ',
            'referenceId': 6001,
            'title': '1주차 퀴즈',
            'status': '응시 필요',
            'scheduleAt': '2026-04-16T23:59:59+09:00',
            'summary': '퀴즈',
          },
          {
            'category': 'CONTENT',
            'referenceId': 5004,
            'title': '3주차 강의 영상',
            'status': '예정',
            'scheduleAt': '2026-04-18T09:00:00+09:00',
            'summary': '콘텐츠 오픈 예정',
          },
        ],
        'weeks': [
          {
            'weekId': 1001,
            'weekNumber': 1,
            'title': 'AI란 무엇인가',
            'isOpened': true
          },
          {
            'weekId': 1002,
            'weekNumber': 2,
            'title': '지도학습 기초',
            'isOpened': true
          },
        ],
      },
    );
  }

  @override
  Future<ApiResponse<List<Map<String, dynamic>>>> getCourseAnnouncements(
      int courseId) async {
    final response = await getCourseHome(courseId);
    return ApiResponse(
      success: response.success,
      message: '강의 공지 조회 성공',
      data: ((response.data?['announcements'] as List<dynamic>?) ?? const [])
          .whereType<Map<String, dynamic>>()
          .toList(),
      errorCode: response.errorCode,
    );
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> createCourseAnnouncement({
    required int courseId,
    required String title,
    required String body,
    required bool pinned,
  }) async {
    final unauthorized = _unauthorized<Map<String, dynamic>>();
    if (unauthorized != null) return unauthorized;
    await Future<void>.delayed(const Duration(milliseconds: 140));
    return ApiResponse(
      success: true,
      message: '강의 공지 등록 완료',
      data: {
        'announcementId': 99,
        'title': title,
        'body': body,
        'pinned': pinned,
        'createdByName': _currentUser?.name ?? '김교수',
        'createdAt': DateTime.now().toIso8601String(),
      },
    );
  }

  @override
  Future<ApiResponse<List<Map<String, dynamic>>>> getMyLearningLogs(
      int courseId) async {
    final unauthorized = _unauthorized<List<Map<String, dynamic>>>();
    if (unauthorized != null) return unauthorized;
    await Future<void>.delayed(const Duration(milliseconds: 180));
    return const ApiResponse(
      success: true,
      message: '내 학습 로그 조회 성공',
      data: [
        {
          'contentId': 5001,
          'title': '1주차 강의 영상',
          'type': 'VOD',
          'progressRate': 78,
          'isCompleted': false,
          'attendanceStatus': 'ATTENDED',
          'attendanceMinutes': 42,
        },
        {
          'contentId': 5002,
          'title': '1주차 교안',
          'type': 'DOCUMENT',
          'progressRate': 100,
          'isCompleted': true,
          'attendanceStatus': null,
          'attendanceMinutes': null,
        },
        {
          'contentId': 5003,
          'title': '2주차 강의 영상',
          'type': 'VOD',
          'progressRate': 34,
          'isCompleted': false,
          'attendanceStatus': 'LATE',
          'attendanceMinutes': 18,
        },
      ],
    );
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> getMyCourseGradebook(
      int courseId) async {
    final unauthorized = _unauthorized<Map<String, dynamic>>();
    if (unauthorized != null) return unauthorized;
    await Future<void>.delayed(const Duration(milliseconds: 180));
    return const ApiResponse(
      success: true,
      message: '내 성적 조회 성공',
      data: {
        'courseId': 101,
        'courseTitle': 'AI 기초',
        'attendanceRate': 85,
        'progressRate': 72,
        'assignmentAverage': 88,
        'quizAverage': 76,
        'overallScore': 82,
        'assignments': [
          {
            'category': 'ASSIGNMENT',
            'referenceId': 7001,
            'title': '1주차 요약 과제',
            'earnedScore': 92,
            'maxScore': 100,
            'percentScore': 92,
            'status': '채점 완료',
            'feedback': '핵심 개념 정리가 명확합니다.',
            'submittedAt': '2026-04-14T21:00:00+09:00',
            'dueAt': '2026-04-15T23:59:59+09:00',
          },
          {
            'category': 'ASSIGNMENT',
            'referenceId': 7002,
            'title': '2주차 개념 비교',
            'earnedScore': 0,
            'maxScore': 100,
            'percentScore': 0,
            'status': '채점 대기',
            'feedback': null,
            'submittedAt': '2026-04-20T22:00:00+09:00',
            'dueAt': '2026-04-22T23:59:59+09:00',
          },
        ],
        'quizzes': [
          {
            'category': 'QUIZ',
            'referenceId': 6001,
            'title': '1주차 퀴즈',
            'earnedScore': 16,
            'maxScore': 20,
            'percentScore': 80,
            'status': '채점 완료',
            'feedback': null,
            'submittedAt': '2026-04-16T20:10:00+09:00',
            'dueAt': '2026-04-16T23:59:59+09:00',
          },
        ],
      },
    );
  }

  @override
  Future<ApiResponse<List<Map<String, dynamic>>>> getCourseStudents(
      int courseId) async {
    final unauthorized = _unauthorized<List<Map<String, dynamic>>>();
    if (unauthorized != null) return unauthorized;
    await Future<void>.delayed(const Duration(milliseconds: 180));
    return const ApiResponse(
      success: true,
      message: '수강생 목록 조회 성공',
      data: [
        {
          'userId': 1,
          'name': '홍길동',
          'email': 'hong@student.com',
          'status': 'ENROLLED',
          'progressRate': 88,
          'attendanceRate': 92,
          'understandingScore': 84,
          'riskLevel': 'LOW',
          'statusSummary': '안정',
          'memo': '발표 참여가 좋음',
        },
        {
          'userId': 2,
          'name': '김학생',
          'email': 'kim@student.com',
          'status': 'ENROLLED',
          'progressRate': 61,
          'attendanceRate': 70,
          'understandingScore': 58,
          'riskLevel': 'MEDIUM',
          'statusSummary': '관찰 필요',
          'memo': '',
        },
        {
          'userId': 3,
          'name': '박학생',
          'email': 'park@student.com',
          'status': 'ENROLLED',
          'progressRate': 39,
          'attendanceRate': 44,
          'understandingScore': 41,
          'riskLevel': 'HIGH',
          'statusSummary': '주의 필요',
          'memo': '상담 예정',
        },
      ],
    );
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> updateCourseStudentMemo({
    required int courseId,
    required int studentId,
    required String memo,
  }) async {
    final unauthorized = _unauthorized<Map<String, dynamic>>();
    if (unauthorized != null) return unauthorized;
    await Future<void>.delayed(const Duration(milliseconds: 140));
    return ApiResponse(
      success: true,
      message: '수강생 메모 저장 완료',
      data: {
        'userId': studentId,
        'name': studentId == 1
            ? '홍길동'
            : studentId == 2
                ? '김학생'
                : '박학생',
        'email': 'student$studentId@example.com',
        'status': 'ENROLLED',
        'progressRate': studentId == 1
            ? 88
            : studentId == 2
                ? 61
                : 39,
        'attendanceRate': studentId == 1
            ? 92
            : studentId == 2
                ? 70
                : 44,
        'understandingScore': studentId == 1
            ? 84
            : studentId == 2
                ? 58
                : 41,
        'riskLevel': studentId == 1
            ? 'LOW'
            : studentId == 2
                ? 'MEDIUM'
                : 'HIGH',
        'statusSummary': studentId == 1
            ? '안정'
            : studentId == 2
                ? '관찰 필요'
                : '주의 필요',
        'memo': memo,
      },
    );
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> createWeek({
    required int courseId,
    required int weekNumber,
    required String title,
    required String openAt,
  }) async {
    final unauthorized = _unauthorized<Map<String, dynamic>>();
    if (unauthorized != null) return unauthorized;
    await Future<void>.delayed(const Duration(milliseconds: 180));
    return ApiResponse(
      success: true,
      message: '주차 생성 완료',
      data: {
        'weekId': 2000 + weekNumber,
        'weekNumber': weekNumber,
        'title': title
      },
    );
  }

  @override
  Future<ApiResponse<List<Map<String, dynamic>>>> getWeekContents(
      int courseId, int weekId) async {
    final unauthorized = _unauthorized<List<Map<String, dynamic>>>();
    if (unauthorized != null) return unauthorized;
    await Future<void>.delayed(const Duration(milliseconds: 180));
    return const ApiResponse(
      success: true,
      message: '주차 콘텐츠 목록 조회 성공',
      data: [
        {
          'contentId': 5001,
          'type': 'VOD',
          'title': '1주차 강의 영상',
          'description': 'OT 및 기본 개념',
          'openAt': '2026-04-10T09:00:00Z',
          'isPublished': true,
        },
      ],
    );
  }

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
  }) async {
    final unauthorized = _unauthorized<Map<String, dynamic>>();
    if (unauthorized != null) return unauthorized;
    await Future<void>.delayed(const Duration(milliseconds: 220));
    return ApiResponse(
      success: true,
      message: '콘텐츠 생성 완료',
      data: {'contentId': 9001, 'title': title},
    );
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> createVideoUploadUrl({
    required String fileName,
    required String contentType,
  }) async {
    final unauthorized = _unauthorized<Map<String, dynamic>>();
    if (unauthorized != null) return unauthorized;
    await Future<void>.delayed(const Duration(milliseconds: 120));
    return ApiResponse(
      success: true,
      message: '비디오 업로드 URL 생성 완료',
      data: {
        'uploadUrl': 'https://example.com/presigned-upload',
        'fileUrl': 'https://cdn.example.com/$fileName',
        'objectKey': 'course-videos/mock/$fileName',
        'expiresInSeconds': 900,
      },
    );
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> createUploadUrl({
    required String fileName,
    required String contentType,
    required String category,
  }) async {
    final unauthorized = _unauthorized<Map<String, dynamic>>();
    if (unauthorized != null) return unauthorized;
    await Future<void>.delayed(const Duration(milliseconds: 120));
    return ApiResponse(
      success: true,
      message: '파일 업로드 URL 생성 완료',
      data: {
        'uploadUrl': 'https://example.com/presigned-upload',
        'fileUrl': 'https://cdn.example.com/$category/$fileName',
        'objectKey': '$category/mock/$fileName',
        'expiresInSeconds': 900,
      },
    );
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> getMyProfile() async {
    final unauthorized = _unauthorized<Map<String, dynamic>>();
    if (unauthorized != null) return unauthorized;
    await Future<void>.delayed(const Duration(milliseconds: 140));
    return ApiResponse(
      success: true,
      message: '내 정보 조회 성공',
      data: {
        'userId': _currentUser!.userId,
        'name': _currentUser!.name,
        'email': _currentUser!.email,
        'role': _currentUser!.role.apiValue,
        'profileImageUrl': _currentUser!.profileImageUrl,
      },
    );
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> updateMyProfile({
    required String name,
    required String profileImageUrl,
  }) async {
    final unauthorized = _unauthorized<Map<String, dynamic>>();
    if (unauthorized != null) return unauthorized;
    await Future<void>.delayed(const Duration(milliseconds: 160));
    _currentUser = AppUser(
      userId: _currentUser!.userId,
      name: name.trim().isEmpty ? _currentUser!.name : name.trim(),
      email: _currentUser!.email,
      role: _currentUser!.role,
      profileImageUrl:
          profileImageUrl.trim().isEmpty ? null : profileImageUrl.trim(),
    );
    return ApiResponse(
      success: true,
      message: '내 정보 수정 완료',
      data: {
        'userId': _currentUser!.userId,
        'name': _currentUser!.name,
        'email': _currentUser!.email,
        'role': _currentUser!.role.apiValue,
        'profileImageUrl': _currentUser!.profileImageUrl,
      },
    );
  }

  @override
  Future<ApiResponse<List<Map<String, dynamic>>>> getCourseAssignments(
    int courseId,
  ) async {
    final unauthorized = _unauthorized<List<Map<String, dynamic>>>();
    if (unauthorized != null) return unauthorized;
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return const ApiResponse(
      success: true,
      message: '과제 목록 조회 성공',
      data: [
        {
          'assignmentId': 7001,
          'title': '1주차 요약 과제',
          'type': 'SUBJECTIVE',
          'dueAt': '2026-04-15T23:59:59+09:00',
          'maxScore': 100,
          'isSubmitted': false,
        },
        {
          'assignmentId': 7002,
          'title': '2주차 개념 비교',
          'type': 'SUBJECTIVE',
          'dueAt': '2026-04-22T23:59:59+09:00',
          'maxScore': 100,
          'isSubmitted': true,
        },
      ],
    );
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> createAssignment({
    required int courseId,
    required String title,
    required String description,
    required String type,
    required String dueAt,
    required int maxScore,
    required bool teamAssignment,
  }) async {
    final unauthorized = _unauthorized<Map<String, dynamic>>();
    if (unauthorized != null) return unauthorized;
    await Future<void>.delayed(const Duration(milliseconds: 180));
    return ApiResponse(
      success: true,
      message: '과제 생성 완료',
      data: {
        'assignmentId': 8000,
        'courseId': courseId,
        'title': title,
        'type': type,
        'dueAt': dueAt,
        'maxScore': maxScore,
        'teamAssignment': teamAssignment,
      },
    );
  }

  @override
  Future<ApiResponse<List<Map<String, dynamic>>>> getCourseQuizzes(
      int courseId) async {
    final unauthorized = _unauthorized<List<Map<String, dynamic>>>();
    if (unauthorized != null) return unauthorized;
    await Future<void>.delayed(const Duration(milliseconds: 160));
    return const ApiResponse(
      success: true,
      message: '퀴즈 목록 조회 성공',
      data: [
        {
          'quizId': 6001,
          'title': '1주차 퀴즈',
          'dueAt': '2026-04-16T23:59:59+09:00',
          'isSubmitted': false,
        },
      ],
    );
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> getContentDetail(
      int contentId) async {
    final unauthorized = _unauthorized<Map<String, dynamic>>();
    if (unauthorized != null) return unauthorized;
    await Future<void>.delayed(const Duration(milliseconds: 180));
    return ApiResponse(
      success: true,
      message: '콘텐츠 상세 조회 성공',
      data: {
        'contentId': contentId,
        'type': 'VOD',
        'title': '1주차 강의 영상',
        'description': 'OT 및 기본 개념',
        'durationSeconds': 1800,
        'myProgress': {
          'progressRate': 35,
          'lastPositionSeconds': 620,
          'isCompleted': false,
        },
      },
    );
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> saveProgress({
    required int contentId,
    required int progressRate,
    required int watchedSeconds,
    required int totalSeconds,
  }) async {
    final unauthorized = _unauthorized<Map<String, dynamic>>();
    if (unauthorized != null) return unauthorized;
    await Future<void>.delayed(const Duration(milliseconds: 160));
    return ApiResponse(
      success: true,
      message: '진도 저장 완료',
      data: {
        'contentId': contentId,
        'progressRate': progressRate,
        'lastPositionSeconds': watchedSeconds,
        'isCompleted': progressRate >= 100,
      },
    );
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> getAssignmentDetail(
      int assignmentId) async {
    final unauthorized = _unauthorized<Map<String, dynamic>>();
    if (unauthorized != null) return unauthorized;
    await Future<void>.delayed(const Duration(milliseconds: 180));
    return ApiResponse(
      success: true,
      message: '과제 상세 조회 성공',
      data: {
        'assignmentId': assignmentId,
        'title': '1주차 요약 과제',
        'description': '강의 내용을 300자 이상 요약하세요.',
        'type': 'SUBJECTIVE',
        'dueAt': '2026-04-15T23:59:59+09:00',
        'maxScore': 100,
        'mySubmission': {
          'submissionId': 8001,
          'status': 'SUBMITTED',
          'submittedAt': '2026-04-14T21:00:00+09:00',
          'score': 92,
          'feedback': '핵심 개념 정리가 좋습니다.',
          'gradedAt': '2026-04-16T15:00:00+09:00',
        },
      },
    );
  }

  @override
  Future<ApiResponse<List<Map<String, dynamic>>>> getAssignmentSubmissions(
      int assignmentId) async {
    final unauthorized = _unauthorized<List<Map<String, dynamic>>>();
    if (unauthorized != null) return unauthorized;
    await Future<void>.delayed(const Duration(milliseconds: 180));
    return const ApiResponse(
      success: true,
      message: '과제 제출 목록 조회 성공',
      data: [
        {
          'submissionId': 8001,
          'studentId': 1,
          'studentName': '홍길동',
          'status': 'SUBMITTED',
          'submittedAt': '2026-04-14T21:00:00+09:00',
          'score': 92,
          'feedback': '핵심 개념 정리가 좋습니다.',
          'gradedAt': '2026-04-16T15:00:00+09:00',
        },
        {
          'submissionId': 8002,
          'studentId': 2,
          'studentName': '김학생',
          'status': 'LATE',
          'submittedAt': '2026-04-16T01:00:00+09:00',
          'score': null,
          'feedback': null,
          'gradedAt': null,
        },
      ],
    );
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> gradeAssignmentSubmission({
    required int assignmentId,
    required int submissionId,
    required int score,
    required String feedback,
  }) async {
    final unauthorized = _unauthorized<Map<String, dynamic>>();
    if (unauthorized != null) return unauthorized;
    await Future<void>.delayed(const Duration(milliseconds: 180));
    return ApiResponse(
      success: true,
      message: '과제 채점 완료',
      data: {
        'submissionId': submissionId,
        'submittedAt': '2026-04-14T21:00:00+09:00',
        'status': 'SUBMITTED',
        'score': score,
        'feedback': feedback,
        'gradedAt': DateTime.now().toIso8601String(),
      },
    );
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> submitAssignment({
    required int assignmentId,
    required String answerText,
  }) async {
    final unauthorized = _unauthorized<Map<String, dynamic>>();
    if (unauthorized != null) return unauthorized;
    await Future<void>.delayed(const Duration(milliseconds: 250));
    if (answerText.trim().length < 5) {
      return const ApiResponse(
        success: false,
        message: '답변이 너무 짧습니다.',
        errorCode: 'INVALID_ANSWER',
      );
    }
    return ApiResponse(
      success: true,
      message: '과제 제출 완료',
      data: {
        'submissionId': 8001,
        'assignmentId': assignmentId,
        'submittedAt': DateTime.now().toIso8601String(),
        'status': 'SUBMITTED',
      },
    );
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> getStudentDashboard() async {
    final unauthorized = _unauthorized<Map<String, dynamic>>();
    if (unauthorized != null) return unauthorized;
    await Future<void>.delayed(const Duration(milliseconds: 140));
    return const ApiResponse(
      success: true,
      message: '학습자 대시보드 조회 성공',
      data: {
        'attendanceRate': 85,
        'progressRate': 72,
        'assignmentSubmitRate': 75,
        'understandingScore': 68,
        'engagementScore': 70,
        'riskLevel': 'MEDIUM',
        'coachingMessage': '최근 학습 흐름이 조금 떨어지고 있어요. 1주차 핵심 개념을 복습해보세요.',
      },
    );
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> getMyReport() async {
    final unauthorized = _unauthorized<Map<String, dynamic>>();
    if (unauthorized != null) return unauthorized;
    await Future<void>.delayed(const Duration(milliseconds: 150));
    return const ApiResponse(
      success: true,
      message: '내 학습 리포트 조회 성공',
      data: {
        'weeklySummary': '이번 주는 출석은 안정적이지만 특정 개념에서 반복 시청이 많았습니다.',
        'strengths': ['출석 성실', '퀴즈 점수 양호'],
        'weaknesses': ['개념 연결 부족', '팀 토론 참여 저조'],
        'nextActions': ['과적합 개념 복습', '꼬리질문 답변하기'],
      },
    );
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> getRecommendations(
      int studentId) async {
    final unauthorized = _unauthorized<Map<String, dynamic>>();
    if (unauthorized != null) return unauthorized;
    await Future<void>.delayed(const Duration(milliseconds: 150));
    return ApiResponse(
      success: true,
      message: '추천 조회 성공',
      data: {
        'studentId': studentId,
        'reviewConcepts': ['지도학습', '과적합'],
        'recommendedActions': [
          '오늘 10분 복습하기',
          '꼬리질문 1개 더 풀어보기',
          '팀 토론에 의견 1회 남기기'
        ],
      },
    );
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> getMyTeam() async {
    final unauthorized = _unauthorized<Map<String, dynamic>>();
    if (unauthorized != null) return unauthorized;
    await Future<void>.delayed(const Duration(milliseconds: 140));
    return const ApiResponse(
      success: true,
      message: '내 팀 조회 성공',
      data: {
        'teamId': 3001,
        'teamName': 'AI 기초 : 1팀',
        'courseId': 101,
        'teamBuildingScore': 82,
        'matchingSummary': '추진형, 분석형, 조율형을 섞어 역할 분담이 자연스럽게 일어나도록 구성했습니다.',
        'members': [
          {'userId': 1, 'name': '홍길동'},
          {'userId': 2, 'name': '김학생'},
          {'userId': 3, 'name': '이학생'},
        ],
      },
    );
  }

  @override
  Future<ApiResponse<List<Map<String, dynamic>>>> getCourseTeams(
      int courseId) async {
    final unauthorized = _unauthorized<List<Map<String, dynamic>>>();
    if (unauthorized != null) return unauthorized;
    await Future<void>.delayed(const Duration(milliseconds: 180));
    return const ApiResponse(
      success: true,
      message: '팀 목록 조회 성공',
      data: [
        {
          'teamId': 3001,
          'name': 'AI 기초 : 1팀',
          'memberCount': 3,
          'status': 'ACTIVE',
          'teamBuildingScore': 82,
          'matchingSummary': '추진형과 분석형을 묶어 실행력과 개념 정교화를 같이 노렸습니다.',
        },
        {
          'teamId': 3002,
          'name': 'AI 기초 : 2팀',
          'memberCount': 3,
          'status': 'ACTIVE',
          'teamBuildingScore': 76,
          'matchingSummary': '안정형과 조율형을 섞어 과제 진행 안정성을 높였습니다.',
        },
      ],
    );
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> autoGroupTeams({
    required int courseId,
    required int teamSize,
  }) async {
    final unauthorized = _unauthorized<Map<String, dynamic>>();
    if (unauthorized != null) return unauthorized;
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return const ApiResponse(
      success: true,
      message: '팀 자동 배정 완료',
      data: {
        'teamCount': 2,
        'groupingBasis': 'LEARNING_STYLE_BALANCED',
        'teams': [
          {
            'teamId': 3001,
            'name': 'AI 기초 : 1팀',
            'memberCount': 3,
            'status': 'ACTIVE',
            'teamBuildingScore': 82,
            'matchingSummary': '추진형과 분석형을 묶어 실행력과 개념 정교화를 같이 노렸습니다.',
          },
          {
            'teamId': 3002,
            'name': 'AI 기초 : 2팀',
            'memberCount': 3,
            'status': 'ACTIVE',
            'teamBuildingScore': 76,
            'matchingSummary': '안정형과 조율형을 섞어 과제 진행 안정성을 높였습니다.',
          },
        ],
      },
    );
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> getTeamDetail(int teamId) async {
    final unauthorized = _unauthorized<Map<String, dynamic>>();
    if (unauthorized != null) return unauthorized;
    await Future<void>.delayed(const Duration(milliseconds: 140));
    return ApiResponse(
      success: true,
      message: '팀 상세 조회 성공',
      data: {
        'teamId': teamId,
        'teamBuildingScore': 82,
        'profileDiversityScore': 79,
        'matchingSummary': '추진형, 분석형, 조율형을 함께 배치해 실행력과 의사결정 균형을 노렸습니다.',
        'collaborationScore': 72,
        'riskSignals': ['특정 학생 채팅 참여 없음'],
        'members': [
          {
            'userId': 1,
            'name': '홍길동',
            'learningStyle': 'DRIVER',
            'reliabilityScore': 74,
            'initiativeScore': 88,
            'supportScore': 63,
            'understandingScore': 70,
            'profileSummary': '실행 속도가 빠르고 먼저 논의를 이끄는 편입니다.',
          },
          {
            'userId': 2,
            'name': '김학생',
            'learningStyle': 'ANALYST',
            'reliabilityScore': 81,
            'initiativeScore': 60,
            'supportScore': 69,
            'understandingScore': 86,
            'profileSummary': '개념 연결과 문제 구조화가 강점입니다.',
          },
          {
            'userId': 3,
            'name': '박학생',
            'learningStyle': 'FACILITATOR',
            'reliabilityScore': 77,
            'initiativeScore': 58,
            'supportScore': 84,
            'understandingScore': 68,
            'profileSummary': '출석과 협업 안정성이 높아 팀 조율에 강합니다.',
          },
        ],
      },
    );
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> getTeamAnalytics(int teamId) async {
    final unauthorized = _unauthorized<Map<String, dynamic>>();
    if (unauthorized != null) return unauthorized;
    await Future<void>.delayed(const Duration(milliseconds: 180));
    return const ApiResponse(
      success: true,
      message: '팀 협업 지표 조회 성공',
      data: {
        'teamBuildingScore': 82,
        'profileDiversityScore': 79,
        'matchingSummary': '추진형, 분석형, 조율형을 함께 배치해 실행력과 의사결정 균형을 노렸습니다.',
        'collaborationScore': 84,
        'conversationBalanceScore': 76,
        'inactiveMemberCount': 0,
        'dominantMemberCount': 1,
        'riskSignals': ['한 명의 발화 비중이 높습니다.'],
        'strengthSignals': [
          '서로 다른 학습 스타일이 섞여 있어 역할 분담 가능성이 높습니다.',
          '팀 대화가 비교적 고르게 분산되어 있습니다.',
        ],
        'styleDistributions': [
          {'style': 'DRIVER', 'memberCount': 1},
          {'style': 'ANALYST', 'memberCount': 1},
          {'style': 'FACILITATOR', 'memberCount': 1},
        ],
      },
    );
  }

  @override
  Future<ApiResponse<List<Map<String, dynamic>>>> getTeamMemberContributions(
      int teamId) async {
    final unauthorized = _unauthorized<List<Map<String, dynamic>>>();
    if (unauthorized != null) return unauthorized;
    await Future<void>.delayed(const Duration(milliseconds: 180));
    return const ApiResponse(
      success: true,
      message: '팀원 기여도 조회 성공',
      data: [
        {
          'userId': 1,
          'name': '홍길동',
          'learningStyle': 'DRIVER',
          'reliabilityScore': 74,
          'messageCount': 12,
          'contributionScore': 88,
        },
        {
          'userId': 2,
          'name': '김학생',
          'learningStyle': 'ANALYST',
          'reliabilityScore': 81,
          'messageCount': 9,
          'contributionScore': 73,
        },
        {
          'userId': 3,
          'name': '박학생',
          'learningStyle': 'FACILITATOR',
          'reliabilityScore': 77,
          'messageCount': 4,
          'contributionScore': 51,
        },
      ],
    );
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> getTeamChatRoom(int teamId) async {
    final unauthorized = _unauthorized<Map<String, dynamic>>();
    if (unauthorized != null) return unauthorized;
    await Future<void>.delayed(const Duration(milliseconds: 120));
    return ApiResponse(
      success: true,
      message: '채팅방 조회 성공',
      data: {'chatRoomId': 4001, 'teamId': teamId},
    );
  }

  @override
  Future<ApiResponse<List<Map<String, dynamic>>>> getChatMessages(
      int chatRoomId) async {
    final unauthorized = _unauthorized<List<Map<String, dynamic>>>();
    if (unauthorized != null) return unauthorized;
    await Future<void>.delayed(const Duration(milliseconds: 120));
    return const ApiResponse(
      success: true,
      message: '채팅 메시지 조회 성공',
      data: [
        {
          'messageId': 101,
          'senderName': '홍길동',
          'message': '이 개념은 이렇게 이해하면 될까요?',
          'sentAt': '2026-04-06T21:00:00+09:00',
        },
        {
          'messageId': 102,
          'senderName': '김학생',
          'message': '좋아요. 예시를 하나 더 찾아볼게요.',
          'sentAt': '2026-04-06T21:01:30+09:00',
        },
      ],
    );
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> getInstructorDashboard(
      int courseId) async {
    final unauthorized = _unauthorized<Map<String, dynamic>>();
    if (unauthorized != null) return unauthorized;
    await Future<void>.delayed(const Duration(milliseconds: 140));
    return ApiResponse(
      success: true,
      message: '교수자 대시보드 조회 성공',
      data: {
        'courseId': courseId,
        'courseTitle': 'AI 기초',
        'studentCount': 40,
        'averageAttendanceRate': 82,
        'averageProgressRate': 70,
        'highRiskStudentCount': 5,
        'lowUnderstandingStudentCount': 7,
      },
    );
  }

  @override
  Future<ApiResponse<List<Map<String, dynamic>>>> getRiskStudents(
      int courseId) async {
    final unauthorized = _unauthorized<List<Map<String, dynamic>>>();
    if (unauthorized != null) return unauthorized;
    await Future<void>.delayed(const Duration(milliseconds: 140));
    return const ApiResponse(
      success: true,
      message: '위험 학생 목록 조회 성공',
      data: [
        {
          'studentId': 1,
          'studentName': '홍길동',
          'riskScore': 78,
          'riskLevel': 'HIGH'
        },
        {
          'studentId': 7,
          'studentName': '박학생',
          'riskScore': 71,
          'riskLevel': 'HIGH'
        },
      ],
    );
  }

  @override
  Future<ApiResponse<List<Map<String, dynamic>>>> getLowUnderstandingStudents(
    int courseId,
  ) async {
    final unauthorized = _unauthorized<List<Map<String, dynamic>>>();
    if (unauthorized != null) return unauthorized;
    await Future<void>.delayed(const Duration(milliseconds: 140));
    return const ApiResponse(
      success: true,
      message: '이해도 낮은 학생 조회 성공',
      data: [
        {'studentId': 2, 'studentName': '김학생', 'understandingScore': 52},
        {'studentId': 5, 'studentName': '최학생', 'understandingScore': 48},
      ],
    );
  }

  @override
  Future<ApiResponse<List<Map<String, dynamic>>>> getInterventions(
      int courseId) async {
    final unauthorized = _unauthorized<List<Map<String, dynamic>>>();
    if (unauthorized != null) return unauthorized;
    await Future<void>.delayed(const Duration(milliseconds: 140));
    return const ApiResponse(
      success: true,
      message: '개입 추천 조회 성공',
      data: [
        {'studentName': '홍길동', 'recommendedAction': '상담 권장'},
        {'studentName': '김학생', 'recommendedAction': '보충자료 발송'},
      ],
    );
  }

  ApiResponse<T>? _unauthorized<T>() {
    if (_accessToken == null || _currentUser == null) {
      return const ApiResponse(
        success: false,
        message: '인증이 필요합니다.',
        errorCode: 'UNAUTHORIZED',
      );
    }
    return null;
  }
}
