import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:devansh/models/reviewmodel.dart';

class ReviewService {
  final _col = FirebaseFirestore.instance.collection('reviews');

  Stream<List<Review>> watchReviews({int limit = 20}) {
    return _col
        .where('approved', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .handleError((error, stack) {})
        .map((snap) {
          final reviews = <Review>[];
          for (final doc in snap.docs) {
            try {
              reviews.add(Review.fromFirestore(doc));
            } catch (e) {
              debugPrint('⚠️ Failed to parse review ${doc.id}: $e');
            }
          }
          return reviews;
        });
  }

  /// Returns the current user's own review, if they've submitted one.
  Future<Review?> getUserReview(String uid) async {
    final doc = await _col.doc(uid).get();
    if (!doc.exists) return null;
    return Review.fromFirestore(doc);
  }

  Future<void> submitReview(Review review, String uid) =>
      _col.doc(uid).set(review.toMap());
}
