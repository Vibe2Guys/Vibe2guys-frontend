import 'package:flutter/material.dart';

import 'core/api_client.dart';
import 'core/api_contract.dart';
import 'core/http_api_client.dart';
import 'core/mock_api_client.dart';

const bool kShowDeveloperApi = bool.fromEnvironment(
  'SHOW_DEV_API',
  defaultValue: false,
);

class Vibe2GuysApp extends StatefulWidget {
  const Vibe2GuysApp({super.key});

  @override
  State<Vibe2GuysApp> createState() => _Vibe2GuysAppState();
}

class _Vibe2GuysAppState extends State<Vibe2GuysApp> {
  final AppController controller = AppController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vibe2Guys LMS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Segoe UI',
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0E7A66)),
      ),
      home: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          if (!controller.isAuthenticated) {
            return LoginPage(controller: controller);
          }
          return AppShell(controller: controller);
        },
      ),
    );
  }
}

class AppController extends ChangeNotifier {
  final ApiClient api = const bool.fromEnvironment('USE_REAL_API', defaultValue: false)
      ? HttpApiClient()
      : MockApiClient();
  bool _loading = false;
  int selectedIndex = 0;

  bool get loading => _loading;
  bool get isAuthenticated => api.currentUser != null && api.accessToken != null;
  AppUser? get user => api.currentUser;

  Future<ApiResponse<Map<String, dynamic>>> login({
    required String email,
    required String password,
    required UserRole role,
  }) async {
    _loading = true;
    notifyListeners();
    final response = await api.login(email: email, password: password, role: role);
    _loading = false;
    notifyListeners();
    return response;
  }

  void logout() {
    api.logout();
    selectedIndex = 0;
    notifyListeners();
  }

  void setSelectedIndex(int index) {
    selectedIndex = index;
    notifyListeners();
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.controller});
  final AppController controller;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController(
    text: 'test@example.com',
  );
  final TextEditingController passwordController = TextEditingController(
    text: '1234abcd!',
  );
  UserRole selectedRole = UserRole.student;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF021F2B), Color(0xFF083B4A), Color(0xFF0E7A66)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Card(
              elevation: 16,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Vibe2Guys LMS',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 8),
                    const Text('공통 API 응답 규칙 기반 Flutter Web MVP'),
                    const SizedBox(height: 18),
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: '이메일',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: '비밀번호',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SegmentedButton<UserRole>(
                      segments: UserRole.values
                          .map(
                            (role) => ButtonSegment<UserRole>(
                              value: role,
                              label: Text(role.label),
                            ),
                          )
                          .toList(),
                      selected: {selectedRole},
                      onSelectionChanged: (selection) {
                        setState(() => selectedRole = selection.first);
                      },
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: widget.controller.loading
                            ? null
                            : () async {
                                final response = await widget.controller.login(
                                  email: emailController.text,
                                  password: passwordController.text,
                                  role: selectedRole,
                                );
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(response.message)),
                                );
                              },
                        child: widget.controller.loading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('로그인'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.controller});
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final role = controller.user!.role;
    final labels = role == UserRole.student
        ? [
            '대시보드',
            '강의',
            '콘텐츠',
            '과제',
            '팀 활동',
            if (kShowDeveloperApi) 'API 규칙',
          ]
        : [
            '교수자 대시보드',
            '위험 학생',
            '강의 관리',
            '팀 분석',
            if (kShowDeveloperApi) 'API 규칙',
          ];
    final currentIndex = controller.selectedIndex >= labels.length ? 0 : controller.selectedIndex;
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: currentIndex,
            labelType: NavigationRailLabelType.all,
            onDestinationSelected: controller.setSelectedIndex,
            leading: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: CircleAvatar(
                backgroundColor: Colors.teal.shade700,
                child: Text(controller.user!.name.characters.first),
              ),
            ),
            trailing: IconButton(
              onPressed: controller.logout,
              icon: const Icon(Icons.logout),
              tooltip: '로그아웃',
            ),
            destinations: labels
                .map(
                  (label) => NavigationRailDestination(
                    icon: const Icon(Icons.radio_button_unchecked),
                    selectedIcon: const Icon(Icons.check_circle),
                    label: Text(label),
                  ),
                )
                .toList(),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFF2FBF8), Color(0xFFE7F5FF)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: _buildBody(role, currentIndex),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(UserRole role, int selectedIndex) {
    if (role == UserRole.student) {
      switch (selectedIndex) {
        case 0:
          return StudentDashboardPage(controller: controller);
        case 1:
          return StudentCoursesPage(controller: controller);
        case 2:
          return StudentContentPage(controller: controller);
        case 3:
          return StudentAssignmentPage(controller: controller);
        case 4:
          return StudentTeamPage(controller: controller);
        case 5:
          if (kShowDeveloperApi) return const ApiRulesPage();
          return StudentDashboardPage(controller: controller);
        default:
          return StudentDashboardPage(controller: controller);
      }
    }
    switch (selectedIndex) {
      case 0:
        return InstructorDashboardPage(controller: controller);
      case 1:
        return InstructorStudentsPage(controller: controller);
      case 2:
        return const InstructorCourseApisPage();
      case 3:
        return const InstructorTeamApisPage();
      case 4:
        if (kShowDeveloperApi) return const ApiRulesPage();
        return InstructorDashboardPage(controller: controller);
      default:
        return InstructorDashboardPage(controller: controller);
    }
  }
}

class StudentDashboardPage extends StatelessWidget {
  const StudentDashboardPage({super.key, required this.controller});
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ApiResponse<dynamic>>>(
      future: Future.wait<ApiResponse<dynamic>>([
        controller.api.getStudentDashboard(),
        controller.api.getMyReport(),
        controller.api.getRecommendations(controller.user!.userId),
      ]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final responses = snapshot.data!;
        final dashboard = responses[0].data as Map<String, dynamic>;
        final report = responses[1].data as Map<String, dynamic>;
        final recommendations = responses[2].data as Map<String, dynamic>;

        return ListView(
          children: [
            Text('학습자 대시보드', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                MetricCard(label: '출석률', value: '${dashboard['attendanceRate']}%'),
                MetricCard(label: '진도율', value: '${dashboard['progressRate']}%'),
                MetricCard(label: '이해도', value: '${dashboard['understandingScore']}'),
                MetricCard(label: '위험도', value: '${dashboard['riskLevel']}'),
              ],
            ),
            const SizedBox(height: 12),
            InfoCard(title: '코칭 메시지', content: '${dashboard['coachingMessage']}'),
            const SizedBox(height: 8),
            InfoCard(title: '주간 요약', content: '${report['weeklySummary']}'),
            const SizedBox(height: 8),
            InfoCard(
              title: '추천 액션',
              content: (recommendations['recommendedActions'] as List<dynamic>).join(' / '),
            ),
          ],
        );
      },
    );
  }
}

class StudentCoursesPage extends StatelessWidget {
  const StudentCoursesPage({super.key, required this.controller});
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ApiResponse<List<Map<String, dynamic>>>>(
      future: controller.api.getMyCourses(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final courses = snapshot.data!.data ?? [];
        return ListView(
          children: [
            Text('내 강의 목록', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12),
            ...courses.map(
              (course) => Card(
                child: ListTile(
                  title: Text('${course['title']}'),
                  subtitle: Text(
                    '진도 ${course['progressRate']}% | 출석 ${course['attendanceRate']}% | 미제출 ${course['assignmentPendingCount']}',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            const EndpointChip(label: 'GET ${Endpoints.coursesMy}'),
            EndpointChip(label: 'GET ${Endpoints.courseDetail(101)}'),
            EndpointChip(label: 'GET ${Endpoints.courseAssignments(101)}'),
            EndpointChip(label: 'GET ${Endpoints.courseQuizzes(101)}'),
          ],
        );
      },
    );
  }
}

class StudentContentPage extends StatefulWidget {
  const StudentContentPage({super.key, required this.controller});
  final AppController controller;

  @override
  State<StudentContentPage> createState() => _StudentContentPageState();
}

class _StudentContentPageState extends State<StudentContentPage> {
  int progressRate = 35;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ApiResponse<Map<String, dynamic>>>(
      future: widget.controller.api.getContentDetail(5001),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final content = snapshot.data!.data!;
        return ListView(
          children: [
            Text('콘텐츠 및 진도', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12),
            InfoCard(
              title: '${content['title']}',
              content: '${content['description']} (${content['durationSeconds']}초)',
            ),
            const SizedBox(height: 10),
            Text('현재 진도율: $progressRate%'),
            Slider(
              value: progressRate.toDouble(),
              max: 100,
              divisions: 20,
              onChanged: (value) => setState(() => progressRate = value.toInt()),
            ),
            FilledButton(
              onPressed: () async {
                final watched = 1800 * progressRate ~/ 100;
                final response = await widget.controller.api.saveProgress(
                  contentId: 5001,
                  progressRate: progressRate,
                  watchedSeconds: watched,
                );
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(response.message)),
                );
              },
              child: const Text('진도 저장'),
            ),
            const SizedBox(height: 10),
            EndpointChip(label: 'GET ${Endpoints.contentDetail(5001)}'),
            EndpointChip(label: 'POST ${Endpoints.contentProgress(5001)}'),
          ],
        );
      },
    );
  }
}

class StudentAssignmentPage extends StatefulWidget {
  const StudentAssignmentPage({super.key, required this.controller});
  final AppController controller;

  @override
  State<StudentAssignmentPage> createState() => _StudentAssignmentPageState();
}

class _StudentAssignmentPageState extends State<StudentAssignmentPage> {
  final TextEditingController answerController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ApiResponse<Map<String, dynamic>>>(
      future: widget.controller.api.getAssignmentDetail(7001),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final assignment = snapshot.data!.data!;
        return ListView(
          children: [
            Text('과제', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12),
            InfoCard(
              title: '${assignment['title']}',
              content: '${assignment['description']}',
            ),
            const SizedBox(height: 12),
            TextField(
              controller: answerController,
              maxLines: 6,
              decoration: const InputDecoration(
                hintText: '답변을 입력하세요',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () async {
                final response = await widget.controller.api.submitAssignment(
                  assignmentId: 7001,
                  answerText: answerController.text,
                );
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(response.message)),
                );
              },
              child: const Text('과제 제출'),
            ),
            const SizedBox(height: 10),
            EndpointChip(label: 'GET ${Endpoints.assignmentDetail(7001)}'),
            EndpointChip(label: 'POST ${Endpoints.assignmentSubmit(7001)}'),
          ],
        );
      },
    );
  }
}

class StudentTeamPage extends StatelessWidget {
  const StudentTeamPage({super.key, required this.controller});
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ApiResponse<dynamic>>>(
      future: Future.wait<ApiResponse<dynamic>>([
        controller.api.getMyTeam(),
        controller.api.getTeamDetail(3001),
        controller.api.getTeamChatRoom(3001),
        controller.api.getChatMessages(4001),
      ]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final responses = snapshot.data!;
        final team = responses[0].data as Map<String, dynamic>;
        final detail = responses[1].data as Map<String, dynamic>;
        final messages = responses[3].data as List<Map<String, dynamic>>;

        return ListView(
          children: [
            Text('팀 활동', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12),
            InfoCard(
              title: '${team['teamName']} (협업점수 ${detail['collaborationScore']})',
              content:
                  '팀원: ${(team['members'] as List<dynamic>).map((e) => (e as Map<String, dynamic>)['name']).join(', ')}',
            ),
            const SizedBox(height: 12),
            ...messages.map(
              (message) => Card(
                child: ListTile(
                  title: Text('${message['senderName']}'),
                  subtitle: Text('${message['message']}'),
                  trailing: Text('${message['sentAt']}'.substring(11, 16)),
                ),
              ),
            ),
            const SizedBox(height: 10),
            const EndpointChip(label: 'GET ${Endpoints.teamsMe}'),
            EndpointChip(label: 'GET ${Endpoints.teamDetail(3001)}'),
            EndpointChip(label: 'GET ${Endpoints.teamChatRoom(3001)}'),
            EndpointChip(label: 'GET ${Endpoints.chatMessages(4001)}'),
          ],
        );
      },
    );
  }
}

class InstructorDashboardPage extends StatelessWidget {
  const InstructorDashboardPage({super.key, required this.controller});
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ApiResponse<Map<String, dynamic>>>(
      future: controller.api.getInstructorDashboard(101),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final data = snapshot.data!.data!;
        return ListView(
          children: [
            Text('교수자 대시보드', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                MetricCard(label: '수강생', value: '${data['studentCount']}'),
                MetricCard(label: '평균 출석', value: '${data['averageAttendanceRate']}%'),
                MetricCard(label: '고위험 학생', value: '${data['highRiskStudentCount']}'),
                MetricCard(
                  label: '저이해 학생',
                  value: '${data['lowUnderstandingStudentCount']}',
                ),
              ],
            ),
            const SizedBox(height: 10),
            EndpointChip(label: 'GET ${Endpoints.instructorDashboard(101)}'),
          ],
        );
      },
    );
  }
}

class InstructorStudentsPage extends StatelessWidget {
  const InstructorStudentsPage({super.key, required this.controller});
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ApiResponse<dynamic>>>(
      future: Future.wait<ApiResponse<dynamic>>([
        controller.api.getRiskStudents(101),
        controller.api.getLowUnderstandingStudents(101),
        controller.api.getInterventions(101),
      ]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final responses = snapshot.data!;
        final risk = responses[0].data as List<Map<String, dynamic>>;
        final low = responses[1].data as List<Map<String, dynamic>>;
        final interventions = responses[2].data as List<Map<String, dynamic>>;
        return ListView(
          children: [
            Text('위험/저이해 학생', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 10),
            const Text('위험 학생'),
            ...risk.map(
              (student) => ListTile(
                title: Text('${student['studentName']}'),
                subtitle: Text('위험도 ${student['riskScore']} (${student['riskLevel']})'),
              ),
            ),
            const Divider(),
            const Text('저이해 학생'),
            ...low.map(
              (student) => ListTile(
                title: Text('${student['studentName']}'),
                subtitle: Text('점수 ${student['understandingScore']}'),
              ),
            ),
            const Divider(),
            const Text('개입 추천'),
            ...interventions.map(
              (item) => ListTile(
                title: Text('${item['studentName']}'),
                subtitle: Text('${item['recommendedAction']}'),
              ),
            ),
            const SizedBox(height: 10),
            EndpointChip(label: 'GET ${Endpoints.riskStudents(101)}'),
            EndpointChip(label: 'GET ${Endpoints.lowUnderstandingStudents(101)}'),
            EndpointChip(label: 'GET ${Endpoints.interventions(101)}'),
          ],
        );
      },
    );
  }
}

class InstructorCourseApisPage extends StatelessWidget {
  const InstructorCourseApisPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        Text('강의 관리 API', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
        SizedBox(height: 10),
        EndpointChip(label: 'POST /api/v1/courses'),
        EndpointChip(label: 'PATCH /api/v1/courses/{courseId}'),
        EndpointChip(label: 'POST /api/v1/courses/{courseId}/assignments'),
        EndpointChip(label: 'POST /api/v1/courses/{courseId}/quizzes'),
      ],
    );
  }
}

class InstructorTeamApisPage extends StatelessWidget {
  const InstructorTeamApisPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        Text('팀 분석 API', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
        SizedBox(height: 10),
        EndpointChip(label: 'GET /api/v1/courses/{courseId}/teams'),
        EndpointChip(label: 'GET /api/v1/teams/{teamId}/analytics'),
        EndpointChip(label: 'GET /api/v1/teams/{teamId}/members/contributions'),
      ],
    );
  }
}

class ApiRulesPage extends StatelessWidget {
  const ApiRulesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        Text('공통 API 규칙', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
        SizedBox(height: 12),
        InfoCard(title: '기본 URL', content: '/api/v1'),
        InfoCard(
          title: '성공 응답',
          content: '{"success": true, "message": "...", "data": {...}}',
        ),
        InfoCard(
          title: '실패 응답',
          content: '{"success": false, "message": "...", "errorCode": "COURSE_NOT_FOUND"}',
        ),
        InfoCard(
          title: '인증 헤더',
          content: 'Authorization: Bearer {accessToken}',
        ),
        InfoCard(title: '역할', content: 'STUDENT / INSTRUCTOR / ADMIN'),
      ],
    );
  }
}

class MetricCard extends StatelessWidget {
  const MetricCard({super.key, required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 190,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: Colors.black54)),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class EndpointChip extends StatelessWidget {
  const EndpointChip({super.key, required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    if (!kShowDeveloperApi) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF072B36),
        borderRadius: BorderRadius.circular(12),
      ),
      child: SelectableText(
        label,
        style: const TextStyle(
          color: Color(0xFFCAFFE8),
          fontFamily: 'Consolas',
        ),
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  const InfoCard({super.key, required this.title, required this.content});
  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.teal.withOpacity(0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(content),
        ],
      ),
    );
  }
}
