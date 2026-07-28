import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:devansh/models/blogmodel.dart';



class BlogService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<BlogPost>> watchAllPosts() {
    return _db
        .collection('blogs')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => BlogPost.fromMap(d.id, d.data()))
              .toList(),
        );
  }

  Stream<List<BlogPost>> watchPublishedPosts() {
    return watchAllPosts().map(
      (posts) => posts.where((p) => p.isPublished).toList(),
    );
  }

  /// One-time fetch of a single post by its Firestore document id.
  Future<BlogPost?> getPost(String id) async {
    final doc = await _db.collection('blogs').doc(id).get();
    if (!doc.exists) return null;
    return BlogPost.fromMap(doc.id, doc.data()!);
  }

  /// One-time fetch of a single post by its slug (for the blog detail page,
  /// e.g. route `/blog/:slug`).
  Future<BlogPost?> getPostBySlug(String slug) async {
    final query = await _db
        .collection('blogs')
        .where('slug', isEqualTo: slug)
        .limit(1)
        .get();
    if (query.docs.isEmpty) return null;
    final doc = query.docs.first;
    return BlogPost.fromMap(doc.id, doc.data());
  }
}