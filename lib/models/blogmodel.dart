import 'package:cloud_firestore/cloud_firestore.dart';

/// A single FAQ entry attached to a blog post.
class BlogFaq {
  final String question;
  final String answer;

  const BlogFaq({required this.question, required this.answer});

  factory BlogFaq.fromMap(Map<String, dynamic> map) {
    return BlogFaq(
      question: map['question'] ?? '',
      answer: map['answer'] ?? '',
    );
  }
}

/// A single blog post, written from the admin panel and read by the
/// storefront's Blog section / blog detail page.
class BlogPost {
  final String id;
  final String title;
  final String slug;
  final String category;
  final String? excerpt;
  final String? content;
  final String status; // 'draft' | 'published'
  final String? coverImage;
  final DateTime? createdAt;
  final List<BlogFaq> faqs;

  const BlogPost({
    required this.id,
    required this.title,
    required this.slug,
    required this.category,
    this.excerpt,
    this.content,
    required this.status,
    this.coverImage,
    this.createdAt,
    this.faqs = const [],
  });

  bool get isPublished => status == 'published';

  factory BlogPost.fromMap(String id, Map<String, dynamic> map) {
    final createdAtRaw = map['createdAt'];
    final faqsRaw = map['faqs'];

    return BlogPost(
      id: id,
      title: map['title'] ?? '',
      slug: map['slug'] ?? '',
      category: map['category'] ?? '',
      excerpt: map['excerpt'],
      content: map['content'],
      status: map['status'] ?? 'draft',
      coverImage: map['coverImage'],
      createdAt: createdAtRaw is Timestamp ? createdAtRaw.toDate() : null,
      faqs: faqsRaw is List
          ? faqsRaw
                .whereType<Map>()
                .map((f) => BlogFaq.fromMap(Map<String, dynamic>.from(f)))
                .toList()
          : const [],
    );
  }
}
