import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../services/firestore_service.dart';
import '../theme/game_theme.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dashboard_screen.dart';

class EndingScreen extends StatefulWidget {
  const EndingScreen({super.key});
  @override
  State<EndingScreen> createState() => _EndingScreenState();
}

class _EndingScreenState extends State<EndingScreen> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scale = CurvedAnimation(
      parent: _ctrl,
      curve: Curves.elasticOut,
    );

    _ctrl.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final game = context.read<GameProvider>();

      await FirestoreService().saveLeaderboardEntry(
        name: game.playerName,
        avatar: game.playerAvatar,
        balance: game.balance,
        day: game.day,
        scams: game.scamsFallenFor,
        ending: game.getEnding().name,
      );
    });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    final ending = game.getEnding();
    final firestore = FirestoreService();

    final endingData = {
      GameEnding.wolfOfPune: {
        "title": "The Wolf of Pune 💎",
        "subtitle": "You survived AND thrived!",
        "body": "You managed your ₹15,000 stipend like a pro. Avoided scams, tracked expenses, and finished the month with enough to spare. Pune sees a future finance bro.",
        "color": GameTheme.gold,
        "icon": "🐺",
        "bg": [const Color(0xFF1A1500), const Color(0xFF2A2000)],
      },
      GameEnding.barelysurvived: {
        "title": "Barely Survived ✅",
        "subtitle": "Close call, but you made it.",
        "body": "You finished the month with some balance left. A few close calls, but smart decisions when it counted. Next month, start with an emergency fund.",
        "color": GameTheme.green,
        "icon": "😅",
        "bg": [const Color(0xFF0A1A0E), const Color(0xFF0F220A)],
      },
      GameEnding.ramenMonth: {
        "title": "Ramen Month 🍜",
        "subtitle": "Budget: Ramen only.",
        "body": "You spent too much too fast. The iPhone and the bar nights added up. Next time, needs before wants — and always pay rent first!",
        "color": GameTheme.orange,
        "icon": "🍜",
        "bg": [const Color(0xFF1A1000), const Color(0xFF221500)],
      },
      GameEnding.calledMom: {
        "title": "Called Mom 📞",
        "subtitle": "The eternal safety net.",
        "body": "Your balance went negative. The month broke you. But hey — everyone calls mom sometimes. Create an emergency fund before next month starts.",
        "color": GameTheme.red,
        "icon": "📞",
        "bg": [const Color(0xFF1A0A0A), const Color(0xFF220808)],
      },
      GameEnding.scammersFav: {
        "title": "The Scammer's Favourite 🎣",
        "subtitle": "Fool me twice, shame on me.",
        "body": "You fell for 2+ scams this month. Guaranteed returns, lucky draws, processing fees — these are ALL red flags. Never pay to receive money.",
        "color": GameTheme.purple,
        "icon": "🎣",
        "bg": [const Color(0xFF0E0A1A), const Color(0xFF14102A)],
      },
    };

    final data = endingData[ending]!;
    final color = data['color'] as Color;

    return Scaffold(
      backgroundColor: GameTheme.navy,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              ScaleTransition(
                scale: _scale,
                child: Container(
                  width: 120, height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: GameTheme.navyCard,
                    border: Border.all(color: color, width: 3),
                    boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 35, spreadRadius: 5)],
                  ),
                  child: Center(child: Text(data['icon'] as String, style: const TextStyle(fontSize: 60))),
                ),
              ),

              const SizedBox(height: 24),
              Text("MONTH COMPLETE", style: GameTheme.subheading.copyWith(color: color, letterSpacing: 3)),
              const SizedBox(height: 8),
              Text(data['title'] as String,
                  textAlign: TextAlign.center,
                  style: GameTheme.heading.copyWith(fontSize: 28, color: color)),
              const SizedBox(height: 8),
              Text(data['subtitle'] as String,
                  style: GameTheme.subheading.copyWith(fontSize: 16, color: Colors.white70)),

              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.all(18),
                decoration: GameTheme.cardDecoration(glowColor: color),
                child: Text(data['body'] as String,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70, fontSize: 15, height: 1.7)),
              ),

              const SizedBox(height: 20),

              // Financial report
              Container(
                padding: const EdgeInsets.all(18),
                decoration: GameTheme.cardDecoration(),
                child: Column(
                  children: [
                    Text("FINAL REPORT", style: GameTheme.subheading.copyWith(color: GameTheme.cyan, letterSpacing: 2, fontSize: 11)),
                    const SizedBox(height: 14),
                    _ReportRow("Started with", "₹15,000", GameTheme.green),
                    _ReportRow("Final balance", "₹${game.balance}", color),
                    _ReportRow("Total spent", "₹${game.totalSpent}", GameTheme.red),
                    _ReportRow(
                      "Scams hit",
                      "${game.scamsFallenFor}",
                      game.scamsFallenFor > 0 ? GameTheme.red : GameTheme.green,
                    ),
                    _ReportRow("Decisions made", "${game.expenses.length}", GameTheme.cyan),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Action buttons
              GestureDetector(
                onTap: () async {
                  final text =
                      "I got the '${data['title']}' ending in BROKE — A Financial Survival Game! 💸";

                  final uri = Uri.parse(
                    "https://wa.me/?text=${Uri.encodeComponent(text)}",
                  );

                  try {
                    await launchUrl(
                      uri,
                      mode: LaunchMode.externalApplication,
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Could not open WhatsApp")),
                    );
                  }
                },
                child: Container(
                  width: double.infinity, height: 52,
                  decoration: GameTheme.glowDecoration(const Color(0xFF25D366)),
                  child: const Center(
                    child: Text("📤  Share on WhatsApp", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              GestureDetector(
                onTap: () async {
                  final game = context.read<GameProvider>();

                  await game.resetGame();

                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const DashboardScreen(),
                    ),
                        (route) => false,
                  );
                },
                child: Container(
                  width: double.infinity,
                  height: 52,
                  decoration: BoxDecoration(
                    color: GameTheme.navyCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: color.withOpacity(0.4),
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      "🔄  Play Again",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReportRow extends StatelessWidget {
  final String label, value;
  final Color color;
  const _ReportRow(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GameTheme.subheading),
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 15)),
        ],
      ),
    );
  }
}