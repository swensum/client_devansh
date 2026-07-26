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
        .handleError((error, stack) {
          // This is almost certainly where your issue shows up.
          debugPrint('🔥 ReviewService stream error: $error');
        })
        .map((snap) {
          debugPrint('📦 Got ${snap.docs.length} review doc(s) from Firestore');
          final reviews = <Review>[];
          for (final doc in snap.docs) {
            try {
              reviews.add(Review.fromFirestore(doc));
            } catch (e) {
              // If one doc fails to parse, don't kill the whole stream/list.
              debugPrint('⚠️ Failed to parse review ${doc.id}: $e');
            }
          }
          return reviews;
        });
  }

  Future<void> submitReview(Review review, String uid) => _col.doc(uid).set(review.toMap());
}