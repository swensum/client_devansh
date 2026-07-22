import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:devansh/models/reviewmodel.dart';

class ReviewService {
  final _col = FirebaseFirestore.instance.collection('reviews');

  /// Live stream of approved reviews, newest first.
  Stream<List<Review>> watchReviews({int limit = 20}) {
    return _col
        .where('approved', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs.map(Review.fromFirestore).toList());
  }

  Future<void> submitReview(Review review) => _col.add(review.toMap());
}