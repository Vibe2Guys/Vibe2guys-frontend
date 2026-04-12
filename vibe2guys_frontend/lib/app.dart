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

  Future<ApiResponse<Map<String, dynamic>>> register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    _loading = true;
    notifyListeners();
    final response = await api.register(
      name: name,
      email: email,
      password: password,
      role: role,
    );
    _loading = false;
    notifyListeners();
    return response;
  }

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

  Future<void> logout() async {
    await api.logout();
    selectedIndex = 0;
    notifyListeners();
  }

  void setSelectedIndex(int index) {
    selectedIndex = index;
    notifyListeners();
  }
}

enum AuthMode { login, register }

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.controller});
  final AppController controller;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final FocusNode nameFocusNode = FocusNode();
  final FocusNode emailFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();
  final FocusNode confirmPasswordFocusNode = FocusNode();
  AuthMode mode = AuthMode.login;
  UserRole selectedRole = UserRole.student;
  UserRole registerRole = UserRole.student;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    nameFocusNode.dispose();
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRegister = mode == AuthMode.register;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF051B2B), Color(0xFF0C4A5B), Color(0xFFE5F6F1)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 980),
            child: Container(
              margin: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x22051B2B),
                    blurRadius: 42,
                    offset: Offset(0, 20),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(36, 40, 36, 40),
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.horizontal(left: Radius.circular(28)),
                        gradient: LinearGradient(
                          colors: [Color(0xFF0B2435), Color(0xFF0E5C63)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: const Text(
                              'Collaborative Learning Platform',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(height: 22),
                          const Text(
                            'Vibe2Guys LMS',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 34,
                              fontWeight: FontWeight.w800,
                              height: 1.15,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            isRegister
                                ? '학습자는 몇 가지 정보만 입력하면 바로 계정을 만들 수 있습니다.'
                                : '학생, 교수자, 관리자 계정으로 같은 화면에서 바로 로그인할 수 있습니다.',
                            style: const TextStyle(
                              color: Color(0xFFD5ECE7),
                              fontSize: 15,
                              height: 1.6,
                            ),
                          ),
                          const SizedBox(height: 30),
                          _AuthHighlight(
                            title: isRegister ? '빠른 시작' : '바로 시작하기',
                            description: isRegister
                                ? '이름, 이메일, 비밀번호만 입력하면 학습자 계정을 바로 만들 수 있습니다.'
                                : '이메일과 비밀번호를 입력하고 역할을 선택한 뒤 바로 학습 화면으로 들어갈 수 있습니다.',
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(36, 32, 36, 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F4),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: SizedBox(
                              width: double.infinity,
                              child: SegmentedButton<AuthMode>(
                                showSelectedIcon: false,
                                style: ButtonStyle(
                                  minimumSize: WidgetStateProperty.all(
                                    const Size.fromHeight(52),
                                  ),
                                  textStyle: WidgetStateProperty.all(
                                    const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                segments: const [
                                  ButtonSegment<AuthMode>(
                                    value: AuthMode.login,
                                    label: SizedBox(
                                      width: 120,
                                      child: Center(child: Text('로그인')),
                                    ),
                                  ),
                                  ButtonSegment<AuthMode>(
                                    value: AuthMode.register,
                                    label: SizedBox(
                                      width: 120,
                                      child: Center(child: Text('회원가입')),
                                    ),
                                  ),
                                ],
                                selected: {mode},
                                onSelectionChanged: (selection) {
                                  setState(() => mode = selection.first);
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 26),
                          Text(
                            isRegister ? '회원가입' : '계정 로그인',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 24),
                          if (isRegister) ...[
                            _AuthTextField(
                              focusNode: nameFocusNode,
                              nextFocusNode: emailFocusNode,
                              controller: nameController,
                              label: '이름',
                              hintText: '홍길동',
                            ),
                            const SizedBox(height: 14),
                          ],
                          _AuthTextField(
                            focusNode: emailFocusNode,
                            nextFocusNode: passwordFocusNode,
                            controller: emailController,
                            label: '이메일',
                            hintText: 'test@example.com',
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 14),
                          _AuthTextField(
                            focusNode: passwordFocusNode,
                            nextFocusNode:
                                isRegister ? confirmPasswordFocusNode : null,
                            controller: passwordController,
                            label: '비밀번호',
                            hintText: isRegister ? '8자 이상 비밀번호' : '비밀번호를 입력하세요',
                            obscureText: true,
                          ),
                          if (isRegister) ...[
                            const SizedBox(height: 14),
                            _AuthTextField(
                              focusNode: confirmPasswordFocusNode,
                              controller: confirmPasswordController,
                              label: '비밀번호 확인',
                              hintText: '비밀번호를 다시 입력하세요',
                              obscureText: true,
                            ),
                          ],
                          const SizedBox(height: 16),
                          if (!isRegister) ...[
                            const Text(
                              '로그인 역할',
                              style: TextStyle(
                                color: Color(0xFF516168),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 10),
                            SegmentedButton<UserRole>(
                              style: ButtonStyle(
                                minimumSize: WidgetStateProperty.all(
                                  const Size.fromHeight(46),
                                ),
                                textStyle: WidgetStateProperty.all(
                                  const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              segments: UserRole.values
                                  .map(
                                    (role) => ButtonSegment<UserRole>(
                                      value: role,
                                      label: SizedBox(
                                        width: 78,
                                        child: Center(child: Text(role.label)),
                                      ),
                                    ),
                                  )
                                  .toList(),
                              selected: {selectedRole},
                              onSelectionChanged: (selection) {
                                setState(() => selectedRole = selection.first);
                              },
                            ),
                          ] else ...[
                            const Text(
                              '회원가입 역할',
                              style: TextStyle(
                                color: Color(0xFF516168),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 10),
                            SegmentedButton<UserRole>(
                              style: ButtonStyle(
                                minimumSize: WidgetStateProperty.all(
                                  const Size.fromHeight(46),
                                ),
                                textStyle: WidgetStateProperty.all(
                                  const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              segments: UserRole.values
                                  .where((role) => role != UserRole.admin)
                                  .map(
                                    (role) => ButtonSegment<UserRole>(
                                      value: role,
                                      label: SizedBox(
                                        width: 78,
                                        child: Center(child: Text(role.label)),
                                      ),
                                    ),
                                  )
                                  .toList(),
                              selected: {registerRole},
                              onSelectionChanged: (selection) {
                                setState(() => registerRole = selection.first);
                              },
                            ),
                          ],
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 18),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              onPressed: widget.controller.loading
                                  ? null
                                  : () => isRegister ? _submitRegister() : _submitLogin(),
                              child: widget.controller.loading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : Text(isRegister ? '회원가입' : '로그인'),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            isRegister
                                ? '가입 후 같은 화면에서 바로 로그인할 수 있습니다.'
                                : '테스트 계정이 있으면 이메일과 비밀번호만 입력하면 됩니다.',
                            style: const TextStyle(
                              color: Color(0xFF7B8A90),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submitLogin() async {
    final response = await widget.controller.login(
      email: emailController.text.trim(),
      password: passwordController.text,
      role: selectedRole,
    );
    if (!mounted) return;
    _showMessage(response.message);
  }

  Future<void> _submitRegister() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      _showMessage('모든 항목을 입력해주세요.');
      return;
    }
    if (password.length < 8) {
      _showMessage('비밀번호는 8자 이상이어야 합니다.');
      return;
    }
    if (password != confirmPassword) {
      _showMessage('비밀번호 확인이 일치하지 않습니다.');
      return;
    }

    final response = await widget.controller.register(
      name: name,
      email: email,
      password: password,
      role: registerRole,
    );
    if (!mounted) return;

    _showMessage(response.message);
    if (!response.success) return;

    setState(() {
      mode = AuthMode.login;
    });
    passwordController.clear();
    confirmPasswordController.clear();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class _AuthHighlight extends StatelessWidget {
  const _AuthHighlight({required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: const TextStyle(
              color: Color(0xFFD7ECE8),
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthTextField extends StatelessWidget {
  const _AuthTextField({
    required this.controller,
    required this.label,
    required this.hintText,
    this.focusNode,
    this.nextFocusNode,
    this.keyboardType,
    this.obscureText = false,
  });

  final TextEditingController controller;
  final String label;
  final String hintText;
  final FocusNode? focusNode;
  final FocusNode? nextFocusNode;
  final TextInputType? keyboardType;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      textInputAction:
          nextFocusNode == null ? TextInputAction.done : TextInputAction.next,
      obscureText: obscureText,
      onSubmitted: (_) {
        if (nextFocusNode != null) {
          nextFocusNode!.requestFocus();
        } else {
          FocusScope.of(context).unfocus();
        }
      },
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        filled: true,
        fillColor: const Color(0xFFF7FAF9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFDCE8E4)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF0E7A66), width: 1.4),
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
              onPressed: () => controller.logout(),
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
        return InstructorCourseManagementPage(controller: controller);
      case 3:
        return InstructorTeamAnalysisPage(controller: controller);
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
        final recommendedActions = _asStringList(recommendations['recommendedActions']);

        return ListView(
          children: [
            DashboardHeroCard(
              title: '학습자 대시보드',
              subtitle: _displayText(
                dashboard['coachingMessage'],
                emptyMessage: '아직 학습 데이터가 충분하지 않습니다. 학습을 시작하면 요약이 채워집니다.',
              ),
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                MetricCard(label: '출석률', value: '${_asInt(dashboard['attendanceRate'])}%'),
                MetricCard(label: '진도율', value: '${_asInt(dashboard['progressRate'])}%'),
                MetricCard(label: '이해도', value: '${_asInt(dashboard['understandingScore'])}'),
                MetricCard(
                  label: '위험도',
                  value: _displayText(
                    dashboard['riskLevel'],
                    emptyMessage: '아직 없음',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            InfoCard(
              title: '주간 요약',
              content: _displayText(
                report['weeklySummary'],
                emptyMessage: '이번 주 학습 요약은 아직 없습니다.',
              ),
            ),
            const SizedBox(height: 10),
            InfoCard(
              title: '추천 액션',
              content: recommendedActions.isEmpty
                  ? '추천할 학습 액션이 아직 없습니다.'
                  : recommendedActions.join(' / '),
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
            DashboardHeroCard(
              title: '내 강의 목록',
              subtitle: courses.isEmpty
                  ? '아직 수강 중인 강의가 없습니다.'
                  : '수강 중인 강의 현황을 한눈에 확인할 수 있습니다.',
            ),
            const SizedBox(height: 16),
            if (courses.isEmpty)
              const EmptyStateCard(
                title: '수강 중인 강의가 없습니다',
                description: '강의에 등록되면 이 화면에서 진도와 출석 현황을 볼 수 있습니다.',
              )
            else
              ...courses.map(
                (course) => InfoCard(
                  title: _displayText(course['title'], emptyMessage: '제목 미정'),
                  content:
                      '진도 ${_asInt(course['progressRate'])}% | 출석 ${_asInt(course['attendanceRate'])}% | 미제출 ${_asInt(course['assignmentPendingCount'])}개',
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
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ApiResponse<Map<String, dynamic>>>(
      future: widget.controller.api.getContentDetail(5001),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final content = snapshot.data!.data!;
        final myProgress = (content['myProgress'] as Map<String, dynamic>?) ?? const {};
        final watchedSeconds = _asInt(myProgress['lastPositionSeconds']);
        final durationSeconds = _asInt(content['durationSeconds']);
        final progressRate = _asInt(myProgress['progressRate']);
        final isCompleted = myProgress['isCompleted'] == true || progressRate >= 100;
        return ListView(
          children: [
            const DashboardHeroCard(
              title: '콘텐츠 및 진도',
              subtitle: '시청 기록은 자동 저장됩니다. 학습자는 재생만 하면 됩니다.',
            ),
            const SizedBox(height: 16),
            InfoCard(
              title: _displayText(content['title'], emptyMessage: '콘텐츠 제목 미정'),
              content:
                  '${_displayText(content['description'], emptyMessage: '콘텐츠 설명이 아직 없습니다.')} ($durationSeconds초)',
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFD8E6E2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '현재 시청 상태',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                      Text(
                        isCompleted ? '시청 완료' : '시청 중',
                        style: TextStyle(
                          color: isCompleted ? const Color(0xFF0E7A66) : const Color(0xFF4A6570),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      minHeight: 10,
                      value: (progressRate.clamp(0, 100)) / 100,
                      backgroundColor: const Color(0xFFE4EFEC),
                      valueColor: const AlwaysStoppedAnimation(Color(0xFF0E7A66)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '진도 $progressRate% · $watchedSeconds초 시청',
                    style: const TextStyle(
                      color: Color(0xFF516168),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isCompleted
                        ? '콘텐츠를 끝까지 시청했습니다.'
                        : '마지막 시청 위치부터 이어서 학습할 수 있습니다.',
                    style: const TextStyle(color: Color(0xFF75848A)),
                  ),
                ],
              ),
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
            const DashboardHeroCard(
              title: '과제',
              subtitle: '과제 내용을 확인하고 제출 답변을 작성할 수 있습니다.',
            ),
            const SizedBox(height: 16),
            InfoCard(
              title: _displayText(assignment['title'], emptyMessage: '과제 제목 미정'),
              content: _displayText(
                assignment['description'],
                emptyMessage: '과제 설명이 아직 없습니다.',
              ),
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
                if (!context.mounted) return;
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
        final members = (detail['members'] as List<dynamic>? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map((e) => _displayText(e['name'], emptyMessage: '이름 없음'))
            .toList();
        final teamName = _displayText(
          detail['teamName'] ?? team['teamName'],
          emptyMessage: '배정된 팀이 없습니다',
        );

        return ListView(
          children: [
            DashboardHeroCard(
              title: '팀 활동',
              subtitle: messages.isEmpty
                  ? '팀 활동이 시작되면 대화와 협업 현황이 여기에 표시됩니다.'
                  : '팀원과의 협업 내용과 최근 대화를 확인할 수 있습니다.',
            ),
            const SizedBox(height: 16),
            InfoCard(
              title: '$teamName (협업점수 ${_asInt(detail['collaborationScore'])})',
              content: members.isEmpty
                  ? '아직 표시할 팀원 정보가 없습니다.'
                  : '팀원: ${members.join(', ')}',
            ),
            const SizedBox(height: 12),
            if (messages.isEmpty)
              const EmptyStateCard(
                title: '팀 대화가 아직 없습니다',
                description: '메시지가 쌓이면 이 영역에서 팀 대화를 바로 볼 수 있습니다.',
              )
            else
              ...messages.map(
                (message) => Card(
                  child: ListTile(
                    title: Text(_displayText(message['senderName'], emptyMessage: '알 수 없음')),
                    subtitle: Text(_displayText(message['message'])),
                    trailing: Text(_timeLabel(message['sentAt'])),
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
            const DashboardHeroCard(
              title: '교수자 대시보드',
              subtitle: '강의 전체 현황과 주의가 필요한 학생 수를 빠르게 확인할 수 있습니다.',
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                MetricCard(label: '수강생', value: '${_asInt(data['studentCount'])}'),
                MetricCard(label: '평균 출석', value: '${_asInt(data['averageAttendanceRate'])}%'),
                MetricCard(label: '고위험 학생', value: '${_asInt(data['highRiskStudentCount'])}'),
                MetricCard(
                  label: '저이해 학생',
                  value: '${_asInt(data['lowUnderstandingStudentCount'])}',
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
            const DashboardHeroCard(
              title: '위험/저이해 학생',
              subtitle: '우선 확인이 필요한 학생을 영역별로 나눠 보여줍니다.',
            ),
            const SizedBox(height: 16),
            SectionPanel(
              title: '위험 학생',
              child: risk.isEmpty
                  ? const EmptyStateCard(
                      title: '위험 학생이 없습니다',
                      description: '현재 기준으로 높은 위험도로 분류된 학생이 없습니다.',
                    )
                  : Column(
                      children: risk
                          .map(
                            (student) => ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(_displayText(student['studentName'])),
                              subtitle: Text(
                                '위험도 ${_asInt(student['riskScore'])} (${_displayText(student['riskLevel'])})',
                              ),
                            ),
                          )
                          .toList(),
                    ),
            ),
            const SizedBox(height: 12),
            SectionPanel(
              title: '저이해 학생',
              child: low.isEmpty
                  ? const EmptyStateCard(
                      title: '저이해 학생이 없습니다',
                      description: '현재 기준으로 별도 확인이 필요한 저이해 학생이 없습니다.',
                    )
                  : Column(
                      children: low
                          .map(
                            (student) => ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(_displayText(student['studentName'])),
                              subtitle: Text('점수 ${_asInt(student['understandingScore'])}'),
                            ),
                          )
                          .toList(),
                    ),
            ),
            const SizedBox(height: 12),
            SectionPanel(
              title: '개입 추천',
              child: interventions.isEmpty
                  ? const EmptyStateCard(
                      title: '개입 추천이 없습니다',
                      description: '학생 데이터가 더 쌓이면 개입 추천이 표시됩니다.',
                    )
                  : Column(
                      children: interventions
                          .map(
                            (item) => ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(_displayText(item['studentName'])),
                              subtitle: Text(_displayText(item['recommendedAction'])),
                            ),
                          )
                          .toList(),
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

class InstructorCourseManagementPage extends StatefulWidget {
  const InstructorCourseManagementPage({super.key, required this.controller});

  final AppController controller;

  @override
  State<InstructorCourseManagementPage> createState() => _InstructorCourseManagementPageState();
}

class _InstructorCourseManagementPageState extends State<InstructorCourseManagementPage> {
  final TextEditingController courseTitleController = TextEditingController();
  final TextEditingController courseDescriptionController = TextEditingController();
  final TextEditingController courseThumbnailController = TextEditingController();
  final TextEditingController courseStartDateController = TextEditingController(text: '2026-05-01');
  final TextEditingController courseEndDateController = TextEditingController(text: '2026-06-30');
  final TextEditingController weekNumberController = TextEditingController(text: '1');
  final TextEditingController weekTitleController = TextEditingController();
  final TextEditingController weekOpenAtController = TextEditingController(
    text: '2026-05-01T09:00:00Z',
  );
  final TextEditingController contentTitleController = TextEditingController();
  final TextEditingController contentDescriptionController = TextEditingController();
  final TextEditingController contentVideoUrlController = TextEditingController();
  final TextEditingController contentDocumentUrlController = TextEditingController();
  final TextEditingController contentDurationController = TextEditingController(text: '1800');
  final TextEditingController contentScheduledAtController = TextEditingController(
    text: '2026-05-01T09:00:00Z',
  );
  final TextEditingController contentOpenAtController = TextEditingController(
    text: '2026-05-01T09:00:00Z',
  );

  int refreshSeed = 0;
  int? selectedCourseId;
  int? selectedWeekId;
  String selectedContentType = 'VOD';
  bool isSequentialRelease = false;

  @override
  void dispose() {
    courseTitleController.dispose();
    courseDescriptionController.dispose();
    courseThumbnailController.dispose();
    courseStartDateController.dispose();
    courseEndDateController.dispose();
    weekNumberController.dispose();
    weekTitleController.dispose();
    weekOpenAtController.dispose();
    contentTitleController.dispose();
    contentDescriptionController.dispose();
    contentVideoUrlController.dispose();
    contentDocumentUrlController.dispose();
    contentDurationController.dispose();
    contentScheduledAtController.dispose();
    contentOpenAtController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ApiResponse<List<Map<String, dynamic>>>>(
      future: widget.controller.api.getMyCourses(),
      key: ValueKey(refreshSeed),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final courses = snapshot.data!.data ?? [];
        if (selectedCourseId == null && courses.isNotEmpty) {
          selectedCourseId = _asInt(courses.first['courseId']);
        }

        return ListView(
          children: [
            const DashboardHeroCard(
              title: '강의 관리',
              subtitle: '강의를 만들고, 주차를 구성하고, VOD/LIVE/DOCUMENT 콘텐츠를 등록할 수 있습니다.',
            ),
            const SizedBox(height: 16),
            SectionPanel(
              title: '새 강의 만들기',
              child: Column(
                children: [
                  _AuthTextField(
                    controller: courseTitleController,
                    label: '강의 제목',
                    hintText: '예: 생성형 AI 입문',
                  ),
                  const SizedBox(height: 12),
                  _AuthTextField(
                    controller: courseDescriptionController,
                    label: '강의 설명',
                    hintText: '강의 소개를 입력하세요',
                  ),
                  const SizedBox(height: 12),
                  _AuthTextField(
                    controller: courseThumbnailController,
                    label: '썸네일 URL',
                    hintText: 'https://example.com/course.png',
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _AuthTextField(
                          controller: courseStartDateController,
                          label: '시작일',
                          hintText: '2026-05-01',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _AuthTextField(
                          controller: courseEndDateController,
                          label: '종료일',
                          hintText: '2026-06-30',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    value: isSequentialRelease,
                    contentPadding: EdgeInsets.zero,
                    title: const Text('순차 공개 강의'),
                    subtitle: const Text('주차별 오픈 일정에 맞춰 콘텐츠를 공개합니다.'),
                    onChanged: (value) => setState(() => isSequentialRelease = value),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: FilledButton(
                      onPressed: _createCourse,
                      child: const Text('강의 생성'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SectionPanel(
              title: '내 강의',
              child: courses.isEmpty
                  ? const EmptyStateCard(
                      title: '등록된 강의가 없습니다',
                      description: '첫 강의를 만들면 여기에서 주차와 콘텐츠를 계속 관리할 수 있습니다.',
                    )
                  : Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: courses
                          .map(
                            (course) => SizedBox(
                              width: 280,
                              child: _SelectionCard(
                                title: _displayText(course['title'], emptyMessage: '제목 미정'),
                                description:
                                    '진도 ${_asInt(course['progressRate'])}% · 출석 ${_asInt(course['attendanceRate'])}%',
                                selected: _asInt(course['courseId']) == selectedCourseId,
                                onTap: () {
                                  setState(() {
                                    selectedCourseId = _asInt(course['courseId']);
                                    selectedWeekId = null;
                                  });
                                },
                              ),
                            ),
                          )
                          .toList(),
                    ),
            ),
            const SizedBox(height: 16),
            if (selectedCourseId != null) _buildSelectedCourseDetail(selectedCourseId!),
          ],
        );
      },
    );
  }

  Widget _buildSelectedCourseDetail(int courseId) {
    return FutureBuilder<ApiResponse<Map<String, dynamic>>>(
      future: widget.controller.api.getCourseDetail(courseId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final course = snapshot.data!.data ?? {};
        final weeks = ((course['weeks'] as List<dynamic>?) ?? const [])
            .whereType<Map<String, dynamic>>()
            .toList();
        if (selectedWeekId == null && weeks.isNotEmpty) {
          selectedWeekId = _asInt(weeks.first['weekId']);
        }

        return Column(
          children: [
            SectionPanel(
              title: '선택한 강의',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InfoCard(
                    title: _displayText(course['title'], emptyMessage: '강의 제목 미정'),
                    content: _displayText(
                      course['description'],
                      emptyMessage: '강의 설명이 아직 없습니다.',
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '주차 생성',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _AuthTextField(
                          controller: weekNumberController,
                          label: '주차 번호',
                          hintText: '1',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: _AuthTextField(
                          controller: weekTitleController,
                          label: '주차 제목',
                          hintText: '예: 1주차 오리엔테이션',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _AuthTextField(
                    controller: weekOpenAtController,
                    label: '오픈 시각',
                    hintText: '2026-05-01T09:00:00Z',
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: FilledButton(
                      onPressed: () => _createWeek(courseId),
                      child: const Text('주차 생성'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SectionPanel(
              title: '주차 목록',
              child: weeks.isEmpty
                  ? const EmptyStateCard(
                      title: '아직 주차가 없습니다',
                      description: '먼저 주차를 만든 뒤 그 안에 콘텐츠를 등록하세요.',
                    )
                  : Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: weeks
                          .map(
                            (week) => SizedBox(
                              width: 240,
                              child: _SelectionCard(
                                title:
                                    '${_asInt(week['weekNumber'])}주차 · ${_displayText(week['title'])}',
                                description: 'weekId ${_asInt(week['weekId'])}',
                                selected: _asInt(week['weekId']) == selectedWeekId,
                                onTap: () {
                                  setState(() {
                                    selectedWeekId = _asInt(week['weekId']);
                                  });
                                },
                              ),
                            ),
                          )
                          .toList(),
                    ),
            ),
            const SizedBox(height: 16),
            if (selectedWeekId != null) _buildContentManager(courseId, selectedWeekId!),
          ],
        );
      },
    );
  }

  Widget _buildContentManager(int courseId, int weekId) {
    return FutureBuilder<ApiResponse<List<Map<String, dynamic>>>>(
      future: widget.controller.api.getWeekContents(courseId, weekId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final contents = snapshot.data!.data ?? [];

        return SectionPanel(
          title: '콘텐츠 등록',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'VOD', label: Text('VOD')),
                  ButtonSegment(value: 'LIVE', label: Text('LIVE')),
                  ButtonSegment(value: 'DOCUMENT', label: Text('문서')),
                ],
                selected: {selectedContentType},
                onSelectionChanged: (selection) {
                  setState(() => selectedContentType = selection.first);
                },
              ),
              const SizedBox(height: 12),
              _AuthTextField(
                controller: contentTitleController,
                label: '콘텐츠 제목',
                hintText: '예: 1주차 강의 영상',
              ),
              const SizedBox(height: 12),
              _AuthTextField(
                controller: contentDescriptionController,
                label: '콘텐츠 설명',
                hintText: '콘텐츠 소개를 입력하세요',
              ),
              if (selectedContentType == 'VOD') ...[
                const SizedBox(height: 12),
                _AuthTextField(
                  controller: contentVideoUrlController,
                  label: '영상 URL',
                  hintText: 'https://cdn.example.com/video.mp4',
                ),
                const SizedBox(height: 12),
                _AuthTextField(
                  controller: contentDurationController,
                  label: '영상 길이(초)',
                  hintText: '1800',
                ),
              ],
              if (selectedContentType == 'DOCUMENT') ...[
                const SizedBox(height: 12),
                _AuthTextField(
                  controller: contentDocumentUrlController,
                  label: '문서 URL',
                  hintText: 'https://cdn.example.com/handout.pdf',
                ),
              ],
              if (selectedContentType == 'LIVE') ...[
                const SizedBox(height: 12),
                _AuthTextField(
                  controller: contentScheduledAtController,
                  label: '실시간 수업 시각',
                  hintText: '2026-05-01T09:00:00Z',
                ),
              ],
              const SizedBox(height: 12),
              _AuthTextField(
                controller: contentOpenAtController,
                label: '공개 시각',
                hintText: '2026-05-01T09:00:00Z',
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: FilledButton(
                  onPressed: () => _createContent(weekId),
                  child: const Text('콘텐츠 등록'),
                ),
              ),
              const SizedBox(height: 18),
              if (contents.isEmpty)
                const EmptyStateCard(
                  title: '등록된 콘텐츠가 없습니다',
                  description: '현재 선택한 주차에 첫 콘텐츠를 등록해보세요.',
                )
              else
                ...contents.map(
                  (content) => InfoCard(
                    title:
                        '${_displayText(content['title'])} · ${_displayText(content['type'])}',
                    content: _displayText(
                      content['description'],
                      emptyMessage: '설명이 없습니다.',
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _createCourse() async {
    final response = await widget.controller.api.createCourse(
      title: courseTitleController.text.trim(),
      description: courseDescriptionController.text.trim(),
      thumbnailUrl: courseThumbnailController.text.trim(),
      startDate: courseStartDateController.text.trim(),
      endDate: courseEndDateController.text.trim(),
      isSequentialRelease: isSequentialRelease,
    );
    _notify(response.message);
    if (!response.success) return;
    setState(() {
      refreshSeed++;
    });
  }

  Future<void> _createWeek(int courseId) async {
    final response = await widget.controller.api.createWeek(
      courseId: courseId,
      weekNumber: int.tryParse(weekNumberController.text.trim()) ?? 1,
      title: weekTitleController.text.trim(),
      openAt: weekOpenAtController.text.trim(),
    );
    _notify(response.message);
    if (!response.success) return;
    setState(() {
      refreshSeed++;
    });
  }

  Future<void> _createContent(int weekId) async {
    final response = await widget.controller.api.createContent(
      weekId: weekId,
      type: selectedContentType,
      title: contentTitleController.text.trim(),
      description: contentDescriptionController.text.trim(),
      videoUrl: contentVideoUrlController.text.trim().isEmpty
          ? null
          : contentVideoUrlController.text.trim(),
      documentUrl: contentDocumentUrlController.text.trim().isEmpty
          ? null
          : contentDocumentUrlController.text.trim(),
      durationSeconds: int.tryParse(contentDurationController.text.trim()),
      scheduledAt: contentScheduledAtController.text.trim().isEmpty
          ? null
          : contentScheduledAtController.text.trim(),
      openAt: contentOpenAtController.text.trim(),
    );
    _notify(response.message);
    if (!response.success) return;
    setState(() {
      refreshSeed++;
    });
  }

  void _notify(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}

class InstructorTeamAnalysisPage extends StatefulWidget {
  const InstructorTeamAnalysisPage({super.key, required this.controller});

  final AppController controller;

  @override
  State<InstructorTeamAnalysisPage> createState() => _InstructorTeamAnalysisPageState();
}

class _InstructorTeamAnalysisPageState extends State<InstructorTeamAnalysisPage> {
  final TextEditingController teamSizeController = TextEditingController(text: '3');
  int refreshSeed = 0;
  int? selectedCourseId;
  int? selectedTeamId;

  @override
  void dispose() {
    teamSizeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ApiResponse<List<Map<String, dynamic>>>>(
      future: widget.controller.api.getMyCourses(),
      key: ValueKey(refreshSeed),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final courses = snapshot.data!.data ?? [];
        if (selectedCourseId == null && courses.isNotEmpty) {
          selectedCourseId = _asInt(courses.first['courseId']);
        }

        return ListView(
          children: [
            const DashboardHeroCard(
              title: '팀 분석',
              subtitle: '강의별 팀 편성 현황과 협업 지표, 팀원 기여도를 확인할 수 있습니다.',
            ),
            const SizedBox(height: 16),
            SectionPanel(
              title: '분석할 강의 선택',
              child: courses.isEmpty
                  ? const EmptyStateCard(
                      title: '분석할 강의가 없습니다',
                      description: '팀 분석은 강의가 있고 수강생이 있을 때 사용할 수 있습니다.',
                    )
                  : Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: courses
                          .map(
                            (course) => SizedBox(
                              width: 280,
                              child: _SelectionCard(
                                title: _displayText(course['title']),
                                description: _displayText(
                                  course['description'],
                                  emptyMessage: '설명이 없습니다.',
                                ),
                                selected: _asInt(course['courseId']) == selectedCourseId,
                                onTap: () {
                                  setState(() {
                                    selectedCourseId = _asInt(course['courseId']);
                                    selectedTeamId = null;
                                  });
                                },
                              ),
                            ),
                          )
                          .toList(),
                    ),
            ),
            const SizedBox(height: 16),
            if (selectedCourseId != null) _buildTeamAnalysis(selectedCourseId!),
          ],
        );
      },
    );
  }

  Widget _buildTeamAnalysis(int courseId) {
    return FutureBuilder<ApiResponse<List<Map<String, dynamic>>>>(
      future: widget.controller.api.getCourseTeams(courseId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final teams = snapshot.data!.data ?? [];
        if (selectedTeamId == null && teams.isNotEmpty) {
          selectedTeamId = _asInt(teams.first['teamId']);
        }

        return Column(
          children: [
            SectionPanel(
              title: '팀 자동 구성',
              child: Row(
                children: [
                  Expanded(
                    child: _AuthTextField(
                      controller: teamSizeController,
                      label: '팀 크기',
                      hintText: '3',
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    onPressed: () => _autoGroup(courseId),
                    child: const Text('자동 배정'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SectionPanel(
              title: '팀 목록',
              child: teams.isEmpty
                  ? const EmptyStateCard(
                      title: '팀이 아직 없습니다',
                      description: '자동 배정 후 팀별 협업 지표를 확인할 수 있습니다.',
                    )
                  : Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: teams
                          .map(
                            (team) => SizedBox(
                              width: 220,
                              child: _SelectionCard(
                                title: _displayText(team['name']),
                                description:
                                    '인원 ${_asInt(team['memberCount'])}명 · ${_displayText(team['status'])}',
                                selected: _asInt(team['teamId']) == selectedTeamId,
                                onTap: () {
                                  setState(() {
                                    selectedTeamId = _asInt(team['teamId']);
                                  });
                                },
                              ),
                            ),
                          )
                          .toList(),
                    ),
            ),
            const SizedBox(height: 16),
            if (selectedTeamId != null) _buildSelectedTeamDetail(selectedTeamId!),
          ],
        );
      },
    );
  }

  Widget _buildSelectedTeamDetail(int teamId) {
    return FutureBuilder<List<ApiResponse<dynamic>>>(
      future: Future.wait<ApiResponse<dynamic>>([
        widget.controller.api.getTeamAnalytics(teamId),
        widget.controller.api.getTeamMemberContributions(teamId),
      ]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final analytics = snapshot.data![0].data as Map<String, dynamic>? ?? {};
        final contributions = snapshot.data![1].data as List<Map<String, dynamic>>? ?? [];
        final riskSignals = _asStringList(analytics['riskSignals']);

        return Column(
          children: [
            SectionPanel(
              title: '팀 협업 지표',
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  MetricCard(
                    label: '협업 점수',
                    value: '${_asInt(analytics['collaborationScore'])}',
                  ),
                  MetricCard(
                    label: '대화 균형',
                    value: '${_asInt(analytics['conversationBalanceScore'])}',
                  ),
                  MetricCard(
                    label: '비활성 인원',
                    value: '${_asInt(analytics['inactiveMemberCount'])}',
                  ),
                  MetricCard(
                    label: '주도 인원',
                    value: '${_asInt(analytics['dominantMemberCount'])}',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SectionPanel(
              title: '리스크 신호',
              child: riskSignals.isEmpty
                  ? const EmptyStateCard(
                      title: '리스크 신호가 없습니다',
                      description: '현재 팀 대화와 활동 기준으로 특별한 경고 신호가 없습니다.',
                    )
                  : Column(
                      children: riskSignals
                          .map(
                            (signal) => ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(Icons.flag_outlined),
                              title: Text(signal),
                            ),
                          )
                          .toList(),
                    ),
            ),
            const SizedBox(height: 16),
            SectionPanel(
              title: '팀원 기여도',
              child: contributions.isEmpty
                  ? const EmptyStateCard(
                      title: '기여도 데이터가 없습니다',
                      description: '메시지와 협업 활동이 쌓이면 팀원별 기여도가 표시됩니다.',
                    )
                  : Column(
                      children: contributions
                          .map(
                            (item) => ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(_displayText(item['name'])),
                              subtitle: Text(
                                '메시지 ${_asInt(item['messageCount'])}개 · 기여도 ${_asInt(item['contributionScore'])}',
                              ),
                            ),
                          )
                          .toList(),
                    ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _autoGroup(int courseId) async {
    final response = await widget.controller.api.autoGroupTeams(
      courseId: courseId,
      teamSize: int.tryParse(teamSizeController.text.trim()) ?? 3,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response.message)));
    if (!response.success) return;
    setState(() {
      refreshSeed++;
    });
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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDCE8E4)),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withValues(alpha: 0.08),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDCE8E4)),
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

class DashboardHeroCard extends StatelessWidget {
  const DashboardHeroCard({super.key, required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF0F7A66), Color(0xFF0B5F6D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(
              color: Color(0xFFD7F0EA),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class EmptyStateCard extends StatelessWidget {
  const EmptyStateCard({super.key, required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDCE8E4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.inbox_outlined, color: Color(0xFF6D8484)),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: const TextStyle(color: Color(0xFF6A7A80), height: 1.5),
          ),
        ],
      ),
    );
  }
}

class SectionPanel extends StatelessWidget {
  const SectionPanel({super.key, required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFDCE8E4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _SelectionCard extends StatelessWidget {
  const _SelectionCard({
    required this.title,
    required this.description,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String description;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFEAF7F3) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? const Color(0xFF0E7A66) : const Color(0xFFDCE8E4),
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(color: Color(0xFF64757B), height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

int _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse('$value') ?? 0;
}

String _displayText(dynamic value, {String emptyMessage = '아직 정보가 없습니다.'}) {
  final text = value?.toString().trim() ?? '';
  if (text.isEmpty || text.toLowerCase() == 'null') {
    return emptyMessage;
  }
  return text;
}

List<String> _asStringList(dynamic value) {
  if (value is List) {
    return value
        .map((item) => item?.toString().trim() ?? '')
        .where((item) => item.isNotEmpty && item.toLowerCase() != 'null')
        .toList();
  }
  return const [];
}

String _timeLabel(dynamic value) {
  final text = value?.toString() ?? '';
  if (text.length >= 16) return text.substring(11, 16);
  return '방금 전';
}
