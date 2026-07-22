import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String id;
  final String name;
  final String role;
  final String message;
  final int rating;
  final DateTime? createdAt;

  const Review({
    required this.id,
    required this.name,
    required this.role,
    required this.message,
    required this.rating,
    this.createdAt,
  });

  factory Review.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return Review(
      id: doc.id,
      name: (data['name'] as String?) ?? 'Anonymous',
      role: (data['role'] as String?) ?? '',
      message: (data['message'] as String?) ?? '',
      rating: (data['rating'] as num?)?.toInt() ?? 5,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'role': role,
    'message': message,
    'rating': rating,
    'createdAt': FieldValue.serverTimestamp(),
    'approved': false, // see note on moderation below
  };
}