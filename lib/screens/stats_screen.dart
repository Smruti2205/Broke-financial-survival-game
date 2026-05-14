import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../theme/game_theme.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    final byCategory = game.spendingByCategory;
    final total = game.totalSpent;

    final catColors = {
      "Food": GameTheme.orange,
      "Transport": GameTheme.cyan,
      "Fun": GameTheme.purple,
      "EMI": GameTheme.gold,
      "Emergency": GameTheme.red,
      "Savings": GameTheme.green,
    };

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("📊  YOUR STATS", style: GameTheme.subheading.copyWith(color: GameTheme.purple, letterSpacing: 2, fontSize: 13)),
          const SizedBox(height: 14),

          // Summary cards
          Row(
            children: [
              Expanded(child: _StatCard(label: "Balance", value: "₹${game.balance}", color: GameTheme.green, icon: "💰")),
              const SizedBox(width: 10),
              Expanded(child: _StatCard(label: "Total Spent", value: "₹$total", color: GameTheme.red, icon: "💸")),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _StatCard(label: "Day", value: "${game.day}/30", color: GameTheme.cyan, icon: "📅")),
              const SizedBox(width: 10),
              Expanded(child: _StatCard(label: "Scams Hit", value: "${game.scamsFallenFor}", color: GameTheme.orange, icon: "🎣")),
            ],
          ),

          const SizedBox(height: 24),

          if (byCategory.isNotEmpty) ...[
            Text("SPENDING BY CATEGORY", style: GameTheme.subheading.copyWith(color: GameTheme.cyan, letterSpacing: 2, fontSize: 11)),
            const SizedBox(height: 14),
            ...byCategory.entries.map((e) {
              final pct = total > 0 ? (e.value / total) : 0.0;
              final color = catColors[e.key] ?? GameTheme.cyan;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(e.key, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        Text("₹${e.value} (${(pct * 100).toStringAsFixed(0)}%)",
                            style: TextStyle(color: color, fontSize: 13)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: pct.toDouble(),
                        backgroundColor: GameTheme.navyCard,
                        valueColor: AlwaysStoppedAnimation(color),
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ] else ...[
            Container(
              width: double.infinity, padding: const EdgeInsets.all(40),
              decoration: GameTheme.cardDecoration(),
              child: Column(
                children: [
                  const Text("📭", style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 12),
                  Text("No expenses yet", style: GameTheme.subheading),
                  Text("Start logging expenses or open your messages!", style: GameTheme.subheading.copyWith(fontSize: 12)),
                ],
              ),
            ),
          ],

          const SizedBox(height: 20),

          // Health indicator
          Container(
            padding: const EdgeInsets.all(16),
            decoration: GameTheme.cardDecoration(glowColor: _getHealthColor(game)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("FINANCIAL HEALTH", style: GameTheme.subheading.copyWith(color: GameTheme.cyan, letterSpacing: 1, fontSize: 11)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text(_getHealthEmoji(game), style: const TextStyle(fontSize: 36)),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_getHealthLabel(game),
                              style: TextStyle(color: _getHealthColor(game), fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 4),
                          Text(_getHealthTip(game), style: GameTheme.subheading.copyWith(fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getHealthColor(GameProvider g) {
    if (g.balance > 8000) return GameTheme.green;
    if (g.balance > 3000) return GameTheme.gold;
    if (g.balance > 1000) return GameTheme.orange;
    return GameTheme.red;
  }

  String _getHealthEmoji(GameProvider g) {
    if (g.balance > 8000) return "😎";
    if (g.balance > 3000) return "🙂";
    if (g.balance > 1000) return "😰";
    return "😱";
  }

  String _getHealthLabel(GameProvider g) {
    if (g.balance > 8000) return "Financially Fit!";
    if (g.balance > 3000) return "Doing OK";
    if (g.balance > 1000) return "Watch out!";
    return "DANGER ZONE";
  }

  String _getHealthTip(GameProvider g) {
    if (g.balance > 8000) return "You're crushing it. Consider saving for emergencies.";
    if (g.balance > 3000) return "Decent balance. Avoid impulse buys for the rest of the month.";
    if (g.balance > 1000) return "Getting tight. Cut non-essentials NOW.";
    return "Critical! Stop all non-essential spending immediately.";
  }
}

class _StatCard extends StatelessWidget {
  final String label, value, icon;
  final Color color;
  const _StatCard({required this.label, required this.value, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: GameTheme.cardDecoration(glowColor: color),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 6),
              Text(label, style: GameTheme.subheading.copyWith(fontSize: 11)),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}