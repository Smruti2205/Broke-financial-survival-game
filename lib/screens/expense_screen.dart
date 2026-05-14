import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../theme/game_theme.dart';

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key});
  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  final _amountCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  @override
  void dispose() {
    _amountCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("💰  LOG EXPENSE", style: GameTheme.subheading.copyWith(color: GameTheme.gold, letterSpacing: 2, fontSize: 13)),
          const SizedBox(height: 14),

          // Category dropdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: GameTheme.cardDecoration(glowColor: GameTheme.orange),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                dropdownColor: GameTheme.navyCard,
                value: game.selectedCategory,
                style: const TextStyle(color: Colors.white, fontSize: 15),
                icon: const Icon(Icons.keyboard_arrow_down, color: GameTheme.orange),
                items: game.categories.map((cat) {
                  final icons = {
                    "Food": "🍛", "Transport": "🚌", "Fun": "🎮",
                    "EMI": "🏠", "Emergency": "🚨", "Savings": "🏦",
                  };
                  return DropdownMenuItem(
                    value: cat,
                    child: Row(
                      children: [
                        Text(icons[cat] ?? "💸", style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: 10),
                        Text(cat),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (val) => game.setCategory(val!),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Amount input
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: GameTheme.cardDecoration(glowColor: GameTheme.gold),
            child: TextField(
              controller: _amountCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: GameTheme.gold, fontSize: 20, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                prefixText: "₹  ",
                prefixStyle: const TextStyle(color: GameTheme.gold, fontSize: 20, fontWeight: FontWeight.bold),
                hintText: "0",
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 20),
                border: InputBorder.none,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Description
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: GameTheme.cardDecoration(),
            child: TextField(
              controller: _descCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Note (optional)",
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                border: InputBorder.none,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Submit button
          GestureDetector(
            onTap: () {
              final amount = int.tryParse(_amountCtrl.text.trim()) ?? 0;
              if (amount <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: const Text("Enter a valid amount"), backgroundColor: GameTheme.red));
                return;
              }
              if (amount > game.balance) {
                showDialog(context: context, builder: (_) => AlertDialog(
                  backgroundColor: GameTheme.navyCard,
                  title: const Text("⚠️ Low Balance!", style: TextStyle(color: GameTheme.red)),
                  content: Text("You only have ₹${game.balance}. Spending ₹$amount might bankrupt you!",
                      style: const TextStyle(color: Colors.white70)),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel", style: TextStyle(color: Colors.white38))),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _doSpend(context, game, amount);
                      },
                      child: const Text("Spend Anyway", style: TextStyle(color: GameTheme.red)),
                    ),
                  ],
                ));
                return;
              }
              _doSpend(context, game, amount);
            },
            child: Container(
              width: double.infinity, height: 56,
              decoration: GameTheme.glowDecoration(GameTheme.orange),
              child: const Center(
                child: Text("DEDUCT EXPENSE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.5)),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Expense history
          if (game.expenses.isNotEmpty) ...[
            Text("RECENT EXPENSES", style: GameTheme.subheading.copyWith(color: GameTheme.cyan, letterSpacing: 2, fontSize: 11)),
            const SizedBox(height: 10),
            ...game.expenses.reversed.take(10).map((e) => _ExpenseTile(expense: e)),
          ],
        ],
      ),
    );
  }

  void _doSpend(BuildContext context, GameProvider game, int amount) {
    final desc = _descCtrl.text.trim().isEmpty ? game.selectedCategory : _descCtrl.text.trim();
    game.spend(amount, game.selectedCategory, desc);
    _amountCtrl.clear();
    _descCtrl.clear();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("₹$amount deducted from ${game.selectedCategory}"),
      backgroundColor: GameTheme.navyCard,
    ));
  }
}

class _ExpenseTile extends StatelessWidget {
  final Expense expense;
  const _ExpenseTile({required this.expense});

  @override
  Widget build(BuildContext context) {
    final icons = {
      "Food": "🍛", "Transport": "🚌", "Fun": "🎮",
      "EMI": "🏠", "Emergency": "🚨", "Savings": "🏦",
    };
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: GameTheme.cardDecoration(),
      child: Row(
        children: [
          Text(icons[expense.category] ?? "💸", style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(expense.description, style: const TextStyle(color: Colors.white, fontSize: 13)),
                Text("Day ${expense.day} • ${expense.category}", style: GameTheme.subheading.copyWith(fontSize: 11)),
              ],
            ),
          ),
          Text("-₹${expense.amount}", style: const TextStyle(color: GameTheme.red, fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }
}