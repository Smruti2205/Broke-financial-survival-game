import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../theme/game_theme.dart';

class EventScreen extends StatefulWidget {
  const EventScreen({super.key});
  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fadeIn;
  int? _chosen;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fadeIn = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    final event = game.currentEvent;
    if (event == null) return const Scaffold(backgroundColor: GameTheme.navy);

    final choices = event['choices'] as List;
    final isScamEvent = event['isScam'] == true;

    return Scaffold(
      backgroundColor: GameTheme.navy,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeIn,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: GameTheme.navyCard,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: GameTheme.gold.withOpacity(0.4)),
                      ),
                      child: Text("📅 DAY ${event['day']} EVENT",
                          style: const TextStyle(color: GameTheme.gold, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // Icon
                Center(
                  child: Container(
                    width: 90, height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: GameTheme.navyCard,
                      border: Border.all(color: isScamEvent ? GameTheme.red : GameTheme.cyan, width: 2.5),
                      boxShadow: [BoxShadow(
                          color: (isScamEvent ? GameTheme.red : GameTheme.cyan).withOpacity(0.3),
                          blurRadius: 25, spreadRadius: 3)],
                    ),
                    child: Center(child: Text(event['icon'] ?? "⚡", style: const TextStyle(fontSize: 46))),
                  ),
                ),

                const SizedBox(height: 20),

                // Title
                Center(
                  child: Text(event['title'],
                      textAlign: TextAlign.center,
                      style: GameTheme.heading.copyWith(fontSize: 22, color: isScamEvent ? GameTheme.red : Colors.white)),
                ),

                const SizedBox(height: 16),

                // Story
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: GameTheme.navyCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isScamEvent ? GameTheme.red.withOpacity(0.3) : Colors.white10),
                  ),
                  child: Text(event['story'],
                      style: const TextStyle(color: Colors.white70, fontSize: 15, height: 1.6)),
                ),

                const SizedBox(height: 24),

                Text("WHAT DO YOU DO?", style: GameTheme.subheading.copyWith(color: GameTheme.cyan, letterSpacing: 2)),
                const SizedBox(height: 12),

                Expanded(
                  child: ListView.builder(
                    itemCount: choices.length,
                    itemBuilder: (_, i) {
                      final choice = choices[i];
                      final cost = choice['cost'] as int;
                      final isScamChoice = choice['isScam'] == true;
                      final isSelected = _chosen == i;

                      Color borderColor = isScamChoice ? GameTheme.red : cost > 2000 ? GameTheme.orange : GameTheme.green;
                      if (isSelected) borderColor = GameTheme.gold;

                      return GestureDetector(
                        onTap: _chosen != null ? null : () {
                          setState(() => _chosen = i);
                          Future.delayed(const Duration(milliseconds: 600), () {
                            game.resolveEvent(i);
                            _showResult(context, choice, event['title']);
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isSelected ? borderColor.withOpacity(0.2) : GameTheme.navyCard,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: isSelected ? borderColor : borderColor.withOpacity(0.4), width: isSelected ? 2 : 1),
                            boxShadow: isSelected ? [BoxShadow(color: borderColor.withOpacity(0.3), blurRadius: 12)] : [],
                          ),
                          child: Row(
                            children: [
                              Text("${i + 1}", style: TextStyle(
                                  color: borderColor, fontWeight: FontWeight.bold, fontSize: 18)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(choice['label'], style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                                    if (cost > 0) ...[
                                      const SizedBox(height: 4),
                                      Text("-₹$cost from ${choice['category']}",
                                          style: TextStyle(color: GameTheme.red.withOpacity(0.8), fontSize: 12)),
                                    ],
                                  ],
                                ),
                              ),
                              if (isSelected)
                                const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: GameTheme.gold)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  void _showResult(BuildContext context, Map choice, String eventTitle) {
    final effect = choice['effect'] as String;

    final tips = {
      'scam': "🚨 Classic scam! Never pay fees to 'claim' prizes.",
      'detective': "🕵️ Brilliant! Asking for registration number is how real scam checkers operate.",
      'safe': "✅ Safe choice. Paying more now avoids bigger issues later.",
      'risky_phone': "⚠️ Your phone health is now at risk. Cheap repairs = bigger problems.",
      'invest_wise': "📈 Smart! SIPs are low-risk, disciplined investments.",
      'generous': "❤️ Helpful, but remember: emergency fund matters too.",
      'miss_opportunity': "😬 Cracked screen might cost you opportunities ahead...",
    };

    final tip = tips[effect] ?? "Every decision has consequences in real life too.";

    showDialog(
      context: context,
      barrierDismissible: false, // optional but safer
      builder: (dialogContext) => AlertDialog(
        backgroundColor: GameTheme.navyCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(eventTitle, style: const TextStyle(color: Colors.white, fontSize: 16)),
        content: Text(tip, style: const TextStyle(color: Colors.white70, height: 1.5)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext); // close dialog
              Navigator.pop(context);       // close event screen
            },
            child: const Text("Got it!", style: TextStyle(color: GameTheme.cyan)),
          ),
        ],
      ),
    );
  }
}