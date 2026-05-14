import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../theme/game_theme.dart';
import 'chat_screen.dart';
import 'expense_screen.dart';
import 'stats_screen.dart';
import 'profile_screen.dart';
import 'event_screen.dart';
import 'ending_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'leaderboard_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with TickerProviderStateMixin {
  late AnimationController _balanceAnim;
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    //print("USER ID: ${FirebaseAuth.instance.currentUser?.uid}");
    _balanceAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _balanceAnim.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _checkEvent();
    });  }

  @override
  void dispose() { _balanceAnim.dispose(); super.dispose(); }

  void _checkEvent() {
    final game = context.read<GameProvider>();

    if (game.gameOver) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const EndingScreen()),
      );
      return; // 🔥 VERY IMPORTANT (prevents event + ending clash)
    }

    if (game.shouldShowEvent) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const EventScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();

    return Scaffold(
      backgroundColor: GameTheme.navy,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(game),
            _buildBalanceCard(game),
            _buildDayProgress(game),
            Expanded(child: _buildBody(game)),
            _buildBottomNav(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(GameProvider game) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
            child: Row(
              children: [
                Container(
                  width: 42, height: 42,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: GameTheme.navyCard,
                      border: Border.all(color: GameTheme.cyan, width: 2)),
                  child: Center(child: Text(game.playerAvatar, style: const TextStyle(fontSize: 22))),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(game.playerName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                    Text("Intern • Pune 📍", style: GameTheme.subheading.copyWith(fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
          const Spacer(),
          // Day badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: GameTheme.navyCard,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: GameTheme.cyan.withOpacity(0.4)),
            ),
            child: Text("DAY ${game.day}/30",
                style: const TextStyle(color: GameTheme.cyan, fontWeight: FontWeight.bold, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(GameProvider game) {
    final isLow = game.balance < 2000;
    final isCritical = game.balance < 500;
    final cardColor = isCritical ? GameTheme.red : isLow ? GameTheme.orange : GameTheme.green;

    return AnimatedBuilder(
      animation: _balanceAnim,
      builder: (_, __) => SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, -0.2), end: Offset.zero)
            .animate(CurvedAnimation(parent: _balanceAnim, curve: Curves.easeOut)),
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [GameTheme.navyCard, GameTheme.navyLight],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: cardColor.withOpacity(0.5), width: 1.5),
            boxShadow: [BoxShadow(color: cardColor.withOpacity(0.2), blurRadius: 20, spreadRadius: 2)],
          ),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: cardColor)),
                      const SizedBox(width: 6),
                      Text("HDFC BANK  •  ****4291",
                          style: GameTheme.subheading.copyWith(fontSize: 12, letterSpacing: 1)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "₹${(game.balance < 0 ? 0 : game.balance).toString().replaceAllMapped(
                      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                          (m) => '${m[1]},',
                    )}",
                    style: GameTheme.balanceText.copyWith(
                      color: cardColor,
                      fontSize: isCritical ? 28 : 32,
                    ),
                  ),
                  Text(
                    isCritical ? "⚠️ CRITICAL — Almost broke!" : isLow ? "⚡ Low balance" : "Available Balance",
                    style: GameTheme.subheading.copyWith(color: cardColor.withOpacity(0.8), fontSize: 11),
                  ),
                ],
              ),
              const Spacer(),
              Column(
                children: [
                  Text("💳", style: const TextStyle(fontSize: 36)),
                  const SizedBox(height: 4),
                  Text("₹${game.totalSpent} spent",
                      style: GameTheme.subheading.copyWith(fontSize: 10, color: GameTheme.red.withOpacity(0.8))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDayProgress(GameProvider game) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Month Progress", style: GameTheme.subheading.copyWith(fontSize: 12)),
              Text("${game.day} of 30 days", style: GameTheme.subheading.copyWith(fontSize: 12, color: GameTheme.cyan)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: game.day / 30,
              backgroundColor: GameTheme.navyCard,
              valueColor: AlwaysStoppedAnimation(GameTheme.cyan),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(GameProvider game) {
    switch (_tab) {
      case 0: return _buildHome(game);
      case 1: return const ChatScreen();
      case 2: return const ExpenseScreen();
      case 3: return const StatsScreen();
      default: return _buildHome(game);
    }
  }

  Widget _buildHome(GameProvider game) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick actions
          Text("QUICK ACTIONS", style: GameTheme.subheading.copyWith(color: GameTheme.cyan, letterSpacing: 2, fontSize: 11)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _QuickAction(icon: "📬", label: "Messages", badge: game.unreadCount,
                  color: GameTheme.cyan, onTap: () => setState(() => _tab = 1))),
              const SizedBox(width: 10),
              Expanded(child: _QuickAction(icon: "💰", label: "Log Expense",
                  color: GameTheme.orange, onTap: () => setState(() => _tab = 2))),
              const SizedBox(width: 10),
              Expanded(child: _QuickAction(icon: "📊", label: "Stats",
                  color: GameTheme.purple, onTap: () => setState(() => _tab = 3))),
            ],
          ),

          const SizedBox(height: 20),

          // Advance day button
          GestureDetector(
            onTap: () {
              game.nextDay();
              _checkEvent();
            },
            child: Container(
              width: double.infinity, height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [GameTheme.navyCard, const Color(0xFF1E2748)]),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: GameTheme.gold.withOpacity(0.4)),
                boxShadow: [BoxShadow(color: GameTheme.goldGlow, blurRadius: 12)],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(game.day >= 30 ? "🏁" : "⏩", style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 10),
                  Text(
                    game.day >= 30 ? "END THE MONTH →" : "ADVANCE TO DAY ${game.day + 1}",
                    style: const TextStyle(color: GameTheme.gold, fontWeight: FontWeight.bold, letterSpacing: 1.5, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const LeaderboardScreen(),
                ),
              );
            },
            child: Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    GameTheme.gold,
                    Color(0xFFFFD54F),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: GameTheme.goldGlow,
                    blurRadius: 12,
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  "🏆 VIEW LEADERBOARD",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Tips section
          Text("FINANCIAL TIPS", style: GameTheme.subheading.copyWith(color: GameTheme.cyan, letterSpacing: 2, fontSize: 11)),
          const SizedBox(height: 10),
          _TipCard(
            icon: "🔍",
            title: "Spot a Scam",
            body: "If someone guarantees returns, it's a red flag. Real investments have risk.",
            color: GameTheme.red,
          ),
          const SizedBox(height: 10),
          _TipCard(
            icon: "💡",
            title: "50/30/20 Rule",
            body: "50% needs, 30% wants, 20% savings. Simple formula to never go broke.",
            color: GameTheme.green,
          ),
          const SizedBox(height: 10),

          // Learn more
          GestureDetector(
            onTap: () async {
              final url = Uri.parse("https://www.google.com/search?q=how+to+manage+salary+india+first+job");
              await launchUrl(url);
            },
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: GameTheme.cardDecoration(glowColor: GameTheme.purple),
              child: Row(
                children: [
                  const Text("🌐", style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Learn about scam detection", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        Text("Opens real guide in browser →", style: GameTheme.subheading.copyWith(color: GameTheme.purple)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    final items = [
      {"icon": "🏠", "label": "Home"},
      {"icon": "📬", "label": "Messages"},
      {"icon": "💰", "label": "Expenses"},
      {"icon": "📊", "label": "Stats"},
    ];
    return Container(
      decoration: BoxDecoration(
        color: GameTheme.navyCard,
        border: Border(top: BorderSide(color: GameTheme.cyan.withOpacity(0.2))),
      ),
      child: Row(
        children: List.generate(items.length, (i) {
          final selected = _tab == i;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _tab = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(
                      color: selected ? GameTheme.cyan : Colors.transparent, width: 2)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(items[i]["icon"]!, style: TextStyle(fontSize: selected ? 22 : 18)),
                    const SizedBox(height: 2),
                    Text(items[i]["label"]!,
                        style: TextStyle(color: selected ? GameTheme.cyan : Colors.white38, fontSize: 10)),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final String icon, label;
  final Color color;
  final VoidCallback onTap;
  final int badge;
  const _QuickAction({required this.icon, required this.label, required this.color, required this.onTap, this.badge = 0});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: GameTheme.navyCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            Column(
              children: [
                Text(icon, style: const TextStyle(fontSize: 26)),
                const SizedBox(height: 4),
                Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
              ],
            ),
            if (badge > 0)
              Positioned(
                top: 0, right: 8,
                child: Container(
                  width: 18, height: 18,
                  decoration: const BoxDecoration(shape: BoxShape.circle, color: GameTheme.red),
                  child: Center(child: Text("$badge", style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  final String icon, title, body;
  final Color color;
  const _TipCard({required this.icon, required this.title, required this.body, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: GameTheme.cardDecoration(glowColor: color),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Text(body, style: GameTheme.subheading.copyWith(fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}