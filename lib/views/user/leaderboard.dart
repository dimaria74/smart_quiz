import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LeaderboardView extends StatelessWidget {
  const LeaderboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text('Leaderboard'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('leaderboard')
            .orderBy('score', descending: true)
            .limit(50)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final isCurrentUser = docs[index].id == currentUserId;

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  height: 85,
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(
                        '#${index + 1}',
                        style: TextStyle(
                          fontSize: 24,
                        ),
                      ),
                    ),
                    title: Text(
                      data['username'] ?? 'Anonymous',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Text(
                      'Score: ${data['score']}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    tileColor: isCurrentUser ? Colors.lightBlue.shade200 : null,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
