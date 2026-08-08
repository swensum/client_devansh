import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:devansh/models/ordermodel.dart';

class OrderRecordService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Saves a new order and returns its generated Firestore document id.
  Future<String> submitOrder(OrderRecord order) async {
    final docRef = await _db.collection('orders').add(order.toMap());
    return docRef.id;
  }

  /// All orders, newest first — the main feed for an admin "Orders" page.
  Stream<List<OrderRecord>> watchOrders() {
    return _db
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => OrderRecord.fromMap(d.id, d.data()))
              .toList(),
        );
  }

  /// Orders filtered by status (e.g. 'pending'), newest first — handy for
  /// an admin panel's "needs attention" view.
  Stream<List<OrderRecord>> watchOrdersByStatus(String status) {
    return _db
        .collection('orders')
        .where('status', isEqualTo: status)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => OrderRecord.fromMap(d.id, d.data()))
              .toList(),
        );
  }

  /// A single shop's order history — e.g. for a "My Orders" screen.
  Stream<List<OrderRecord>> watchOrdersForUser(String userId) {
    return _db
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => OrderRecord.fromMap(d.id, d.data()))
              .toList(),
        );
  }

  Future<OrderRecord?> getOrder(String id) async {
    final doc = await _db.collection('orders').doc(id).get();
    if (!doc.exists) return null;
    return OrderRecord.fromMap(doc.id, doc.data()!);
  }

  /// Lets an admin panel mark an order confirmed/cancelled/etc.
  Future<void> updateStatus(String orderId, String status) {
    return _db.collection('orders').doc(orderId).update({'status': status});
  }
}
