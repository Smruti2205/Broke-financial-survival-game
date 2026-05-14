import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../theme/game_theme.dart';
import '../services/auth_service.dart';
import 'splash_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();

    return Scaffold(
      backgroundColor: GameTheme.navy,
      appBar: AppBar(
        backgroundColor: GameTheme.navyCard,
        title: const Text("PLAYER PROFILE",
            style: TextStyle(color: GameTheme.cyan, letterSpacing: 2, fontSize: 14)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Avatar
            Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: GameTheme.navyCard,
                border: Border.all(color: GameTheme.gold, width: 3),
                boxShadow: [BoxShadow(color: GameTheme.goldGlow, blurRadius: 25)],
              ),
              child: Center(child: Text(game.playerAvatar, style: const TextStyle(fontSize: 56))),
            ),
            const SizedBox(height: 12),
            Text(game.playerName, style: GameTheme.heading.copyWith(fontSize: 26)),
            Text("Level 1 Intern  •  Pune 📍", style: GameTheme.subheading),

            const SizedBox(height: 24),

            // Stats grid
            Container(
              padding: const EdgeInsets.all(16),
              decoration: GameTheme.cardDecoration(glowColor: GameTheme.cyan),
              child: Column(
                children: [
                  Text("GAME STATS",
                      style: GameTheme.subheading.copyWith(color: GameTheme.cyan, letterSpacing: 2, fontSize: 11)),
                  const SizedBox(height: 14),
                  _StatsRow("Balance", "₹${game.balance}", GameTheme.gold),
                  const Divider(color: Colors.white10),
                  _StatsRow("Day", "${game.day} of 30", GameTheme.cyan),
                  const Divider(color: Colors.white10),
                  _StatsRow("Total Spent", "₹${game.totalSpent}", GameTheme.red),
                  const Divider(color: Colors.white10),
                  _StatsRow("Scams Fallen For", "${game.scamsFallenFor}", GameTheme.orange),
                  const Divider(color: Colors.white10),
                  _StatsRow("Decisions Made", "${game.expenses.length}", GameTheme.purple),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Badges
            Container(
              padding: const EdgeInsets.all(16),
              decoration: GameTheme.cardDecoration(glowColor: GameTheme.gold),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("BADGES",
                      style: GameTheme.subheading.copyWith(color: GameTheme.gold, letterSpacing: 2, fontSize: 11)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10, runSpacing: 10,
                    children: [
                      _Badge(icon: "🎮", label: "Player", earned: true),
                      _Badge(icon: "🏦", label: "Received Stipend", earned: true),
                      _Badge(icon: "🕵️", label: "Scam Detector",
                          earned: game.scamsFallenFor == 0 && game.day >= 10),
                      _Badge(icon: "💎", label: "Wolf of Pune",
                          earned: game.balance >= 5000 && game.day >= 30),
                      _Badge(icon: "📊", label: "Smart Saver",
                          earned: (game.spendingByCategory["Savings"] ?? 0) > 0),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Restart button
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    backgroundColor: GameTheme.navyCard,
                    title: const Text("Restart Game?", style: TextStyle(color: Colors.white)),
                    content: const Text("All progress will be lost.", style: TextStyle(color: Colors.white70)),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Cancel", style: TextStyle(color: Colors.white38)),
                      ),
                      TextButton(
                        onPressed: () async {
                          final game = context.read<GameProvider>();
                          await game.resetGame();
                          await AuthService().signOut(); // signs out Firebase + Google in one call
                          Navigator.pop(context);
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (_) => const SplashScreen()),
                                (route) => false,
                          );
                        },
                        child: const Text("Restart", style: TextStyle(color: GameTheme.red)),
                      ),
                    ],
                  ),
                );
              },
              child: Container(
                width: double.infinity, height: 52,
                decoration: BoxDecoration(
                  color: GameTheme.red.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: GameTheme.red.withOpacity(0.4)),
                ),
                child: const Center(
                  child: Text("🔄  RESTART GAME",
                      style: TextStyle(color: GameTheme.red, fontWeight: FontWeight.bold, letterSpacing: 1)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final String label, value;
  final Color color;
  const _StatsRow(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
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

class _Badge extends StatelessWidget {
  final String icon, label;
  final bool earned;
  const _Badge({required this.icon, required this.label, required this.earned});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: earned ? GameTheme.gold.withOpacity(0.15) : GameTheme.navyLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: earned ? GameTheme.gold.withOpacity(0.5) : Colors.white10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon,
              style: TextStyle(fontSize: 16, color: earned ? null : Colors.white.withOpacity(0.2))),
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(
                  color: earned ? GameTheme.gold : Colors.white.withOpacity(0.3),
                  fontSize: 12,
                  fontWeight: earned ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}