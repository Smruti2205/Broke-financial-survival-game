import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../theme/game_theme.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameTheme.navy,

      appBar: AppBar(
        backgroundColor: GameTheme.navyCard,
        elevation: 0,
        title: const Text(
          'GLOBAL LEADERBOARD',
          style: TextStyle(
            color: GameTheme.cyan,
            letterSpacing: 2,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('leaderboard')
            .orderBy('balance', descending: true)
            .limit(20)
            .snapshots(),

        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData ||
              snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No players yet',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,

            itemBuilder: (context, index) {
              final data =
              docs[index].data() as Map<String, dynamic>;

              final isTopPlayer = index == 0;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),

                decoration: GameTheme.cardDecoration(
                  glowColor: isTopPlayer
                      ? GameTheme.gold
                      : GameTheme.cyan,
                ),

                child: Row(
                  children: [
                    // Rank
                    Text(
                      '#${index + 1}',
                      style: TextStyle(
                        color: isTopPlayer
                            ? GameTheme.gold
                            : Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Avatar
                    Text(
                      data['avatar'] ?? '👤',
                      style: const TextStyle(fontSize: 30),
                    ),

                    const SizedBox(width: 16),

                    // Player Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(
                            data['name'] ?? 'Player',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            data['ending'] ?? '',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Stats
                    Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.end,
                      children: [
                        Text(
                          '₹${data['balance'] ?? 0}',
                          style: const TextStyle(
                            color: GameTheme.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          'Scams: ${data['scams'] ?? 0}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}