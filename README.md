# BROKE — Financial Survival Game

**BROKE** is a Flutter-based mobile game that simulates real-life financial decisions for young professionals. Players manage a monthly budget, respond to messages from landlords and scammers, navigate daily events, and try to reach the end of the month without going broke.

---

## Gameplay Overview

* You start with **₹15,000** — your monthly internship stipend.
* The game runs for **30 in-game days**.
* Every day, money is deducted for basic survival needs (food, transport, etc.).
* You receive messages from people like your landlord, friends, and scammers — and must decide how to respond.
* Random events trigger on specific days, forcing tough financial choices.
* Your ending depends on how much you save and whether you fell for scams.

### Game Endings

| Ending | Condition |
|---|---|
| 🐺 Wolf of Pune | Balance ≥ ₹5,000 & zero scams — you crushed it |
| 😅 Barely Survived | Balance ≥ ₹2,000 — tight but made it |
| 🍜 Ramen Month | Balance > ₹0 — lived on bare minimum |
| 📞 Called Mom | Balance went negative — needed rescue |
| 🎣 Scammer's Favourite | Fell for 2+ scams — lesson learned the hard way |
---

## Features

* Message Inbox — Chat-style messages from characters like landlords, friends, banks, and scammers
* Scam Detection — Fake investment offers and suspicious calls test financial awareness
* Daily Events — Story-driven scenarios with multiple choices
* Expense Tracker — Manual expense logging with categories
* Spending Stats — Spending breakdown visualization
* Leaderboard — Compare scores with other players
* Multiple Endings — Different outcomes based on player decisions
* Firebase Auth — Google Sign-In and guest login
* Cloud Save — Game progress stored using Firestore
* Dark Cyberpunk Theme — Neon-inspired UI with monospace fonts

---

## Tech Stack

| Layer            | Technology                      |
| ---------------- | ------------------------------- |
| Framework        | Flutter (Dart)                  |
| State Management | Provider                        |
| Backend / Auth   | Firebase Auth + Cloud Firestore |
| Google Sign-In   | `google_sign_in`                |
| Navigation       | Flutter Navigator               |
| URL Handling     | `url_launcher`                  |

---

## Project Structure

```text
lib/
├── main.dart
├── firebase_options.dart
│
├── providers/
│   └── game_provider.dart
│
├── screens/
│   ├── splash_screen.dart
│   ├── dashboard_screen.dart
│   ├── chat_screen.dart
│   ├── event_screen.dart
│   ├── expense_screen.dart
│   ├── stats_screen.dart
│   ├── leaderboard_screen.dart
│   ├── profile_screen.dart
│   └── ending_screen.dart
│
├── services/
│   ├── auth_service.dart
│   └── firestore_service.dart
│
└── theme/
    └── game_theme.dart
```

---

## Getting Started

### Prerequisites

* Flutter SDK `>=3.0.0`
* Dart SDK `>=3.0.0 <4.0.0`
* Firebase project with Authentication and Firestore enabled

# Installation

## 1. Clone Repository

```bash
git clone https://github.com/Smruti2205/Broke-financial-survival-game.git
```

## 2. Open Project

```bash
cd Broke-financial-survival-game
```

## 3. Install Dependencies

```bash
flutter pub get
```

## 4. Run Project

```bash
flutter run
```

Currently supported on Android.

---

### Firebase Setup

1. Create a Firebase project
2. Enable Google Sign-In under Authentication
3. Enable Cloud Firestore
4. Add `google-services.json` for Android
5. Replace `firebase_options.dart` using `flutterfire configure`

---

## Dependencies

```yaml
firebase_core: ^3.15.2
firebase_auth: ^5.7.0
cloud_firestore: ^5.5.0
google_sign_in: ^6.2.1
provider: ^6.1.0
url_launcher: ^6.2.0
```

---

## Platform Support

| Platform | Status    |
| -------- | --------- |
| Android  | Supported |

---

## Learning Goals

This project helps users learn about:

* Budgeting on limited income
* Identifying common financial scams
* Managing needs vs. wants
* Saving habits
* Consequences of impulsive spending

---

## Contributing

Pull requests are welcome. Open an issue before making major changes.

---

## License

This project is not published to pub.dev (`publish_to: none`). All rights reserved.
