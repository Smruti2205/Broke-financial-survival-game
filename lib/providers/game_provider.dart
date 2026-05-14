import 'package:flutter/material.dart';
import 'dart:math';
import '../services/firestore_service.dart';

enum GameEnding { wolfOfPune, barelysurvived, ramenMonth, calledMom, scammersFav }

class Expense {
  final String category;
  final int amount;
  final int day;
  final String description;
  Expense({required this.category, required this.amount, required this.day, required this.description});
}

class GameMessage {
  final String sender;
  final String preview;
  final String fullText;
  final String? icon;
  final int? spendAmount;
  final String? spendCategory;
  final bool isScam;
  final bool isRead;
  final String tag;

  GameMessage({
    required this.sender,
    required this.preview,
    required this.fullText,
    this.icon,
    this.spendAmount,
    this.spendCategory,
    this.isScam = false,
    this.isRead = false,
    required this.tag,
  });

  GameMessage copyWith({bool? isRead}) => GameMessage(
    sender: sender, preview: preview, fullText: fullText,
    icon: icon, spendAmount: spendAmount, spendCategory: spendCategory,
    isScam: isScam, isRead: isRead ?? this.isRead, tag: tag,
  );
}

class GameProvider extends ChangeNotifier {
  final _firestore = FirestoreService();

  // ── Player ──────────────────────────────────────────────────
  String playerName = "Player";
  String playerAvatar = "👨‍💻";
  bool isLoggedIn = false;

  // ── Game state ───────────────────────────────────────────────
  int balance = 15000;
  int day = 1;
  int scamsFallenFor = 0;
  bool gameOver = false;
  int _phoneHealth = 100;

  String selectedCategory = "Food";
  final List<String> categories = ["Food", "Transport", "Fun", "EMI", "Emergency", "Savings"];

  // ── Expense log ──────────────────────────────────────────────
  List<Expense> expenses = [];

  // ── Messages ─────────────────────────────────────────────────
  // Built with the player's real name — call _buildMessages(name) whenever name is known
  late List<GameMessage> messages;

  GameProvider() {
    messages = _buildMessages(playerName);
  }

  List<GameMessage> _buildMessages(String name) => [
    GameMessage(
      sender: "HDFC Bank",
      preview: "₹15,000 credited to your account",
      fullText: "Dear $name, ₹15,000 has been credited to your account ending 4291. This is your internship stipend for the month.",
      icon: "🏦",
      tag: "bank_credit",
    ),
    GameMessage(
      sender: "Landlord Sharma",
      preview: "🏠 Rent due by Day 5 — ₹6,000",
      fullText: "Beta, rent is due by Day 5. Please pay ₹6,000 before 5pm or there will be a ₹500 late fee added daily.",
      icon: "🏠",
      spendAmount: 6000,
      spendCategory: "EMI",
      tag: "rent",
    ),
    GameMessage(
      sender: "Riya 👯",
      preview: "Bro new iPhone just dropped 👀",
      fullText: "BHAI new iPhone just launched!! Let's go halves — ₹7,500 each. It'll be sick, everyone at office will notice 🔥",
      icon: "📱",
      spendAmount: 7500,
      spendCategory: "Fun",
      tag: "iphone",
    ),
    GameMessage(
      sender: "Investment Guru Ji",
      preview: "📈 Invest ₹5,000 → get ₹50,000 GUARANTEED",
      fullText: "Dear Friend! GUARANTEED returns! Invest just ₹5,000 today and receive ₹50,000 within 7 days. Limited seats only. Transfer to: UPI: totallylegit@paytm",
      icon: "📈",
      spendAmount: 5000,
      spendCategory: "Fun",
      isScam: true,
      tag: "scam_invest",
    ),
    GameMessage(
      sender: "Canteen Wala",
      preview: "New ₹250 lunch combo today only!",
      fullText: "Special offer! New premium lunch combo — paneer butter masala + naan + cold drink + dessert for ₹250. Your usual dabba costs ₹60.",
      icon: "🍛",
      spendAmount: 250,
      spendCategory: "Food",
      tag: "lunch",
    ),
    GameMessage(
      sender: "Rapido",
      preview: "Your daily commute: ₹80/day",
      fullText: "Your office is 8km away. Rapido bike taxi: ₹80/day. Monthly pass: ₹1,800. BEST bus: ₹15/day. Walking: 0 but 45 mins each way.",
      icon: "🛵",
      tag: "transport",
    ),
  ];

  // ── Events / daily scenarios ─────────────────────────────────
  // Single source of truth — no duplication in resetGame()
  static List<Map<String, dynamic>> _buildEvents() => [
    {
      "day": 3,
      "title": "The Broken Screen",
      "story": "Your phone screen cracked when you dropped it near the water cooler. You need it for work calls.",
      "icon": "📵",
      "choices": [
        {"label": "Official service center", "cost": 2500, "category": "Emergency", "effect": "safe"},
        {"label": "Friend's repair guy (₹800)", "cost": 800, "category": "Emergency", "effect": "risky_phone"},
        {"label": "Use it cracked (free)", "cost": 0, "category": "Emergency", "effect": "miss_opportunity"},
      ]
    },
    {
      "day": 7,
      "title": "Lucky Draw Call",
      "story": "You get a call: 'Congratulations! You've won ₹10,000 in our SBI lucky draw. Just pay ₹500 processing fee!'",
      "icon": "📞",
      "isScam": true,
      "choices": [
        {"label": "Pay ₹500 fee 🤑", "cost": 500, "category": "Fun", "effect": "scam", "isScam": true},
        {"label": "Hang up immediately", "cost": 0, "category": "", "effect": "safe"},
        {"label": "Ask for company reg number 🕵️", "cost": 0, "category": "", "effect": "detective"},
      ]
    },
    {
      "day": 12,
      "title": "Weekend Hangout",
      "story": "Office gang wants to go to a fancy rooftop bar in Koregaon Park. Cover charge + drinks will be ₹1,500.",
      "icon": "🍻",
      "choices": [
        {"label": "Join them (₹1,500)", "cost": 1500, "category": "Fun", "effect": "social"},
        {"label": "Join but only have water 😅", "cost": 300, "category": "Fun", "effect": "awkward"},
        {"label": "Fake headache, stay home", "cost": 0, "category": "", "effect": "loner"},
      ]
    },
    {
      "day": 17,
      "title": "SIP or Not?",
      "story": "Your HR mentions the company offers ₹500/month SIP investment option. Small but it builds over time.",
      "icon": "📊",
      "choices": [
        {"label": "Start SIP ₹500/month", "cost": 500, "category": "Savings", "effect": "invest_wise"},
        {"label": "Skip for now", "cost": 0, "category": "", "effect": "neutral"},
        {"label": "Ask for FD info first", "cost": 0, "category": "", "effect": "smart"},
      ]
    },
    {
      "day": 22,
      "title": "Emergency: Friend Needs Money",
      "story": "Your college friend Sahil messages: 'Bhai hospital emergency, need ₹3,000 urgently, will return next week.'",
      "icon": "🆘",
      "choices": [
        {"label": "Send ₹3,000 immediately", "cost": 3000, "category": "Emergency", "effect": "generous"},
        {"label": "Send ₹1,000 (what you can afford)", "cost": 1000, "category": "Emergency", "effect": "partial"},
        {"label": "Ask for details first", "cost": 0, "category": "", "effect": "cautious"},
      ]
    },
  ];

  int currentEventIndex = 0;
  List<Map<String, dynamic>> dailyEvents = _buildEvents();

  bool _eventShown = false;
  bool get shouldShowEvent {
    if (_eventShown) return false;
    if (currentEventIndex >= dailyEvents.length) return false;
    return dailyEvents[currentEventIndex]['day'] == day;
  }

  Map<String, dynamic>? get currentEvent =>
      currentEventIndex < dailyEvents.length ? dailyEvents[currentEventIndex] : null;

  // ── Stats ─────────────────────────────────────────────────────
  int get totalSpent => expenses.fold(0, (sum, e) => sum + e.amount);
  Map<String, int> get spendingByCategory {
    final map = <String, int>{};
    for (final e in expenses) {
      map[e.category] = (map[e.category] ?? 0) + e.amount;
    }
    return map;
  }

  // ── Actions ───────────────────────────────────────────────────
  Future<void> login(
      String name,
      String avatar, {
        String authType = 'guest',
      }) async {
    playerName = name;
    playerAvatar = avatar;
    isLoggedIn = true;

    // Rebuild messages so the bank SMS says the real player name, not "Player"
    messages = _buildMessages(name);

    await _firestore.saveUserProfile(
      name: name,
      avatar: avatar,
      authType: authType,
    );

    notifyListeners();
  }

  void spend(int amount, String category, String description) {
    balance -= amount;
    expenses.add(Expense(
      category: category,
      amount: amount,
      day: day,
      description: description,
    ));
    if (balance <= 0) gameOver = true;
    notifyListeners();
    saveGame();
  }

  void earn(int amount) {
    balance += amount;
    notifyListeners();
    saveGame();
  }

  void markMessageRead(int index) {
    messages[index] = messages[index].copyWith(isRead: true);
    notifyListeners();
  }

  void resolveMessage(int index, bool accepted) {
    final msg = messages[index];
    messages[index] = messages[index].copyWith(isRead: true);

    if (accepted && msg.spendAmount != null) {
      if (msg.isScam) scamsFallenFor++;
      spend(msg.spendAmount!, msg.spendCategory ?? "Fun", msg.preview);
    } else {
      notifyListeners();
    }
  }

  void resolveEvent(int choiceIndex) {
    _eventShown = true;
    final event = currentEvent;
    if (event == null) return;
    final choice = event['choices'][choiceIndex];
    final cost = choice['cost'] as int;
    final effect = choice['effect'] as String;
    final category = choice['category'] as String;

    if (cost > 0) {
      spend(cost, category.isEmpty ? "Other" : category, event['title']);
    }

    if (effect == 'scam' || choice['isScam'] == true) {
      scamsFallenFor++;
    }
    if (effect == 'risky_phone') _phoneHealth = 20;

    currentEventIndex++;
    notifyListeners();
    saveGame();
  }

  void nextDay() {
    if (day >= 30) {
      gameOver = true;
      notifyListeners();
      return;
    }

    day++;
    _eventShown = false;

    // Always deduct daily basics when advancing (day is already incremented)
    final dailyBasic = Random().nextInt(100) + 60;
    spend(dailyBasic, "Food", "Daily basics"); // calls notifyListeners + saveGame

    // Check game over after spending (spend() sets gameOver if balance <= 0)
    if (gameOver) notifyListeners();
  }

  Future<void> resetGame() async {
    balance = 15000;
    day = 1;
    scamsFallenFor = 0;
    gameOver = false;
    _phoneHealth = 100;
    _eventShown = false;
    currentEventIndex = 0;
    selectedCategory = "Food";
    expenses = [];
    messages = _buildMessages(playerName); // uses current name, no duplication
    dailyEvents = _buildEvents();          // single source of truth

    notifyListeners();
    await saveGame();
  }

  Future<void> saveGame() async {
    await _firestore.saveGameState(
      balance: balance,
      day: day,
      scams: scamsFallenFor,
    );
  }

  Future<void> loadGame() async {
    final data = await _firestore.loadGameState();
    if (data != null) {
      balance = data['balance'] ?? 15000;
      day = data['day'] ?? 1;
      scamsFallenFor = data['scams'] ?? 0;
      notifyListeners();
    }
  }

  void setCategory(String val) {
    selectedCategory = val;
    notifyListeners();
  }

  void logExpense(int amount) {
    spend(amount, selectedCategory, "Manual: $selectedCategory");
  }

  GameEnding getEnding() {
    if (scamsFallenFor >= 2) return GameEnding.scammersFav;
    if (balance < 0) return GameEnding.calledMom;
    if (balance >= 5000 && scamsFallenFor == 0) return GameEnding.wolfOfPune;
    if (balance >= 2000) return GameEnding.barelysurvived;
    return GameEnding.ramenMonth;
  }

  int get unreadCount => messages.where((m) => !m.isRead).length;
}