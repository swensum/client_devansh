import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String id;
  final String name;
  final String role;
  final String message;
  final int rating;
  final String? photoUrl;
  final DateTime? createdAt;
  final bool approved;

  const Review({
    required this.id,
    required this.name,
    required this.role,
    required this.message,
    required this.rating,
    this.photoUrl,
    this.createdAt,
    this.approved = false,
  });

  factory Review.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return Review(
      id: doc.id,
      name: (data['name'] as String?) ?? 'Anonymous',
      role: (data['role'] as String?) ?? '',
      message: (data['message'] as String?) ?? '',
      rating: (data['rating'] as num?)?.toInt() ?? 5,
      photoUrl: data['photoUrl'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      approved: (data['approved'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'role': role,
    'message': message,
    'rating': rating,
    'photoUrl': photoUrl,
    'createdAt': FieldValue.serverTimestamp(),
    'approved': false, // always resets to unapproved on submit/edit
  };
}
