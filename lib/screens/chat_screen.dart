import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../theme/game_theme.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    final msgs = game.messages;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Text("📬", style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Text("MESSAGES", style: GameTheme.subheading.copyWith(color: GameTheme.cyan, letterSpacing: 2, fontSize: 13)),
              const SizedBox(width: 8),
              if (game.unreadCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: GameTheme.red, borderRadius: BorderRadius.circular(10)),
                  child: Text("${game.unreadCount} new", style: const TextStyle(color: Colors.white, fontSize: 11)),
                ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: msgs.length,
            itemBuilder: (_, i) => _MessageTile(index: i, msg: msgs[i]),
          ),
        ),
      ],
    );
  }
}

class _MessageTile extends StatelessWidget {
  final int index;
  final GameMessage msg;
  const _MessageTile({required this.index, required this.msg});

  @override
  Widget build(BuildContext context) {
    final unread = !msg.isRead;
    final hasAction = msg.spendAmount != null;

    return GestureDetector(
      onTap: () => _openMessage(context),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: unread ? GameTheme.navyCard : GameTheme.navyLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: msg.isScam ? GameTheme.red.withOpacity(0.5)
                : unread ? GameTheme.cyan.withOpacity(0.4)
                : Colors.white10,
          ),
          boxShadow: unread ? [BoxShadow(color: GameTheme.cyan.withOpacity(0.06), blurRadius: 10)] : [],
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 46, height: 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: GameTheme.navyLight,
                border: Border.all(
                  color: msg.isScam ? GameTheme.red : msg.isRead ? Colors.white12 : GameTheme.cyan,
                  width: 1.5,
                ),
              ),
              child: Center(child: Text(msg.icon ?? "💬", style: const TextStyle(fontSize: 22))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(msg.sender,
                          style: TextStyle(
                            color: msg.isScam ? GameTheme.red : Colors.white,
                            fontWeight: unread ? FontWeight.bold : FontWeight.normal,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      if (msg.isScam)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: GameTheme.red.withOpacity(0.2), borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: GameTheme.red.withOpacity(0.5))),
                          child: const Text("⚠️ SCAM?", style: TextStyle(color: GameTheme.red, fontSize: 9, fontWeight: FontWeight.bold)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(msg.preview,
                      style: GameTheme.subheading.copyWith(fontSize: 12),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  if (hasAction && !msg.isRead) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: GameTheme.orange.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: GameTheme.orange.withOpacity(0.4)),
                          ),
                          child: Text("TAP TO RESPOND  ₹${msg.spendAmount}",
                              style: const TextStyle(color: GameTheme.orange, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            if (unread)
              Container(width: 8, height: 8, decoration: const BoxDecoration(shape: BoxShape.circle, color: GameTheme.cyan)),
          ],
        ),
      ),
    );
  }

  void _openMessage(BuildContext context) {
    final game = context.read<GameProvider>();

    showModalBottomSheet(
      context: context,
      backgroundColor: GameTheme.navyCard,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      isScrollControlled: true,
      builder: (_) => ChangeNotifierProvider.value(
        value: game,
        child: _MessageDetail(index: index, msg: msg),
      ),
    );
  }
}

class _MessageDetail extends StatelessWidget {
  final int index;
  final GameMessage msg;
  const _MessageDetail({required this.index, required this.msg});

  @override
  Widget build(BuildContext context) {
    final game = context.read<GameProvider>();
    final alreadyResolved = msg.isRead && msg.spendAmount != null;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 52, height: 52,
                decoration: BoxDecoration(shape: BoxShape.circle, color: GameTheme.navyLight,
                    border: Border.all(color: msg.isScam ? GameTheme.red : GameTheme.cyan, width: 2)),
                child: Center(child: Text(msg.icon ?? "💬", style: const TextStyle(fontSize: 28))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(msg.sender, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    if (msg.isScam)
                      Text("⚠️ This looks like a SCAM!", style: TextStyle(color: GameTheme.red, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Body
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: GameTheme.navyLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white10),
            ),
            child: Text(msg.fullText, style: const TextStyle(color: Colors.white70, height: 1.5, fontSize: 14)),
          ),

          if (msg.isScam) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: GameTheme.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: GameTheme.red.withOpacity(0.4)),
              ),
              child: const Row(
                children: [
                  Text("🚨", style: TextStyle(fontSize: 20)),
                  SizedBox(width: 8),
                  Expanded(child: Text("Red flag: Guaranteed returns are impossible. This is a classic scam tactic.",
                      style: TextStyle(color: GameTheme.red, fontSize: 12))),
                ],
              ),
            ),
          ],

          const SizedBox(height: 20),

          if (msg.spendAmount != null && !alreadyResolved) ...[
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      game.resolveMessage(index, true);
                      _showConsequence(context, true, msg);
                    },
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        color: msg.isScam ? GameTheme.red.withOpacity(0.8) : GameTheme.green.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Text(
                          msg.isScam ? "Pay ₹${msg.spendAmount} 😬" : "Pay ₹${msg.spendAmount}",
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      game.markMessageRead(index);
                      Navigator.pop(context);
                    },
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        color: GameTheme.navyLight,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: const Center(child: Text("Ignore / Skip", style: TextStyle(color: Colors.white70))),
                    ),
                  ),
                ),
              ],
            ),
          ] else if (alreadyResolved) ...[
            Container(
              width: double.infinity, height: 48,
              decoration: BoxDecoration(color: GameTheme.navyLight, borderRadius: BorderRadius.circular(14)),
              child: const Center(child: Text("✅ Already resolved", style: TextStyle(color: Colors.white38))),
            ),
          ] else ...[
            GestureDetector(
              onTap: () { game.markMessageRead(index); Navigator.pop(context); },
              child: Container(
                width: double.infinity, height: 48,
                decoration: BoxDecoration(color: GameTheme.cyan.withOpacity(0.15), borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: GameTheme.cyan.withOpacity(0.4))),
                child: const Center(child: Text("Got it!", style: TextStyle(color: GameTheme.cyan))),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showConsequence(BuildContext context, bool paid, GameMessage msg) {
    final isScam = msg.isScam;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: GameTheme.navyCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          paid
              ? (isScam ? "💸 You got scammed!" : "✅ Done!")
              : "👍 Smart move!",
          style: TextStyle(
            color: isScam && paid ? GameTheme.red : GameTheme.green,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          paid
              ? (isScam
              ? "You lost ₹${msg.spendAmount}. Always verify before paying any 'fees' or 'processing charges'!"
              : "₹${msg.spendAmount} deducted. ${msg.spendCategory} expense logged.")
              : "You chose to skip this. ${isScam ? 'Good thinking — that was a scam!' : 'You can always revisit.'}",
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext); // close dialog
              Navigator.pop(context);       // close bottom sheet
            },
            child: const Text("OK", style: TextStyle(color: GameTheme.cyan)),
          ),
        ],
      ),
    );
  }
}