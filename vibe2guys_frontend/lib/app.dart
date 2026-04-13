import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;

import 'core/api_client.dart';
import 'core/api_contract.dart';
import 'core/http_api_client.dart';
import 'core/mock_api_client.dart';

const bool kShowDeveloperApi = bool.fromEnvironment(
  'SHOW_DEV_API',
  defaultValue: false,
);

class LearnSightApp extends StatefulWidget {
  const LearnSightApp({super.key});

  @override
  State<LearnSightApp> createState() => _LearnSightAppState();
}

class _LearnSightAppState extends State<LearnSightApp> {
  final AppController controller = AppController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LearnSight',
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
  final ApiClient api =
      const bool.fromEnvironment('USE_REAL_API', defaultValue: false)
          ? HttpApiClient()
          : MockApiClient();
  bool _loading = false;
  int selectedIndex = 0;
  bool showingMyPage = false;
  final Map<int, String> _teamAliases = {};

  bool get loading => _loading;
  bool get isAuthenticated =>
      api.currentUser != null && api.accessToken != null;
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
    final response =
        await api.login(email: email, password: password, role: role);
    _loading = false;
    notifyListeners();
    return response;
  }

  Future<void> logout() async {
    await api.logout();
    selectedIndex = 0;
    showingMyPage = false;
    notifyListeners();
  }

  void setSelectedIndex(int index) {
    selectedIndex = index;
    showingMyPage = false;
    notifyListeners();
  }

  void openMyPage() {
    showingMyPage = true;
    notifyListeners();
  }

  void refreshUser() {
    notifyListeners();
  }

  String teamAlias(int teamId, String fallback) {
    return _teamAliases[teamId]?.trim().isNotEmpty == true
        ? _teamAliases[teamId]!
        : fallback;
  }

  void setTeamAlias(int teamId, String alias) {
    final normalized = alias.trim();
    if (normalized.isEmpty) {
      _teamAliases.remove(teamId);
    } else {
      _teamAliases[teamId] = normalized;
    }
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

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final FocusNode nameFocusNode = FocusNode();
  final FocusNode emailFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();
  final FocusNode confirmPasswordFocusNode = FocusNode();
  late final AnimationController shakeController;
  AuthMode mode = AuthMode.login;
  UserRole selectedRole = UserRole.student;
  UserRole registerRole = UserRole.student;
  String? loginEmailError;
  String? loginPasswordError;

  @override
  void initState() {
    super.initState();
    shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 360),
    );
  }

  @override
  void dispose() {
    shakeController.dispose();
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
                        borderRadius:
                            BorderRadius.horizontal(left: Radius.circular(28)),
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
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: const Text(
                              'AI Learning Analytics Platform',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(height: 22),
                          const Text(
                            'LearnSight',
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
                                ? '몇 가지 정보만 입력하면 LearnSight 계정을 바로 만들 수 있습니다.'
                                : 'LearnSight에서 학습 상태를 확인하고 강의 데이터를 한 화면에서 관리할 수 있습니다.',
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
                      child: AnimatedBuilder(
                        animation: shakeController,
                        builder: (context, child) {
                          final progress = shakeController.value;
                          final offset = progress < 1
                              ? (1 - progress) *
                                  10 *
                                  (progress < 0.25 ||
                                          (progress >= 0.5 && progress < 0.75)
                                      ? 1
                                      : -1)
                              : 0.0;
                          return Transform.translate(
                            offset: Offset(offset, 0),
                            child: child,
                          );
                        },
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
                                    setState(() {
                                      mode = selection.first;
                                      loginEmailError = null;
                                      loginPasswordError = null;
                                    });
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
                              errorText: !isRegister ? loginEmailError : null,
                              onChanged: !isRegister
                                  ? (_) {
                                      if (loginEmailError != null) {
                                        setState(() => loginEmailError = null);
                                      }
                                    }
                                  : null,
                            ),
                            const SizedBox(height: 14),
                            _AuthTextField(
                              focusNode: passwordFocusNode,
                              nextFocusNode:
                                  isRegister ? confirmPasswordFocusNode : null,
                              controller: passwordController,
                              label: '비밀번호',
                              hintText:
                                  isRegister ? '8자 이상 비밀번호' : '비밀번호를 입력하세요',
                              obscureText: true,
                              errorText:
                                  !isRegister ? loginPasswordError : null,
                              onChanged: !isRegister
                                  ? (_) {
                                      if (loginPasswordError != null) {
                                        setState(
                                            () => loginPasswordError = null);
                                      }
                                    }
                                  : null,
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
                                          child:
                                              Center(child: Text(role.label)),
                                        ),
                                      ),
                                    )
                                    .toList(),
                                selected: {selectedRole},
                                onSelectionChanged: (selection) {
                                  setState(
                                      () => selectedRole = selection.first);
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
                                          child:
                                              Center(child: Text(role.label)),
                                        ),
                                      ),
                                    )
                                    .toList(),
                                selected: {registerRole},
                                onSelectionChanged: (selection) {
                                  setState(
                                      () => registerRole = selection.first);
                                },
                              ),
                            ],
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                style: FilledButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 18),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                onPressed: widget.controller.loading
                                    ? null
                                    : () => isRegister
                                        ? _submitRegister()
                                        : _submitLogin(),
                                child: widget.controller.loading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2),
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
    final email = emailController.text.trim();
    final password = passwordController.text;
    String? nextEmailError;
    String? nextPasswordError;

    if (email.isEmpty) {
      nextEmailError = '이메일을 입력해주세요.';
    } else if (!email.contains('@')) {
      nextEmailError = '올바른 이메일 형식을 입력해주세요.';
    }
    if (password.isEmpty) {
      nextPasswordError = '비밀번호를 입력해주세요.';
    }

    if (nextEmailError != null || nextPasswordError != null) {
      setState(() {
        loginEmailError = nextEmailError;
        loginPasswordError = nextPasswordError;
      });
      _triggerLoginShake();
      return;
    }

    final response = await widget.controller.login(
      email: email,
      password: password,
      role: selectedRole,
    );
    if (!mounted) return;
    if (response.success) {
      setState(() {
        loginEmailError = null;
        loginPasswordError = null;
      });
      return;
    }

    setState(() {
      if (response.message.contains('이메일')) {
        loginEmailError = response.message;
        loginPasswordError = null;
      } else if (response.message.contains('비밀번호')) {
        loginPasswordError = response.message;
      } else {
        loginPasswordError = '이메일 또는 비밀번호를 확인해주세요.';
      }
    });
    _triggerLoginShake();
  }

  Future<void> _submitRegister() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
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

  void _triggerLoginShake() {
    shakeController.forward(from: 0);
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
    this.errorText,
    this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final String hintText;
  final FocusNode? focusNode;
  final FocusNode? nextFocusNode;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String? errorText;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      textInputAction:
          nextFocusNode == null ? TextInputAction.done : TextInputAction.next,
      obscureText: obscureText,
      onChanged: onChanged,
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
        errorText: errorText,
        errorMaxLines: 2,
        errorStyle: const TextStyle(
          color: Color(0xFFC43C35),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFC43C35), width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFC43C35), width: 1.4),
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
    final items = role == UserRole.student
        ? [
            const _NavItem('대시보드', Icons.space_dashboard_rounded),
            const _NavItem('내 강의', Icons.menu_book_rounded),
            const _NavItem('강의 신청', Icons.search_rounded),
            const _NavItem('콘텐츠', Icons.play_circle_outline_rounded),
            const _NavItem('과제', Icons.assignment_rounded),
            const _NavItem('팀 활동', Icons.groups_rounded),
            if (kShowDeveloperApi) const _NavItem('API 규칙', Icons.code_rounded),
          ]
        : [
            const _NavItem('교수자 대시보드', Icons.analytics_rounded),
            const _NavItem('수강생 관리', Icons.school_rounded),
            const _NavItem('강의 관리', Icons.edit_note_rounded),
            const _NavItem('팀 분석', Icons.hub_rounded),
            if (kShowDeveloperApi) const _NavItem('API 규칙', Icons.code_rounded),
          ];
    final currentIndex =
        controller.selectedIndex >= items.length ? 0 : controller.selectedIndex;
    return Scaffold(
      body: Row(
        children: [
          Container(
            width: 132,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFF9FFFC), Color(0xFFF0F8FF)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              border: Border(
                right: BorderSide(
                  color: const Color(0xFFD7E7E2).withValues(alpha: 0.9),
                ),
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x120A3A33),
                  blurRadius: 20,
                  offset: Offset(6, 0),
                ),
              ],
            ),
            child: NavigationRail(
              selectedIndex: currentIndex,
              minWidth: 92,
              groupAlignment: -0.85,
              backgroundColor: Colors.transparent,
              indicatorColor: const Color(0xFFDDF6ED),
              selectedIconTheme: const IconThemeData(
                color: Color(0xFF0E7A66),
                size: 24,
              ),
              unselectedIconTheme: const IconThemeData(
                color: Color(0xFF64757B),
                size: 22,
              ),
              selectedLabelTextStyle: const TextStyle(
                color: Color(0xFF0E5C63),
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
              unselectedLabelTextStyle: const TextStyle(
                color: Color(0xFF6A7A80),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              labelType: NavigationRailLabelType.all,
              onDestinationSelected: controller.setSelectedIndex,
              leading: Padding(
                padding: const EdgeInsets.fromLTRB(10, 12, 10, 18),
                child: InkWell(
                  onTap: controller.openMyPage,
                  borderRadius: BorderRadius.circular(22),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: controller.showingMyPage
                          ? const Color(0xFFE7F7F0)
                          : Colors.white.withValues(alpha: 0.86),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: controller.showingMyPage
                            ? const Color(0xFF0E7A66)
                            : const Color(0xFFD7E7E2),
                      ),
                    ),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: Colors.teal.shade700,
                          backgroundImage: _profileImageProvider(
                              controller.user?.profileImageUrl),
                          child: _profileImageProvider(
                                      controller.user?.profileImageUrl) ==
                                  null
                              ? Text(
                                  controller.user!.name.characters.first,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          controller.user!.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF14353C),
                          ),
                        ),
                        const SizedBox(height: 3),
                        const Text(
                          '내 프로필',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0E7A66),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              trailing: Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFD7E7E2)),
                ),
                child: IconButton(
                  onPressed: () => controller.logout(),
                  icon: const Icon(Icons.logout_rounded),
                  tooltip: '로그아웃',
                ),
              ),
              destinations: items
                  .map(
                    (item) => NavigationRailDestination(
                      icon: Icon(item.icon),
                      selectedIcon: Icon(item.icon),
                      label: Text(item.label, textAlign: TextAlign.center),
                    ),
                  )
                  .toList(),
            ),
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
    if (controller.showingMyPage) {
      return MyPage(controller: controller);
    }
    if (role == UserRole.student) {
      switch (selectedIndex) {
        case 0:
          return StudentDashboardPage(controller: controller);
        case 1:
          return StudentMyCoursesPage(controller: controller);
        case 2:
          return StudentCourseCatalogPage(controller: controller);
        case 3:
          return StudentContentPage(controller: controller);
        case 4:
          return StudentAssignmentPage(controller: controller);
        case 5:
          return StudentTeamPage(controller: controller);
        case 6:
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
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());
        final responses = snapshot.data!;
        final dashboard = responses[0].data as Map<String, dynamic>;
        final report = responses[1].data as Map<String, dynamic>;
        final recommendations = responses[2].data as Map<String, dynamic>;
        final recommendedActions =
            _asStringList(recommendations['recommendedActions']);

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
                MetricCard(
                    label: '출석률',
                    value: '${_asInt(dashboard['attendanceRate'])}%'),
                MetricCard(
                    label: '진도율',
                    value: '${_asInt(dashboard['progressRate'])}%'),
                MetricCard(
                    label: '이해도',
                    value: '${_asInt(dashboard['understandingScore'])}'),
                MetricCard(
                  label: '위험도',
                  value: _displayText(
                    dashboard['riskLevel'],
                    emptyMessage: '아직 없음',
                  ),
                  tone: _statusToneFor(
                    '위험도',
                    _displayText(dashboard['riskLevel'], emptyMessage: '아직 없음'),
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

class StudentMyCoursesPage extends StatefulWidget {
  const StudentMyCoursesPage({super.key, required this.controller});
  final AppController controller;

  @override
  State<StudentMyCoursesPage> createState() => _StudentMyCoursesPageState();
}

class _StudentMyCoursesPageState extends State<StudentMyCoursesPage> {
  int? selectedCourseId;
  int? selectedWeekId;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ApiResponse<List<Map<String, dynamic>>>>(
      future: widget.controller.api.getMyCourses(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final courses = snapshot.data!.data ?? [];
        if (selectedCourseId == null && courses.isNotEmpty) {
          selectedCourseId = _asInt(courses.first['courseId']);
        }
        return ListView(
          children: [
            const DashboardHeroCard(
              title: '내 강의',
              subtitle: '수강 중인 강의를 선택하면 강의 개요와 주차별 학습 구성을 바로 볼 수 있습니다.',
            ),
            const SizedBox(height: 16),
            SectionPanel(
              title: '수강 중인 강의',
              child: courses.isEmpty
                  ? const EmptyStateCard(
                      title: '수강 중인 강의가 없습니다',
                      description: '강의 신청 메뉴에서 공개 강의를 찾거나 강의 코드로 등록할 수 있습니다.',
                    )
                  : Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: courses.map((course) {
                        return SizedBox(
                          width: 280,
                          child: _SelectionCard(
                            title: _displayText(course['title']),
                            description:
                                '진도 ${_asInt(course['progressRate'])}% · 출석 ${_asInt(course['attendanceRate'])}%\n강의 코드 ${_displayText(course['courseCode'], emptyMessage: '-')}',
                            selected:
                                _asInt(course['courseId']) == selectedCourseId,
                            onTap: () {
                              setState(() {
                                selectedCourseId = _asInt(course['courseId']);
                                selectedWeekId = null;
                              });
                            },
                          ),
                        );
                      }).toList(),
                    ),
            ),
            const SizedBox(height: 16),
            if (selectedCourseId != null)
              _StudentCourseOverview(
                controller: widget.controller,
                courseId: selectedCourseId!,
                selectedWeekId: selectedWeekId,
                onWeekSelected: (weekId) =>
                    setState(() => selectedWeekId = weekId),
                heroTitle: '강의 구성',
                heroSubtitle: '강의 개요와 주차별 콘텐츠를 확인할 수 있습니다.',
              ),
            const SizedBox(height: 10),
            const EndpointChip(label: 'GET ${Endpoints.coursesMy}'),
            EndpointChip(label: 'GET ${Endpoints.courseDetail(101)}'),
            EndpointChip(label: 'GET ${Endpoints.weekContents(101, 1001)}'),
          ],
        );
      },
    );
  }
}

class StudentCourseCatalogPage extends StatefulWidget {
  const StudentCourseCatalogPage({super.key, required this.controller});
  final AppController controller;

  @override
  State<StudentCourseCatalogPage> createState() =>
      _StudentCourseCatalogPageState();
}

class _StudentCourseCatalogPageState extends State<StudentCourseCatalogPage> {
  final TextEditingController searchController = TextEditingController();
  final TextEditingController courseCodeController = TextEditingController();
  int refreshSeed = 0;
  bool enrollingByCode = false;
  Set<int> enrollingCourseIds = <int>{};
  int? selectedCourseId;
  int? selectedWeekId;

  @override
  void dispose() {
    searchController.dispose();
    courseCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ApiResponse<List<Map<String, dynamic>>>>(
      key: ValueKey(refreshSeed),
      future: widget.controller.api
          .getCourses(keyword: searchController.text.trim()),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final courses = snapshot.data!.data ?? [];
        if (selectedCourseId == null && courses.isNotEmpty) {
          selectedCourseId = _asInt(courses.first['courseId']);
        }
        return ListView(
          children: [
            const DashboardHeroCard(
              title: '강의 신청',
              subtitle: '공개 강의를 찾아 내용을 미리 보고 수강신청하거나, 비공개 강의는 코드로 등록할 수 있습니다.',
            ),
            const SizedBox(height: 16),
            SectionPanel(
              title: '강의 코드로 등록',
              child: Column(
                children: [
                  _AuthTextField(
                    controller: courseCodeController,
                    label: '강의 코드',
                    hintText: '예: CRS-A1B2C3D4',
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: FilledButton(
                      onPressed: enrollingByCode ? null : _enrollByCode,
                      child: Text(enrollingByCode ? '등록 중...' : '코드로 등록'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SectionPanel(
              title: '공개 강의 목록',
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _AuthTextField(
                          controller: searchController,
                          label: '강의 제목 검색',
                          hintText: '예: 생성형 AI',
                        ),
                      ),
                      const SizedBox(width: 12),
                      FilledButton.tonal(
                        onPressed: () => setState(() => refreshSeed++),
                        child: const Text('검색'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (courses.isEmpty)
                    const EmptyStateCard(
                      title: '검색된 공개 강의가 없습니다',
                      description: '강의 제목을 바꿔 검색해보세요.',
                    )
                  else
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: courses
                          .map(
                            (course) => SizedBox(
                              width: 280,
                              child: _SelectionCard(
                                title: _displayText(course['title']),
                                description:
                                    '${_displayText(course['instructorName'])}\n${_displayText(course['description'], emptyMessage: '강의 설명이 없습니다.')}',
                                selected: _asInt(course['courseId']) ==
                                    selectedCourseId,
                                onTap: () {
                                  setState(() {
                                    selectedCourseId =
                                        _asInt(course['courseId']);
                                    selectedWeekId = null;
                                  });
                                },
                              ),
                            ),
                          )
                          .toList(),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (selectedCourseId != null)
              _StudentCourseOverview(
                controller: widget.controller,
                courseId: selectedCourseId!,
                selectedWeekId: selectedWeekId,
                onWeekSelected: (weekId) =>
                    setState(() => selectedWeekId = weekId),
                heroTitle: '강의 미리보기',
                heroSubtitle: '강의를 신청하지 않아도 개요와 주차별 자료 구성을 먼저 확인할 수 있습니다.',
                footer: Align(
                  alignment: Alignment.centerLeft,
                  child: FilledButton.tonal(
                    onPressed: enrollingCourseIds.contains(selectedCourseId!)
                        ? null
                        : () => _enrollCourse(selectedCourseId!),
                    child: Text(
                      enrollingCourseIds.contains(selectedCourseId!)
                          ? '신청 중...'
                          : '이 강의 수강신청',
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 10),
            const EndpointChip(label: 'GET ${Endpoints.courses}'),
            const EndpointChip(label: 'POST ${Endpoints.enrollByCode}'),
            EndpointChip(
                label: 'POST ${Endpoints.courseDetail(101)}/enrollments'),
          ],
        );
      },
    );
  }

  Future<void> _enrollCourse(int courseId) async {
    setState(() {
      enrollingCourseIds = {...enrollingCourseIds, courseId};
    });
    final response =
        await widget.controller.api.enrollCourse(courseId: courseId);
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(response.message)));
    setState(() {
      enrollingCourseIds.remove(courseId);
      refreshSeed++;
    });
  }

  Future<void> _enrollByCode() async {
    setState(() {
      enrollingByCode = true;
    });
    final response = await widget.controller.api.enrollCourseByCode(
      courseCode: courseCodeController.text.trim(),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(response.message)));
    setState(() {
      enrollingByCode = false;
      if (response.success) {
        courseCodeController.clear();
        refreshSeed++;
      }
    });
  }
}

class _StudentCourseOverview extends StatelessWidget {
  const _StudentCourseOverview({
    required this.controller,
    required this.courseId,
    required this.selectedWeekId,
    required this.onWeekSelected,
    required this.heroTitle,
    required this.heroSubtitle,
    this.footer,
  });

  final AppController controller;
  final int courseId;
  final int? selectedWeekId;
  final void Function(int weekId) onWeekSelected;
  final String heroTitle;
  final String heroSubtitle;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ApiResponse<Map<String, dynamic>>>(
      future: controller.api.getCourseDetail(courseId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final course = snapshot.data!.data ?? {};
        final weeks = ((course['weeks'] as List<dynamic>?) ?? const [])
            .whereType<Map<String, dynamic>>()
            .toList();
        final effectiveWeekId = selectedWeekId ??
            (weeks.isNotEmpty ? _asInt(weeks.first['weekId']) : null);
        if (effectiveWeekId != null && selectedWeekId == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            onWeekSelected(effectiveWeekId);
          });
        }
        final overviewSection = SectionPanel(
          title: heroTitle,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InfoCard(
                title: _displayText(course['title']),
                content:
                    '${_displayText(course['description'], emptyMessage: '강의 소개가 아직 없습니다.')}\n강의 코드 ${_displayText(course['courseCode'], emptyMessage: '-')} · ${course['isPublic'] == true ? '공개 강의' : '비공개 강의'}',
              ),
              InfoCard(
                title: '강의 기본 정보',
                content:
                    '담당 교수 ${_displayText((course['instructor'] as Map<String, dynamic>?)?['name'], emptyMessage: '미정')} · 시작 ${_displayText(course['startDate'])} · 종료 ${_displayText(course['endDate'])}',
              ),
              Text(
                heroSubtitle,
                style: const TextStyle(
                  color: Color(0xFF64757B),
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (footer != null) ...[
                const SizedBox(height: 12),
                footer!,
              ],
            ],
          ),
        );

        final weekSection = SectionPanel(
          title: '주차 목록',
          child: weeks.isEmpty
              ? const EmptyStateCard(
                  title: '등록된 주차가 없습니다',
                  description: '강의 주차가 등록되면 이곳에서 순서대로 볼 수 있습니다.',
                )
              : Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: weeks.map((week) {
                    return SizedBox(
                      width: 220,
                      child: _SelectionCard(
                        title:
                            '${_asInt(week['weekNumber'])}주차 · ${_displayText(week['title'])}',
                        description: '클릭하면 주차별 자료와 콘텐츠를 볼 수 있습니다.',
                        selected: _asInt(week['weekId']) == effectiveWeekId,
                        onTap: () => onWeekSelected(_asInt(week['weekId'])),
                      ),
                    );
                  }).toList(),
                ),
        );

        return Column(
          children: [
            overviewSection,
            const SizedBox(height: 16),
            weekSection,
            const SizedBox(height: 16),
            if (effectiveWeekId != null)
              _StudentWeekPreview(
                controller: controller,
                courseId: courseId,
                weekId: effectiveWeekId,
              ),
          ],
        );
      },
    );
  }
}

class _StudentWeekPreview extends StatelessWidget {
  const _StudentWeekPreview({
    required this.controller,
    required this.courseId,
    required this.weekId,
  });

  final AppController controller;
  final int courseId;
  final int weekId;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ApiResponse<List<Map<String, dynamic>>>>(
      future: controller.api.getWeekContents(courseId, weekId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final contents = snapshot.data!.data ?? [];
        return SectionPanel(
          title: '주차 자료',
          child: contents.isEmpty
              ? const EmptyStateCard(
                  title: '등록된 자료가 없습니다',
                  description: '교안이나 영상이 올라오면 이곳에서 확인할 수 있습니다.',
                )
              : Column(
                  children: contents
                      .map(
                        (content) => Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFDCE8E4)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _StatusChip(
                                label: '유형',
                                value: _displayText(content['type'],
                                    emptyMessage: '자료'),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _displayText(content['title']),
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      _displayText(
                                        content['description'],
                                        emptyMessage:
                                            '강의 개요 또는 교안 설명이 아직 없습니다.',
                                      ),
                                      style: const TextStyle(
                                        color: Color(0xFF64757B),
                                        height: 1.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
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
  int? selectedCourseId;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ApiResponse<List<Map<String, dynamic>>>>(
      future: widget.controller.api.getMyCourses(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final courses = snapshot.data!.data ?? [];
        if (selectedCourseId == null && courses.isNotEmpty) {
          selectedCourseId = _asInt(courses.first['courseId']);
        }
        return ListView(
          children: [
            const DashboardHeroCard(
              title: '콘텐츠 및 진도',
              subtitle: '내 강의별 진행상황과 최근 학습한 콘텐츠를 함께 확인할 수 있습니다.',
            ),
            const SizedBox(height: 16),
            SectionPanel(
              title: '내 강의 선택',
              child: courses.isEmpty
                  ? const EmptyStateCard(
                      title: '수강 중인 강의가 없습니다',
                      description: '강의 신청 메뉴에서 강의를 등록하면 여기서 진도를 볼 수 있습니다.',
                    )
                  : Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: courses
                          .map(
                            (course) => SizedBox(
                              width: 260,
                              child: _SelectionCard(
                                title: _displayText(course['title']),
                                description:
                                    '진도 ${_asInt(course['progressRate'])}% · 출석 ${_asInt(course['attendanceRate'])}%',
                                selected: _asInt(course['courseId']) ==
                                    selectedCourseId,
                                onTap: () => setState(
                                  () => selectedCourseId =
                                      _asInt(course['courseId']),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
            ),
            const SizedBox(height: 16),
            if (selectedCourseId != null)
              _StudentCourseProgressView(
                controller: widget.controller,
                courseId: selectedCourseId!,
              ),
            const SizedBox(height: 10),
            const EndpointChip(label: 'GET ${Endpoints.coursesMy}'),
            EndpointChip(label: 'GET ${Endpoints.courseLearningLogs(101)}'),
          ],
        );
      },
    );
  }
}

class _StudentCourseProgressView extends StatelessWidget {
  const _StudentCourseProgressView({
    required this.controller,
    required this.courseId,
  });

  final AppController controller;
  final int courseId;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ApiResponse<dynamic>>>(
      future: Future.wait<ApiResponse<dynamic>>([
        controller.api.getCourseDetail(courseId),
        controller.api.getMyLearningLogs(courseId),
      ]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final course = snapshot.data![0].data as Map<String, dynamic>? ?? {};
        final logs =
            snapshot.data![1].data as List<Map<String, dynamic>>? ?? [];
        final completedCount =
            logs.where((item) => item['isCompleted'] == true).length;
        final averageProgress = logs.isEmpty
            ? 0
            : (logs
                        .map((item) => _asInt(item['progressRate']))
                        .reduce((a, b) => a + b) /
                    logs.length)
                .round();
        final recentLogs = [...logs]..sort(
            (a, b) => _asInt(b['contentId']).compareTo(_asInt(a['contentId'])));

        return Column(
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                MetricCard(
                  label: '평균 진행률',
                  value: '$averageProgress%',
                  tone: _statusToneFor(
                    '상태',
                    averageProgress >= 80
                        ? '안정'
                        : averageProgress >= 50
                            ? '관찰 필요'
                            : '주의 필요',
                  ),
                ),
                MetricCard(label: '완료 콘텐츠', value: '$completedCount개'),
                MetricCard(
                    label: '최근 학습', value: '${recentLogs.take(3).length}건'),
              ],
            ),
            const SizedBox(height: 16),
            SectionPanel(
              title: '진행상황 요약',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InfoCard(
                    title: _displayText(course['title']),
                    content:
                        '${_displayText(course['description'], emptyMessage: '강의 설명이 아직 없습니다.')}\n담당 교수 ${_displayText((course['instructor'] as Map<String, dynamic>?)?['name'], emptyMessage: '미정')}',
                  ),
                  if (recentLogs.isEmpty)
                    const EmptyStateCard(
                      title: '최근 학습 내역이 없습니다',
                      description: '콘텐츠를 시청하면 최근 들은 기록과 진행상황이 여기에 표시됩니다.',
                    )
                  else
                    ...recentLogs.take(5).map(
                          (log) => Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border:
                                  Border.all(color: const Color(0xFFDCE8E4)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        _displayText(log['title']),
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                    _StatusChip(
                                      label: '유형',
                                      value: _displayText(log['type'],
                                          emptyMessage: '자료'),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(999),
                                  child: LinearProgressIndicator(
                                    minHeight: 9,
                                    value: (_asInt(log['progressRate'])
                                            .clamp(0, 100)) /
                                        100,
                                    backgroundColor: const Color(0xFFE8F0ED),
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      _statusToneFor(
                                        '상태',
                                        log['isCompleted'] == true
                                            ? '안정'
                                            : '관찰 필요',
                                      ).foreground,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    _StatusChip(
                                      label: '진도',
                                      value: '${_asInt(log['progressRate'])}%',
                                    ),
                                    _StatusChip(
                                      label: '학습 상태',
                                      value: log['isCompleted'] == true
                                          ? '완료'
                                          : '진행 중',
                                    ),
                                    if (_displayText(
                                      log['attendanceStatus'],
                                      emptyMessage: '',
                                    ).isNotEmpty)
                                      _StatusChip(
                                        label: '출석',
                                        value: _displayText(
                                            log['attendanceStatus']),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                ],
              ),
            ),
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
  int refreshSeed = 0;
  int? selectedCourseId;
  int? selectedAssignmentId;

  @override
  void dispose() {
    answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ApiResponse<List<Map<String, dynamic>>>>(
      key: ValueKey(refreshSeed),
      future: widget.controller.api.getMyCourses(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final courses = snapshot.data!.data ?? [];
        if (selectedCourseId == null && courses.isNotEmpty) {
          selectedCourseId = _asInt(courses.first['courseId']);
        }
        return ListView(
          children: [
            const DashboardHeroCard(
              title: '과제',
              subtitle: '수강 중인 강의별로 과제를 확인하고 제출할 수 있습니다.',
            ),
            const SizedBox(height: 16),
            SectionPanel(
              title: '강의 선택',
              child: courses.isEmpty
                  ? const EmptyStateCard(
                      title: '수강 중인 강의가 없습니다',
                      description: '강의를 등록하면 강의별 과제가 여기에 표시됩니다.',
                    )
                  : Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: courses
                          .map(
                            (course) => SizedBox(
                              width: 260,
                              child: _SelectionCard(
                                title: _displayText(course['title']),
                                description:
                                    '미제출 ${_asInt(course['assignmentPendingCount'])}개',
                                selected: _asInt(course['courseId']) ==
                                    selectedCourseId,
                                onTap: () {
                                  setState(() {
                                    selectedCourseId =
                                        _asInt(course['courseId']);
                                    selectedAssignmentId = null;
                                  });
                                },
                              ),
                            ),
                          )
                          .toList(),
                    ),
            ),
            const SizedBox(height: 16),
            if (selectedCourseId != null)
              _buildAssignmentArea(selectedCourseId!),
            const SizedBox(height: 10),
            const EndpointChip(label: 'GET ${Endpoints.coursesMy}'),
            EndpointChip(label: 'GET ${Endpoints.courseAssignments(101)}'),
            EndpointChip(label: 'GET ${Endpoints.assignmentDetail(7001)}'),
            EndpointChip(label: 'POST ${Endpoints.assignmentSubmit(7001)}'),
          ],
        );
      },
    );
  }

  Widget _buildAssignmentArea(int courseId) {
    return FutureBuilder<ApiResponse<List<Map<String, dynamic>>>>(
      future: widget.controller.api.getCourseAssignments(courseId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final assignments = snapshot.data!.data ?? [];
        if (selectedAssignmentId == null && assignments.isNotEmpty) {
          selectedAssignmentId = _asInt(assignments.first['assignmentId']);
        }
        return Column(
          children: [
            SectionPanel(
              title: '강의별 과제 목록',
              child: assignments.isEmpty
                  ? const EmptyStateCard(
                      title: '등록된 과제가 없습니다',
                      description: '교수자가 과제를 등록하면 여기에서 확인할 수 있습니다.',
                    )
                  : Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: assignments
                          .map(
                            (assignment) => SizedBox(
                              width: 280,
                              child: _SelectionCard(
                                title: _displayText(assignment['title']),
                                description:
                                    '마감 ${_displayText(assignment['dueAt'])}\n${assignment['isSubmitted'] == true ? '제출 완료' : '미제출'}',
                                selected: _asInt(assignment['assignmentId']) ==
                                    selectedAssignmentId,
                                onTap: () {
                                  setState(() {
                                    selectedAssignmentId =
                                        _asInt(assignment['assignmentId']);
                                  });
                                },
                              ),
                            ),
                          )
                          .toList(),
                    ),
            ),
            const SizedBox(height: 16),
            if (selectedAssignmentId != null)
              FutureBuilder<ApiResponse<Map<String, dynamic>>>(
                future: widget.controller.api
                    .getAssignmentDetail(selectedAssignmentId!),
                builder: (context, detailSnapshot) {
                  if (!detailSnapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final assignment = detailSnapshot.data!.data!;
                  return SectionPanel(
                    title: '과제 상세',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InfoCard(
                          title: _displayText(
                            assignment['title'],
                            emptyMessage: '과제 제목 미정',
                          ),
                          content: _displayText(
                            assignment['description'],
                            emptyMessage: '과제 설명이 아직 없습니다.',
                          ),
                        ),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _StatusChip(
                              label: '유형',
                              value: _displayText(assignment['type']),
                            ),
                            _StatusChip(
                              label: '마감',
                              value: _displayText(assignment['dueAt']),
                            ),
                          ],
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
                            final response =
                                await widget.controller.api.submitAssignment(
                              assignmentId: selectedAssignmentId!,
                              answerText: answerController.text,
                            );
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(response.message)),
                            );
                            if (response.success) {
                              setState(() {
                                refreshSeed++;
                              });
                            }
                          },
                          child: const Text('과제 제출'),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        );
      },
    );
  }
}

class StudentTeamPage extends StatefulWidget {
  const StudentTeamPage({super.key, required this.controller});
  final AppController controller;

  @override
  State<StudentTeamPage> createState() => _StudentTeamPageState();
}

class _StudentTeamPageState extends State<StudentTeamPage> {
  final TextEditingController aliasController = TextEditingController();
  bool editingAlias = false;

  @override
  void dispose() {
    aliasController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ApiResponse<dynamic>>>(
      future: Future.wait<ApiResponse<dynamic>>([
        widget.controller.api.getMyTeam(),
        widget.controller.api.getTeamDetail(3001),
        widget.controller.api.getTeamChatRoom(3001),
        widget.controller.api.getChatMessages(4001),
      ]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final responses = snapshot.data!;
        final team = responses[0].data as Map<String, dynamic>? ?? {};
        final detail = responses[1].data as Map<String, dynamic>? ?? {};
        final messages = responses[3].data as List<Map<String, dynamic>>? ?? [];
        final teamId = _asInt(detail['teamId'] ?? team['teamId']);
        final defaultTeamName = _displayText(
          detail['teamName'] ?? detail['name'] ?? team['teamName'],
          emptyMessage: '배정된 팀이 없습니다',
        );
        final displayTeamName =
            widget.controller.teamAlias(teamId, defaultTeamName);
        if (aliasController.text.trim().isEmpty && editingAlias == false) {
          aliasController.text = displayTeamName;
        }
        final members = (detail['members'] as List<dynamic>? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map((e) => _displayText(e['name'], emptyMessage: '이름 없음'))
            .toList();

        return ListView(
          children: [
            DashboardHeroCard(
              title: '팀 활동',
              subtitle: '팀 카드를 눌러 설명, 개인 별칭, 대화창을 한 화면에서 볼 수 있습니다.',
            ),
            const SizedBox(height: 16),
            SectionPanel(
              title: '내 팀',
              child: _SelectionCard(
                title: displayTeamName,
                description:
                    '원래 팀명: $defaultTeamName\n협업점수 ${_asInt(detail['collaborationScore'])} · 팀 빌딩 ${_asInt(detail['teamBuildingScore'])}',
                selected: true,
                onTap: () {},
              ),
            ),
            const SizedBox(height: 16),
            SectionPanel(
              title: '팀 설명',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InfoCard(
                    title: displayTeamName,
                    content: _displayText(
                      detail['matchingSummary'],
                      emptyMessage: '팀 설명이 아직 없습니다.',
                    ),
                  ),
                  InfoCard(
                    title: '팀원 구성',
                    content: members.isEmpty
                        ? '아직 팀원 정보가 없습니다.'
                        : members.join(', '),
                  ),
                  const SizedBox(height: 8),
                  if (editingAlias) ...[
                    _AuthTextField(
                      controller: aliasController,
                      label: '내 화면용 팀명',
                      hintText: '예: AI 기초 : 발표팀',
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        FilledButton.tonal(
                          onPressed: () {
                            widget.controller
                                .setTeamAlias(teamId, aliasController.text);
                            setState(() {
                              editingAlias = false;
                            });
                          },
                          child: const Text('개인 팀명 저장'),
                        ),
                        const SizedBox(width: 10),
                        TextButton(
                          onPressed: () {
                            aliasController.text = defaultTeamName;
                            widget.controller.setTeamAlias(teamId, '');
                            setState(() {
                              editingAlias = false;
                            });
                          },
                          child: const Text('원래 팀명으로'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '이 팀명은 내 화면에만 적용됩니다.',
                      style: TextStyle(color: Color(0xFF64757B)),
                    ),
                  ] else
                    Align(
                      alignment: Alignment.centerLeft,
                      child: FilledButton.tonal(
                        onPressed: () {
                          aliasController.text = displayTeamName;
                          setState(() {
                            editingAlias = true;
                          });
                        },
                        child: const Text('개인 팀명 바꾸기'),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SectionPanel(
              title: '팀 대화창',
              child: messages.isEmpty
                  ? const EmptyStateCard(
                      title: '팀 대화가 아직 없습니다',
                      description: '대화가 시작되면 여기에서 바로 이어서 볼 수 있습니다.',
                    )
                  : Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FCFB),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFDCE8E4)),
                      ),
                      child: Column(
                        children: messages
                            .map(
                              (message) => Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  width: double.infinity,
                                  margin: const EdgeInsets.only(bottom: 10),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: const Color(0xFFDCE8E4),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            _displayText(
                                              message['senderName'],
                                              emptyMessage: '알 수 없음',
                                            ),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                          const Spacer(),
                                          Text(
                                            _timeLabel(message['sentAt']),
                                            style: const TextStyle(
                                              color: Color(0xFF75848A),
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(_displayText(message['message'])),
                                    ],
                                  ),
                                ),
                              ),
                            )
                            .toList(),
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
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());
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
                MetricCard(
                    label: '수강생', value: '${_asInt(data['studentCount'])}'),
                MetricCard(
                    label: '평균 출석',
                    value: '${_asInt(data['averageAttendanceRate'])}%'),
                MetricCard(
                    label: '고위험 학생',
                    value: '${_asInt(data['highRiskStudentCount'])}'),
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

class InstructorStudentsPage extends StatefulWidget {
  const InstructorStudentsPage({super.key, required this.controller});
  final AppController controller;

  @override
  State<InstructorStudentsPage> createState() => _InstructorStudentsPageState();
}

class _InstructorStudentsPageState extends State<InstructorStudentsPage> {
  final Map<int, TextEditingController> memoControllers = {};
  final Set<int> savingStudentIds = <int>{};
  int refreshSeed = 0;
  int? selectedCourseId;

  @override
  void dispose() {
    for (final controller in memoControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ApiResponse<dynamic>>>(
      key: ValueKey(refreshSeed),
      future: Future.wait<ApiResponse<dynamic>>([
        widget.controller.api.getMyCourses(),
        if (selectedCourseId != null)
          widget.controller.api.getInstructorDashboard(selectedCourseId!),
        if (selectedCourseId != null)
          widget.controller.api.getInterventions(selectedCourseId!),
      ]),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());
        final courses =
            snapshot.data!.first.data as List<Map<String, dynamic>>? ?? [];
        if (selectedCourseId == null && courses.isNotEmpty) {
          selectedCourseId = _asInt(courses.first['courseId']);
        }
        final dashboard = snapshot.data!.length > 1
            ? snapshot.data![1].data as Map<String, dynamic>? ?? {}
            : const <String, dynamic>{};
        final interventions = snapshot.data!.length > 2
            ? snapshot.data![2].data as List<Map<String, dynamic>>? ?? []
            : const <Map<String, dynamic>>[];

        return ListView(
          children: [
            const DashboardHeroCard(
              title: '수강생 관리',
              subtitle: '담당 강의 수강생을 모아 보고, 상태를 빠르게 확인하고, 개인 메모를 남길 수 있습니다.',
            ),
            const SizedBox(height: 16),
            SectionPanel(
              title: '강의 선택',
              child: courses.isEmpty
                  ? const EmptyStateCard(
                      title: '담당 강의가 없습니다',
                      description: '강의가 등록되면 이 화면에서 수강생 현황을 볼 수 있습니다.',
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
                                  emptyMessage: '강의 설명이 없습니다.',
                                ),
                                selected: _asInt(course['courseId']) ==
                                    selectedCourseId,
                                onTap: () {
                                  setState(() {
                                    selectedCourseId =
                                        _asInt(course['courseId']);
                                  });
                                },
                              ),
                            ),
                          )
                          .toList(),
                    ),
            ),
            const SizedBox(height: 16),
            if (selectedCourseId != null) ...[
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  MetricCard(
                      label: '수강생',
                      value: '${_asInt(dashboard['studentCount'])}명'),
                  MetricCard(
                      label: '평균 출석',
                      value: '${_asInt(dashboard['averageAttendanceRate'])}%'),
                  MetricCard(
                      label: '고위험',
                      value: '${_asInt(dashboard['highRiskStudentCount'])}명'),
                  MetricCard(
                      label: '저이해',
                      value:
                          '${_asInt(dashboard['lowUnderstandingStudentCount'])}명'),
                ],
              ),
              const SizedBox(height: 16),
              _buildStudentList(selectedCourseId!),
              const SizedBox(height: 12),
              SectionPanel(
                title: '개입 추천',
                child: interventions.isEmpty
                    ? const EmptyStateCard(
                        title: '개입 추천이 없습니다',
                        description: '학생 데이터가 쌓이면 추천 액션이 표시됩니다.',
                      )
                    : Column(
                        children: interventions
                            .map(
                              (item) => ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(_displayText(item['studentName'])),
                                subtitle: Text(
                                    _displayText(item['recommendedAction'])),
                              ),
                            )
                            .toList(),
                      ),
              ),
              const SizedBox(height: 10),
              EndpointChip(
                  label: 'GET ${Endpoints.courseStudents(selectedCourseId!)}'),
              EndpointChip(
                  label:
                      'PATCH ${Endpoints.courseStudentMemo(selectedCourseId!, 1)}'),
            ],
          ],
        );
      },
    );
  }

  Widget _buildStudentList(int courseId) {
    return FutureBuilder<ApiResponse<List<Map<String, dynamic>>>>(
      future: widget.controller.api.getCourseStudents(courseId),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());
        final students = snapshot.data!.data ?? [];
        if (students.isEmpty) {
          return const SectionPanel(
            title: '수강생 현황',
            child: EmptyStateCard(
              title: '수강생이 없습니다',
              description: '학생이 등록되면 학습 상태와 메모를 확인할 수 있습니다.',
            ),
          );
        }
        return SectionPanel(
          title: '수강생 현황',
          child: Column(
            children: students
                .map((student) => _buildStudentCard(courseId, student))
                .toList(),
          ),
        );
      },
    );
  }

  Widget _buildStudentCard(int courseId, Map<String, dynamic> student) {
    final studentId = _asInt(student['userId']);
    final memoController = memoControllers.putIfAbsent(
      studentId,
      () => TextEditingController(
          text: _displayText(student['memo'], emptyMessage: '')),
    );
    if (memoController.text.trim().isEmpty &&
        _displayText(student['memo'], emptyMessage: '').isNotEmpty) {
      memoController.text = _displayText(student['memo'], emptyMessage: '');
    }
    final riskLevel = _displayText(student['riskLevel'], emptyMessage: 'LOW');
    final riskTone = _statusToneFor('위험도', riskLevel);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FCFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDCE8E4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _displayText(student['name'], emptyMessage: '이름 없음'),
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _displayText(student['email'], emptyMessage: '이메일 정보 없음'),
                      style: const TextStyle(color: Color(0xFF66777D)),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: riskTone.background,
                  border: Border.all(color: riskTone.border),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '위험도 $riskLevel',
                  style: TextStyle(
                    color: riskTone.foreground,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _StatusChip(
                  label: '진도', value: '${_asInt(student['progressRate'])}%'),
              _StatusChip(
                  label: '출석', value: '${_asInt(student['attendanceRate'])}%'),
              _StatusChip(
                  label: '이해도',
                  value: '${_asInt(student['understandingScore'])}'),
              _StatusChip(
                  label: '상태', value: _displayText(student['statusSummary'])),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: memoController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: '교수자 메모',
              hintText: '학생 상태나 후속 조치를 기록하세요',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.tonal(
              onPressed: savingStudentIds.contains(studentId)
                  ? null
                  : () => _saveMemo(courseId, studentId, memoController.text),
              child: Text(
                  savingStudentIds.contains(studentId) ? '저장 중...' : '메모 저장'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveMemo(int courseId, int studentId, String memo) async {
    setState(() {
      savingStudentIds.add(studentId);
    });
    final response = await widget.controller.api.updateCourseStudentMemo(
      courseId: courseId,
      studentId: studentId,
      memo: memo,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(response.message)));
    setState(() {
      savingStudentIds.remove(studentId);
      refreshSeed++;
    });
  }
}

class InstructorCourseManagementPage extends StatefulWidget {
  const InstructorCourseManagementPage({super.key, required this.controller});

  final AppController controller;

  @override
  State<InstructorCourseManagementPage> createState() =>
      _InstructorCourseManagementPageState();
}

class _InstructorCourseManagementPageState
    extends State<InstructorCourseManagementPage> {
  final TextEditingController courseTitleController = TextEditingController();
  final TextEditingController courseDescriptionController =
      TextEditingController();
  final TextEditingController courseThumbnailController =
      TextEditingController();
  final TextEditingController courseStartDateController =
      TextEditingController(text: '2026-05-01');
  final TextEditingController courseEndDateController =
      TextEditingController(text: '2026-06-30');
  final TextEditingController weekNumberController =
      TextEditingController(text: '1');
  final TextEditingController weekTitleController = TextEditingController();
  final TextEditingController weekOpenAtController = TextEditingController(
    text: '2026-05-01T09:00:00Z',
  );
  final TextEditingController contentTitleController = TextEditingController();
  final TextEditingController contentDescriptionController =
      TextEditingController();
  final TextEditingController contentVideoUrlController =
      TextEditingController();
  final TextEditingController contentDocumentUrlController =
      TextEditingController();
  final TextEditingController contentDurationController =
      TextEditingController(text: '0');
  final TextEditingController contentScheduledAtController =
      TextEditingController(
    text: '2026-05-01T09:00:00Z',
  );
  final TextEditingController contentOpenAtController = TextEditingController(
    text: '2026-05-01T09:00:00Z',
  );
  final TextEditingController assignmentTitleController =
      TextEditingController();
  final TextEditingController assignmentDescriptionController =
      TextEditingController();
  final TextEditingController assignmentDueAtController = TextEditingController(
    text: '2026-05-20T23:59:59Z',
  );

  int refreshSeed = 0;
  int? selectedCourseId;
  int? selectedWeekId;
  String selectedContentType = 'VOD';
  String selectedAssignmentType = 'SUBJECTIVE';
  bool isSequentialRelease = false;
  bool isPublicCourse = true;
  bool isTeamAssignment = false;
  bool uploadingVideo = false;
  bool uploadingThumbnail = false;
  bool uploadingDocument = false;

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
    assignmentTitleController.dispose();
    assignmentDescriptionController.dispose();
    assignmentDueAtController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ApiResponse<List<Map<String, dynamic>>>>(
      future: widget.controller.api.getMyCourses(),
      key: ValueKey(refreshSeed),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());
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
                  Row(
                    children: [
                      FilledButton.tonal(
                        onPressed: uploadingThumbnail
                            ? null
                            : _pickAndUploadCourseThumbnail,
                        child: Text(
                            uploadingThumbnail ? '업로드 중...' : '썸네일 파일 올리기'),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          courseThumbnailController.text.trim().isEmpty
                              ? '이미지 파일을 올리면 썸네일이 자동으로 연결됩니다.'
                              : '썸네일 파일 업로드 완료',
                          style: const TextStyle(color: Color(0xFF66777D)),
                        ),
                      ),
                    ],
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
                    onChanged: (value) =>
                        setState(() => isSequentialRelease = value),
                  ),
                  SwitchListTile(
                    value: isPublicCourse,
                    contentPadding: EdgeInsets.zero,
                    title: const Text('공개 강의'),
                    subtitle: Text(
                      isPublicCourse
                          ? '누구나 강의 제목으로 찾아 수강신청할 수 있습니다.'
                          : '강의 코드를 가진 학생만 등록할 수 있습니다.',
                    ),
                    onChanged: (value) =>
                        setState(() => isPublicCourse = value),
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
                                title: _displayText(course['title'],
                                    emptyMessage: '제목 미정'),
                                description:
                                    '진도 ${_asInt(course['progressRate'])}% · 출석 ${_asInt(course['attendanceRate'])}%\n강의 코드 ${_displayText(course['courseCode'], emptyMessage: '-')} · ${course['isPublic'] == true ? '공개' : '비공개'}',
                                selected: _asInt(course['courseId']) ==
                                    selectedCourseId,
                                onTap: () {
                                  setState(() {
                                    selectedCourseId =
                                        _asInt(course['courseId']);
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
            if (selectedCourseId != null)
              _buildSelectedCourseDetail(selectedCourseId!),
          ],
        );
      },
    );
  }

  Widget _buildSelectedCourseDetail(int courseId) {
    return FutureBuilder<ApiResponse<Map<String, dynamic>>>(
      future: widget.controller.api.getCourseDetail(courseId),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());
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
                    title:
                        _displayText(course['title'], emptyMessage: '강의 제목 미정'),
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
                                selected:
                                    _asInt(week['weekId']) == selectedWeekId,
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
            if (selectedWeekId != null)
              _buildContentManager(courseId, selectedWeekId!),
            const SizedBox(height: 16),
            _buildAssignmentManager(courseId),
          ],
        );
      },
    );
  }

  Widget _buildContentManager(int courseId, int weekId) {
    return FutureBuilder<ApiResponse<List<Map<String, dynamic>>>>(
      future: widget.controller.api.getWeekContents(courseId, weekId),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());
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
              if (selectedContentType == 'LIVE') ...[
                _AuthTextField(
                  controller: contentTitleController,
                  label: '콘텐츠 제목',
                  hintText: '예: 1주차 실시간 수업',
                ),
                const SizedBox(height: 12),
                _AuthTextField(
                  controller: contentDescriptionController,
                  label: '콘텐츠 설명',
                  hintText: '콘텐츠 소개를 입력하세요',
                ),
              ],
              if (selectedContentType == 'VOD') ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    FilledButton.tonal(
                      onPressed: uploadingVideo ? null : _pickAndUploadVideo,
                      child: Text(uploadingVideo ? '업로드 중...' : '영상 올리기'),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        contentVideoUrlController.text.trim().isEmpty
                            ? '업로드 후 영상 URL이 자동으로 채워집니다.'
                            : '업로드 완료: 영상 URL이 연결되었습니다.',
                        style: const TextStyle(color: Color(0xFF66777D)),
                      ),
                    ),
                  ],
                ),
                if (contentVideoUrlController.text.trim().isNotEmpty) ...[
                  const SizedBox(height: 12),
                  InfoCard(
                    title: contentTitleController.text.trim().isEmpty
                        ? '업로드한 영상'
                        : contentTitleController.text.trim(),
                    content: contentDescriptionController.text.trim().isEmpty
                        ? '업로드한 동영상 콘텐츠가 자동으로 등록됩니다.'
                        : contentDescriptionController.text.trim(),
                  ),
                ],
              ],
              if (selectedContentType == 'DOCUMENT') ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    FilledButton.tonal(
                      onPressed:
                          uploadingDocument ? null : _pickAndUploadDocument,
                      child: Text(uploadingDocument ? '업로드 중...' : '문서 파일 올리기'),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        contentDocumentUrlController.text.trim().isEmpty
                            ? 'PDF, DOCX 등 문서를 올리면 자동으로 연결됩니다.'
                            : '문서 파일 업로드 완료',
                        style: const TextStyle(color: Color(0xFF66777D)),
                      ),
                    ),
                  ],
                ),
                if (contentDocumentUrlController.text.trim().isNotEmpty) ...[
                  const SizedBox(height: 12),
                  InfoCard(
                    title: contentTitleController.text.trim().isEmpty
                        ? '업로드한 문서'
                        : contentTitleController.text.trim(),
                    content: contentDescriptionController.text.trim().isEmpty
                        ? '업로드한 문서 콘텐츠가 자동으로 등록됩니다.'
                        : contentDescriptionController.text.trim(),
                  ),
                ],
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

  Widget _buildAssignmentManager(int courseId) {
    return FutureBuilder<ApiResponse<List<Map<String, dynamic>>>>(
      future: widget.controller.api.getCourseAssignments(courseId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final assignments = snapshot.data!.data ?? [];
        return SectionPanel(
          title: '과제 관리',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _AuthTextField(
                controller: assignmentTitleController,
                label: '과제 제목',
                hintText: '예: 3주차 개념 정리 과제',
              ),
              const SizedBox(height: 12),
              _AuthTextField(
                controller: assignmentDescriptionController,
                label: '과제 설명',
                hintText: '학생에게 보여줄 과제 안내를 입력하세요',
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(value: 'SUBJECTIVE', label: Text('서술형')),
                        ButtonSegment(value: 'DESCRIPTIVE', label: Text('확장형')),
                      ],
                      selected: {selectedAssignmentType},
                      onSelectionChanged: (selection) {
                        setState(() {
                          selectedAssignmentType = selection.first;
                        });
                      },
                    ),
                  ),
                ],
              ),
              SwitchListTile(
                value: isTeamAssignment,
                contentPadding: EdgeInsets.zero,
                title: const Text('팀 과제'),
                subtitle: const Text('팀 단위로 과제를 수행하는 과제로 표시합니다.'),
                onChanged: (value) => setState(() => isTeamAssignment = value),
              ),
              _AuthTextField(
                controller: assignmentDueAtController,
                label: '마감 시각',
                hintText: '2026-05-20T23:59:59Z',
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: FilledButton(
                  onPressed: () => _createAssignment(courseId),
                  child: const Text('과제 생성'),
                ),
              ),
              const SizedBox(height: 18),
              if (assignments.isEmpty)
                const EmptyStateCard(
                  title: '등록된 과제가 없습니다',
                  description: '과제를 만들면 학생들이 강의별로 확인할 수 있습니다.',
                )
              else
                ...assignments.map(
                  (assignment) => InfoCard(
                    title: _displayText(assignment['title']),
                    content:
                        '마감 ${_displayText(assignment['dueAt'])} · ${assignment['teamAssignment'] == true ? '팀 과제' : '개인 과제'} · ${_displayText(assignment['type'])}',
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
      isPublic: isPublicCourse,
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
      if (selectedContentType != 'LIVE') {
        contentTitleController.clear();
        contentDescriptionController.clear();
      }
      contentVideoUrlController.clear();
      contentDocumentUrlController.clear();
      contentDurationController.text = '0';
    });
  }

  Future<void> _createAssignment(int courseId) async {
    final response = await widget.controller.api.createAssignment(
      courseId: courseId,
      title: assignmentTitleController.text.trim(),
      description: assignmentDescriptionController.text.trim(),
      type: selectedAssignmentType,
      dueAt: assignmentDueAtController.text.trim(),
      teamAssignment: isTeamAssignment,
    );
    _notify(response.message);
    if (!response.success) return;
    setState(() {
      refreshSeed++;
      assignmentTitleController.clear();
      assignmentDescriptionController.clear();
      assignmentDueAtController.text = '2026-05-20T23:59:59Z';
      isTeamAssignment = false;
      selectedAssignmentType = 'SUBJECTIVE';
    });
  }

  Future<void> _pickAndUploadVideo() async {
    await _pickAndUploadFile(
      allowedExtensions: const ['mp4', 'mov', 'webm', 'mkv'],
      category: 'CONTENT_VIDEO',
      uploadingSetter: (value) => setState(() => uploadingVideo = value),
      onUploaded: (file, fileUrl) {
        setState(() {
          contentVideoUrlController.text = fileUrl;
          contentTitleController.text = _inferTitleFromFileName(file.name);
          contentDescriptionController.text =
              '${_inferTitleFromFileName(file.name)} 동영상 콘텐츠';
          contentDurationController.text = '0';
        });
      },
      successMessage: '영상 업로드가 완료되었습니다.',
    );
  }

  Future<void> _pickAndUploadDocument() async {
    await _pickAndUploadFile(
      allowedExtensions: const [
        'pdf',
        'doc',
        'docx',
        'ppt',
        'pptx',
        'xls',
        'xlsx',
        'txt'
      ],
      category: 'CONTENT_DOCUMENT',
      uploadingSetter: (value) => setState(() => uploadingDocument = value),
      onUploaded: (file, fileUrl) {
        setState(() {
          contentDocumentUrlController.text = fileUrl;
          contentTitleController.text = _inferTitleFromFileName(file.name);
          contentDescriptionController.text =
              '${_inferTitleFromFileName(file.name)} 문서 콘텐츠';
        });
      },
      successMessage: '문서 업로드가 완료되었습니다.',
    );
  }

  Future<void> _pickAndUploadCourseThumbnail() async {
    await _pickAndUploadFile(
      allowedExtensions: const ['jpg', 'jpeg', 'png', 'webp', 'gif'],
      category: 'COURSE_THUMBNAIL',
      uploadingSetter: (value) => setState(() => uploadingThumbnail = value),
      onUploaded: (file, fileUrl) {
        setState(() {
          courseThumbnailController.text = fileUrl;
        });
      },
      successMessage: '썸네일 업로드가 완료되었습니다.',
    );
  }

  Future<void> _pickAndUploadFile({
    required List<String> allowedExtensions,
    required String category,
    required void Function(bool value) uploadingSetter,
    required void Function(PlatformFile file, String fileUrl) onUploaded,
    required String successMessage,
  }) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: allowedExtensions,
      withData: true,
    );
    if (result == null || result.files.isEmpty) {
      return;
    }

    final file = result.files.single;
    final bytes = file.bytes;
    if (bytes == null || bytes.isEmpty) {
      _notify('파일 데이터를 읽을 수 없습니다.');
      return;
    }

    final contentType = _guessContentType(file.extension ?? '');
    uploadingSetter(true);

    try {
      final uploadUrlResponse = await widget.controller.api.createUploadUrl(
        fileName: file.name,
        contentType: contentType,
        category: category,
      );
      if (!uploadUrlResponse.success || uploadUrlResponse.data == null) {
        _notify(uploadUrlResponse.message);
        return;
      }
      final data = uploadUrlResponse.data!;
      final uploadUri = Uri.parse('${data['uploadUrl']}');
      final response = await http.put(
        uploadUri,
        headers: {'Content-Type': contentType},
        body: bytes,
      );
      if (response.statusCode < 200 || response.statusCode >= 300) {
        _notify('S3 업로드에 실패했습니다. (${response.statusCode})');
        return;
      }
      onUploaded(file, '${data['fileUrl'] ?? ''}');
      _notify(successMessage);
    } catch (_) {
      _notify('파일 업로드 중 오류가 발생했습니다.');
    } finally {
      if (mounted) {
        uploadingSetter(false);
      }
    }
  }

  String _inferTitleFromFileName(String fileName) {
    final parts = fileName.split('.');
    final withoutExtension = parts.length > 1
        ? parts.sublist(0, parts.length - 1).join('.')
        : fileName;
    return withoutExtension.replaceAll(RegExp(r'[_-]+'), ' ').trim();
  }

  String _guessContentType(String extension) {
    switch (extension.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'gif':
        return 'image/gif';
      case 'mov':
        return 'video/quicktime';
      case 'webm':
        return 'video/webm';
      case 'mkv':
        return 'video/x-matroska';
      case 'pdf':
        return 'application/pdf';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'ppt':
        return 'application/vnd.ms-powerpoint';
      case 'pptx':
        return 'application/vnd.openxmlformats-officedocument.presentationml.presentation';
      case 'xls':
        return 'application/vnd.ms-excel';
      case 'xlsx':
        return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      case 'txt':
        return 'text/plain';
      case 'mp4':
      default:
        return 'video/mp4';
    }
  }

  void _notify(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}

class MyPage extends StatefulWidget {
  const MyPage({super.key, required this.controller});

  final AppController controller;

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  final TextEditingController nameController = TextEditingController();
  int refreshSeed = 0;
  bool uploadingProfile = false;
  bool saving = false;
  String profileImageUrl = '';

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ApiResponse<Map<String, dynamic>>>(
      key: ValueKey(refreshSeed),
      future: widget.controller.api.getMyProfile(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());
        final profile = snapshot.data!.data ?? {};
        if (nameController.text.trim().isEmpty) {
          nameController.text = _displayText(profile['name'], emptyMessage: '');
        }
        if (profileImageUrl.trim().isEmpty) {
          profileImageUrl =
              _displayText(profile['profileImageUrl'], emptyMessage: '');
        }
        final imageProvider = _profileImageProvider(profileImageUrl);
        return ListView(
          children: [
            const DashboardHeroCard(
              title: '마이페이지',
              subtitle: '내 계정 정보와 프로필 이미지를 관리할 수 있습니다.',
            ),
            const SizedBox(height: 16),
            SectionPanel(
              title: '프로필',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: const Color(0xFF0E7A66),
                        backgroundImage: imageProvider,
                        child: imageProvider == null
                            ? Text(
                                _displayText(profile['name'], emptyMessage: '?')
                                    .characters
                                    .first,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 16),
                      FilledButton.tonal(
                        onPressed:
                            uploadingProfile ? null : _uploadProfileImage,
                        child:
                            Text(uploadingProfile ? '업로드 중...' : '프로필 이미지 올리기'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _AuthTextField(
                    controller: nameController,
                    label: '이름',
                    hintText: '이름을 입력하세요',
                  ),
                  const SizedBox(height: 12),
                  InfoCard(
                    title: '이메일',
                    content: _displayText(profile['email'],
                        emptyMessage: '이메일 정보가 없습니다.'),
                  ),
                  InfoCard(
                    title: '역할',
                    content: UserRole.fromApi(_displayText(profile['role'],
                            emptyMessage: 'STUDENT'))
                        .label,
                  ),
                  if (profileImageUrl.trim().isNotEmpty)
                    InfoCard(
                      title: '프로필 이미지 URL',
                      content: profileImageUrl,
                    ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: FilledButton(
                      onPressed: saving ? null : _saveProfile,
                      child: Text(saving ? '저장 중...' : '내 정보 저장'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const EndpointChip(label: 'GET /api/v1/users/me'),
                  const EndpointChip(label: 'PATCH /api/v1/users/me'),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _uploadProfileImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['jpg', 'jpeg', 'png', 'webp'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) {
      return;
    }
    final file = result.files.single;
    final bytes = file.bytes;
    if (bytes == null || bytes.isEmpty) {
      _notify('파일 데이터를 읽을 수 없습니다.');
      return;
    }
    final contentType = switch ((file.extension ?? '').toLowerCase()) {
      'jpg' || 'jpeg' => 'image/jpeg',
      'png' => 'image/png',
      'webp' => 'image/webp',
      _ => 'application/octet-stream',
    };
    setState(() {
      uploadingProfile = true;
    });
    try {
      final upload = await widget.controller.api.createUploadUrl(
        fileName: file.name,
        contentType: contentType,
        category: 'PROFILE_IMAGE',
      );
      if (!upload.success || upload.data == null) {
        _notify(upload.message);
        return;
      }
      final response = await http.put(
        Uri.parse('${upload.data!['uploadUrl']}'),
        headers: {'Content-Type': contentType},
        body: bytes,
      );
      if (response.statusCode < 200 || response.statusCode >= 300) {
        _notify('프로필 이미지 업로드에 실패했습니다. (${response.statusCode})');
        return;
      }
      setState(() {
        profileImageUrl = '${upload.data!['fileUrl'] ?? ''}';
      });
      _notify('프로필 이미지 업로드가 완료되었습니다.');
    } catch (_) {
      _notify('프로필 이미지 업로드 중 오류가 발생했습니다.');
    } finally {
      if (mounted) {
        setState(() {
          uploadingProfile = false;
        });
      }
    }
  }

  Future<void> _saveProfile() async {
    setState(() {
      saving = true;
    });
    final response = await widget.controller.api.updateMyProfile(
      name: nameController.text.trim(),
      profileImageUrl: profileImageUrl.trim(),
    );
    if (!mounted) return;
    _notify(response.message);
    if (response.success) {
      widget.controller.refreshUser();
      setState(() {
        refreshSeed++;
      });
    }
    setState(() {
      saving = false;
    });
  }

  void _notify(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}

class InstructorTeamAnalysisPage extends StatefulWidget {
  const InstructorTeamAnalysisPage({super.key, required this.controller});

  final AppController controller;

  @override
  State<InstructorTeamAnalysisPage> createState() =>
      _InstructorTeamAnalysisPageState();
}

class _InstructorTeamAnalysisPageState
    extends State<InstructorTeamAnalysisPage> {
  final TextEditingController teamSizeController =
      TextEditingController(text: '3');
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
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());
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
                                selected: _asInt(course['courseId']) ==
                                    selectedCourseId,
                                onTap: () {
                                  setState(() {
                                    selectedCourseId =
                                        _asInt(course['courseId']);
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
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());
        final teams = snapshot.data!.data ?? [];
        if (selectedTeamId == null && teams.isNotEmpty) {
          selectedTeamId = _asInt(teams.first['teamId']);
        }

        return Column(
          children: [
            SectionPanel(
              title: 'AI 팀 빌딩',
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
                    child: const Text('AI 배정'),
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
                                    '인원 ${_asInt(team['memberCount'])}명 · 팀빌딩 ${_asInt(team['teamBuildingScore'])}\n${_displayText(team['matchingSummary'], emptyMessage: '추천 사유가 없습니다.')}',
                                selected:
                                    _asInt(team['teamId']) == selectedTeamId,
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
            if (selectedTeamId != null)
              _buildSelectedTeamDetail(selectedTeamId!),
          ],
        );
      },
    );
  }

  Widget _buildSelectedTeamDetail(int teamId) {
    return FutureBuilder<List<ApiResponse<dynamic>>>(
      future: Future.wait<ApiResponse<dynamic>>([
        widget.controller.api.getTeamDetail(teamId),
        widget.controller.api.getTeamAnalytics(teamId),
        widget.controller.api.getTeamMemberContributions(teamId),
      ]),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());
        final detail = snapshot.data![0].data as Map<String, dynamic>? ?? {};
        final analytics = snapshot.data![1].data as Map<String, dynamic>? ?? {};
        final contributions =
            snapshot.data![2].data as List<Map<String, dynamic>>? ?? [];
        final riskSignals = _asStringList(analytics['riskSignals']);
        final strengthSignals = _asStringList(analytics['strengthSignals']);
        final members = (detail['members'] as List<dynamic>? ?? [])
            .whereType<Map<String, dynamic>>()
            .toList();
        final styleDistributions =
            (analytics['styleDistributions'] as List<dynamic>? ?? [])
                .whereType<Map<String, dynamic>>()
                .toList();

        return Column(
          children: [
            SectionPanel(
              title: '팀 빌딩 요약',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      MetricCard(
                        label: '팀 빌딩 점수',
                        value: '${_asInt(analytics['teamBuildingScore'])}',
                      ),
                      MetricCard(
                        label: '스타일 다양성',
                        value: '${_asInt(analytics['profileDiversityScore'])}',
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  InfoCard(
                    title: '매칭 사유',
                    content: _displayText(
                      analytics['matchingSummary'] ?? detail['matchingSummary'],
                      emptyMessage: '매칭 사유가 없습니다.',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
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
              title: '팀 스타일 분포',
              child: styleDistributions.isEmpty
                  ? const EmptyStateCard(
                      title: '스타일 분석이 없습니다',
                      description: '학습 데이터가 쌓이면 팀 스타일 분포가 표시됩니다.',
                    )
                  : Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: styleDistributions
                          .map(
                            (item) => MetricCard(
                              label: _displayText(item['style']),
                              value: '${_asInt(item['memberCount'])}명',
                            ),
                          )
                          .toList(),
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
              title: '강점 신호',
              child: strengthSignals.isEmpty
                  ? const EmptyStateCard(
                      title: '강점 신호가 없습니다',
                      description: '현재는 별도 강점 신호를 계산하지 못했습니다.',
                    )
                  : Column(
                      children: strengthSignals
                          .map(
                            (signal) => ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(Icons.auto_awesome_outlined),
                              title: Text(signal),
                            ),
                          )
                          .toList(),
                    ),
            ),
            const SizedBox(height: 16),
            SectionPanel(
              title: '팀원 스타일 프로필',
              child: members.isEmpty
                  ? const EmptyStateCard(
                      title: '팀원 프로필이 없습니다',
                      description: '팀원 프로필이 계산되면 이곳에 표시됩니다.',
                    )
                  : Column(
                      children: members
                          .map(
                            (member) => ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                '${_displayText(member['name'])} · ${_displayText(member['learningStyle'])}',
                              ),
                              subtitle: Text(
                                '${_displayText(member['profileSummary'])}\n신뢰도 ${_asInt(member['reliabilityScore'])} · 추진 ${_asInt(member['initiativeScore'])} · 지원 ${_asInt(member['supportScore'])} · 이해 ${_asInt(member['understandingScore'])}',
                              ),
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
                                '${_displayText(item['learningStyle'])} · 신뢰도 ${_asInt(item['reliabilityScore'])} · 메시지 ${_asInt(item['messageCount'])}개 · 기여도 ${_asInt(item['contributionScore'])}',
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
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(response.message)));
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
        Text('공통 API 규칙',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
        SizedBox(height: 12),
        InfoCard(title: '기본 URL', content: '/api/v1'),
        InfoCard(
          title: '성공 응답',
          content: '{"success": true, "message": "...", "data": {...}}',
        ),
        InfoCard(
          title: '실패 응답',
          content:
              '{"success": false, "message": "...", "errorCode": "COURSE_NOT_FOUND"}',
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
  const MetricCard({
    super.key,
    required this.label,
    required this.value,
    this.tone,
  });
  final String label;
  final String value;
  final _StatusTone? tone;

  @override
  Widget build(BuildContext context) {
    final resolvedTone = tone ?? _StatusTone.neutral();
    return Container(
      width: 190,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: resolvedTone.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: resolvedTone.border),
        boxShadow: [
          BoxShadow(
            color: resolvedTone.border.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 13, color: resolvedTone.foreground),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: resolvedTone.foreground,
            ),
          ),
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
          Text(title,
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(content),
        ],
      ),
    );
  }
}

class DashboardHeroCard extends StatelessWidget {
  const DashboardHeroCard(
      {super.key, required this.title, required this.subtitle});

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
  const EmptyStateCard(
      {super.key, required this.title, required this.description});

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

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final tone = _statusToneFor(label, value);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: tone.background,
        border: Border.all(color: tone.border),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$label $value',
        style: TextStyle(
          color: tone.foreground,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem(this.label, this.icon);

  final String label;
  final IconData icon;
}

class _StatusTone {
  const _StatusTone({
    required this.background,
    required this.border,
    required this.foreground,
  });

  final Color background;
  final Color border;
  final Color foreground;

  factory _StatusTone.neutral() {
    return const _StatusTone(
      background: Color(0xFFF4FAF8),
      border: Color(0xFFD7E7E2),
      foreground: Color(0xFF31505A),
    );
  }
}

_StatusTone _statusToneFor(String label, String value) {
  final normalized = value.trim().toUpperCase();
  if (label.contains('위험') || normalized == 'HIGH' || value.contains('주의')) {
    return const _StatusTone(
      background: Color(0xFFFDEDEA),
      border: Color(0xFFF3B4AA),
      foreground: Color(0xFFB9382A),
    );
  }
  if (normalized == 'MEDIUM' || value.contains('관찰') || value.contains('비공개')) {
    return const _StatusTone(
      background: Color(0xFFFFF6E6),
      border: Color(0xFFF0CF88),
      foreground: Color(0xFF9A6A00),
    );
  }
  if (normalized == 'LOW' || value.contains('안정') || value.contains('공개')) {
    return const _StatusTone(
      background: Color(0xFFEAF7F0),
      border: Color(0xFFA8D8BC),
      foreground: Color(0xFF1F7A46),
    );
  }
  return _StatusTone.neutral();
}

ImageProvider<Object>? _profileImageProvider(String? url) {
  final text = url?.trim() ?? '';
  if (text.isEmpty) {
    return null;
  }
  return NetworkImage(text);
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
