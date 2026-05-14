import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../theme/game_theme.dart';
import 'dashboard_screen.dart';
import 'dart:math';
import '../services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late AnimationController _slideCtrl;
  late Animation<double> _pulse;
  late Animation<Offset> _slide;

  bool _showLogin = false;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
    _slideCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _pulse = Tween<double>(begin: 0.95, end: 1.05)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
    _slide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOut));

    Future.delayed(const Duration(milliseconds: 400), () {
      _slideCtrl.forward();
      Future.delayed(const Duration(seconds: 2), () => setState(() => _showLogin = true));
    });
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _slideCtrl.dispose();
    super.dispose();
  }

  void _goToDashboard(String name, String avatar) {
    context.read<GameProvider>().login(name, avatar);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const DashboardScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameTheme.navy,
      body: Stack(
        children: [
          ...List.generate(12, (i) => _Particle(index: i)),
          SafeArea(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 600),
              child: _showLogin
                  ? _LoginSignupScreen(onSuccess: _goToDashboard)
                  : _buildSplash(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSplash() {
    return Center(
      child: SlideTransition(
        position: _slide,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _pulse,
              child: Container(
                width: 120, height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: GameTheme.navyCard,
                  border: Border.all(color: GameTheme.gold, width: 3),
                  boxShadow: [BoxShadow(color: GameTheme.gold.withOpacity(0.4), blurRadius: 30, spreadRadius: 5)],
                ),
                child: const Center(child: Text("💸", style: TextStyle(fontSize: 60))),
              ),
            ),
            const SizedBox(height: 24),
            Text("BROKE", style: GameTheme.heading.copyWith(fontSize: 48, color: GameTheme.gold, letterSpacing: 8)),
            const SizedBox(height: 8),
            Text("A Financial Survival Game", style: GameTheme.subheading.copyWith(color: GameTheme.cyan)),
            const SizedBox(height: 40),
            const SizedBox(
              width: 24, height: 24,
              child: CircularProgressIndicator(color: GameTheme.cyan, strokeWidth: 2),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Separate stateful widget so each tab manages its own fields cleanly ──────

class _LoginSignupScreen extends StatefulWidget {
  final void Function(String name, String avatar) onSuccess;
  const _LoginSignupScreen({required this.onSuccess});

  @override
  State<_LoginSignupScreen> createState() => _LoginSignupScreenState();
}

class _LoginSignupScreenState extends State<_LoginSignupScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  // Shared
  String _selectedAvatar = "👨‍💻";
  final List<String> _avatars = ["👨‍💻", "👩‍💻", "🧑‍🎓", "👨‍🏫", "🧑‍💼", "👩‍🏫"];

  // Login tab
  final _loginEmailCtrl = TextEditingController();
  final _loginPasswordCtrl = TextEditingController();
  bool _loginLoading = false;
  String? _loginError;
  bool _loginPasswordVisible = false;

  // Signup tab
  final _signupNameCtrl = TextEditingController();
  final _signupEmailCtrl = TextEditingController();
  final _signupPasswordCtrl = TextEditingController();
  final _signupConfirmCtrl = TextEditingController();
  bool _signupLoading = false;
  String? _signupError;
  bool _signupPasswordVisible = false;

  // Guest
  final _guestNameCtrl = TextEditingController();
  bool _guestLoading = false;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _loginEmailCtrl.dispose();
    _loginPasswordCtrl.dispose();
    _signupNameCtrl.dispose();
    _signupEmailCtrl.dispose();
    _signupPasswordCtrl.dispose();
    _signupConfirmCtrl.dispose();
    _guestNameCtrl.dispose();
    super.dispose();
  }

  String _friendlyError(String raw) {
    if (raw.contains('user-not-found') || raw.contains('invalid-credential')) {
      return 'No account found with that email.';
    }
    if (raw.contains('wrong-password')) return 'Incorrect password.';
    if (raw.contains('email-already-in-use')) return 'That email is already registered. Try logging in.';
    if (raw.contains('weak-password')) return 'Password must be at least 6 characters.';
    if (raw.contains('invalid-email')) return 'Please enter a valid email address.';
    if (raw.contains('network-request-failed')) return 'No internet connection.';
    return 'Something went wrong. Please try again.';
  }

  Future<void> _doLogin() async {
    setState(() { _loginError = null; _loginLoading = true; });

    final email = _loginEmailCtrl.text.trim();
    final password = _loginPasswordCtrl.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() { _loginError = 'Please fill in both fields.'; _loginLoading = false; });
      return;
    }

    try {
      final user = await AuthService().signInWithEmail(email, password);
      if (user != null) {
        widget.onSuccess(user.displayName ?? email.split('@')[0], _selectedAvatar);
      } else {
        setState(() { _loginError = 'Login failed. Please try again.'; });
      }
    } catch (e) {
      setState(() { _loginError = _friendlyError(e.toString()); });
    } finally {
      if (mounted) setState(() => _loginLoading = false);
    }
  }

  Future<void> _doSignup() async {
    setState(() { _signupError = null; _signupLoading = true; });

    final name = _signupNameCtrl.text.trim();
    final email = _signupEmailCtrl.text.trim();
    final password = _signupPasswordCtrl.text.trim();
    final confirm = _signupConfirmCtrl.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      setState(() { _signupError = 'Please fill in all fields.'; _signupLoading = false; });
      return;
    }
    if (password != confirm) {
      setState(() { _signupError = 'Passwords do not match.'; _signupLoading = false; });
      return;
    }
    if (password.length < 6) {
      setState(() { _signupError = 'Password must be at least 6 characters.'; _signupLoading = false; });
      return;
    }

    try {
      final user = await AuthService().signUpWithEmail(email, password);
      if (user != null) {
        widget.onSuccess(name, _selectedAvatar);
      } else {
        setState(() { _signupError = 'Account creation failed. Please try again.'; });
      }
    } catch (e) {
      setState(() { _signupError = _friendlyError(e.toString()); });
    } finally {
      if (mounted) setState(() => _signupLoading = false);
    }
  }

  Future<void> _doGuest() async {
    setState(() => _guestLoading = true);
    final name = _guestNameCtrl.text.trim().isEmpty ? 'Player' : _guestNameCtrl.text.trim();
    try {
      final user = await AuthService().signInAnonymously();
      if (user != null) widget.onSuccess(name, _selectedAvatar);
    } catch (_) {
      // fail silently for guest — shouldn't happen
    } finally {
      if (mounted) setState(() => _guestLoading = false);
    }
  }

  Future<void> _doGoogle() async {
    try {
      final user = await AuthService().signInWithGoogle();
      if (user != null) {
        widget.onSuccess(user.displayName ?? 'Player', _selectedAvatar);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        children: [
          // Logo
          Container(
            width: 72, height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: GameTheme.navyCard,
              border: Border.all(color: GameTheme.gold, width: 2),
              boxShadow: [BoxShadow(color: GameTheme.goldGlow, blurRadius: 20)],
            ),
            child: const Center(child: Text("💸", style: TextStyle(fontSize: 38))),
          ),
          const SizedBox(height: 10),
          Text("BROKE", style: GameTheme.heading.copyWith(fontSize: 32, color: GameTheme.gold, letterSpacing: 6)),
          Text("₹15,000 stipend. Survive 30 days.", style: GameTheme.subheading.copyWith(fontSize: 12)),

          const SizedBox(height: 24),

          // Avatar picker (shared across tabs)
          _AvatarPicker(
            avatars: _avatars,
            selected: _selectedAvatar,
            onSelect: (a) => setState(() => _selectedAvatar = a),
          ),

          const SizedBox(height: 20),

          // Tab bar
          Container(
            decoration: BoxDecoration(
              color: GameTheme.navyCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: GameTheme.cyan.withOpacity(0.2)),
            ),
            child: TabBar(
              controller: _tabCtrl,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                color: GameTheme.cyan.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: GameTheme.cyan.withOpacity(0.5)),
              ),
              labelColor: GameTheme.cyan,
              unselectedLabelColor: Colors.white38,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1),
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: "LOGIN"),
                Tab(text: "SIGN UP"),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Tab views (fixed height so scroll works)
          SizedBox(
            height: 320,
            child: TabBarView(
              controller: _tabCtrl,
              children: [
                _buildLoginTab(),
                _buildSignupTab(),
              ],
            ),
          ),

          const SizedBox(height: 8),
          _Divider(label: "OR"),
          const SizedBox(height: 12),

          // Google
          _OutlineButton(
            label: "SIGN IN WITH GOOGLE",
            icon: "🌐",
            color: Colors.white,
            textColor: Colors.black,
            onTap: _doGoogle,
          ),

          const SizedBox(height: 10),

          // Guest
          _buildGuestRow(),
        ],
      ),
    );
  }

  Widget _buildLoginTab() {
    return Column(
      children: [
        _Field(controller: _loginEmailCtrl, hint: "Email", keyboardType: TextInputType.emailAddress),
        const SizedBox(height: 12),
        _Field(
          controller: _loginPasswordCtrl,
          hint: "Password",
          obscure: !_loginPasswordVisible,
          suffix: IconButton(
            icon: Icon(_loginPasswordVisible ? Icons.visibility_off : Icons.visibility,
                color: Colors.white38, size: 20),
            onPressed: () => setState(() => _loginPasswordVisible = !_loginPasswordVisible),
          ),
        ),
        if (_loginError != null) ...[
          const SizedBox(height: 10),
          _ErrorBanner(message: _loginError!),
        ],
        const Spacer(),
        _PrimaryButton(
          label: "LOGIN →",
          loading: _loginLoading,
          onTap: _doLogin,
        ),
      ],
    );
  }

  Widget _buildSignupTab() {
    return Column(
      children: [
        _Field(controller: _signupNameCtrl, hint: "Your Name (e.g. Priya, Arjun)"),
        const SizedBox(height: 10),
        _Field(controller: _signupEmailCtrl, hint: "Email", keyboardType: TextInputType.emailAddress),
        const SizedBox(height: 10),
        _Field(
          controller: _signupPasswordCtrl,
          hint: "Password (min 6 chars)",
          obscure: !_signupPasswordVisible,
          suffix: IconButton(
            icon: Icon(_signupPasswordVisible ? Icons.visibility_off : Icons.visibility,
                color: Colors.white38, size: 20),
            onPressed: () => setState(() => _signupPasswordVisible = !_signupPasswordVisible),
          ),
        ),
        const SizedBox(height: 10),
        _Field(controller: _signupConfirmCtrl, hint: "Confirm Password", obscure: !_signupPasswordVisible),
        if (_signupError != null) ...[
          const SizedBox(height: 8),
          _ErrorBanner(message: _signupError!),
        ],
        const Spacer(),
        _PrimaryButton(
          label: "CREATE ACCOUNT →",
          loading: _signupLoading,
          onTap: _doSignup,
          color: GameTheme.gold,
          textColor: Colors.black,
        ),
      ],
    );
  }

  Widget _buildGuestRow() {
    return Row(
      children: [
        Expanded(
          child: _Field(controller: _guestNameCtrl, hint: "Guest name (optional)"),
        ),
        const SizedBox(width: 10),
        _guestLoading
            ? const SizedBox(width: 60, child: Center(child: CircularProgressIndicator(color: GameTheme.cyan, strokeWidth: 2)))
            : GestureDetector(
          onTap: _doGuest,
          child: Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: GameTheme.navyCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: GameTheme.cyan.withOpacity(0.3)),
            ),
            child: const Center(
              child: Text("GUEST", style: TextStyle(color: GameTheme.cyan, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1)),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Small reusable widgets ───────────────────────────────────────────────────

class _AvatarPicker extends StatelessWidget {
  final List<String> avatars;
  final String selected;
  final void Function(String) onSelect;
  const _AvatarPicker({required this.avatars, required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: GameTheme.cardDecoration(glowColor: GameTheme.cyan),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Choose Avatar", style: GameTheme.subheading.copyWith(color: GameTheme.cyan, fontSize: 12)),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: avatars.map((a) {
                final sel = a == selected;
                return GestureDetector(
                  onTap: () => onSelect(a),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 10),
                    width: 50, height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: sel ? GameTheme.cyan.withOpacity(0.2) : GameTheme.navyLight,
                      border: Border.all(color: sel ? GameTheme.cyan : Colors.transparent, width: 2),
                    ),
                    child: Center(child: Text(a, style: const TextStyle(fontSize: 26))),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscure;
  final TextInputType? keyboardType;
  final Widget? suffix;
  const _Field({required this.controller, required this.hint, this.obscure = false, this.keyboardType, this.suffix});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white, fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 14),
        suffixIcon: suffix,
        filled: true,
        fillColor: GameTheme.navyLight,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: GameTheme.cyan.withOpacity(0.3))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: GameTheme.cyan.withOpacity(0.25))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: GameTheme.cyan)),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool loading;
  final Color color;
  final Color textColor;
  const _PrimaryButton({required this.label, required this.onTap, this.loading = false, this.color = GameTheme.cyan, this.textColor = Colors.black});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: Container(
        width: double.infinity, height: 52,
        decoration: GameTheme.glowDecoration(color),
        child: Center(
          child: loading
              ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2.5))
              : Text(label, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 1.5)),
        ),
      ),
    );
  }
}

class _OutlineButton extends StatelessWidget {
  final String label;
  final String icon;
  final Color color;
  final Color textColor;
  final VoidCallback onTap;
  const _OutlineButton({required this.label, required this.icon, required this.color, required this.textColor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity, height: 52,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(icon, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 10),
            Text(label, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1)),
          ],
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: GameTheme.red.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: GameTheme.red.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          const Text("⚠️", style: TextStyle(fontSize: 14)),
          const SizedBox(width: 8),
          Expanded(child: Text(message, style: const TextStyle(color: GameTheme.red, fontSize: 13))),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  final String label;
  const _Divider({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.white12, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(label, style: const TextStyle(color: Colors.white24, fontSize: 12)),
        ),
        Expanded(child: Divider(color: Colors.white12, thickness: 1)),
      ],
    );
  }
}

// ─── Background particles (unchanged) ────────────────────────────────────────

class _Particle extends StatefulWidget {
  final int index;
  const _Particle({required this.index});
  @override
  State<_Particle> createState() => _ParticleState();
}

class _ParticleState extends State<_Particle> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late double x, y, size;

  @override
  void initState() {
    super.initState();
    final rng = Random(widget.index * 42);
    x = rng.nextDouble();
    y = rng.nextDouble();
    size = rng.nextDouble() * 3 + 1;
    _ctrl = AnimationController(vsync: this, duration: Duration(seconds: 3 + rng.nextInt(4)))
      ..repeat(reverse: true);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: x * MediaQuery.of(context).size.width,
      top: y * MediaQuery.of(context).size.height,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) => Opacity(
          opacity: 0.1 + _ctrl.value * 0.3,
          child: Container(width: size, height: size,
              decoration: BoxDecoration(shape: BoxShape.circle, color: GameTheme.cyan)),
        ),
      ),
    );
  }
}