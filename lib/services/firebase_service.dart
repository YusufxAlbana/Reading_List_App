import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/reading_item.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionPath = 'books';
  final String tagsCollectionPath = 'tags';

  // Stream untuk real-time sync books
  Stream<List<ReadingItem>> getBooksStream() {
    return _firestore
        .collection(collectionPath)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return ReadingItem.fromJson(data);
      }).toList();
    });
  }

  // Stream untuk real-time sync tags
  Stream<List<String>> getTagsStream() {
    return _firestore
        .collection(tagsCollectionPath)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => doc.id).toList();
    });
  }

  // Add book
  Future<void> addBook(ReadingItem item) async {
    await _firestore.collection(collectionPath).doc(item.id).set(item.toJson());
  }

  // Update book
  Future<void> updateBook(ReadingItem item) async {
    await _firestore.collection(collectionPath).doc(item.id).update(item.toJson());
  }

  // Delete book
  Future<void> deleteBook(String id) async {
    await _firestore.collection(collectionPath).doc(id).delete();
  }

  // Add tag
  Future<void> addTag(String tag) async {
    await _firestore.collection(tagsCollectionPath).doc(tag).set({
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Delete tag
  Future<void> deleteTag(String tag) async {
    await _firestore.collection(tagsCollectionPath).doc(tag).delete();
  }

  // Delete multiple tags
  Future<void> deleteTags(List<String> tags) async {
    final batch = _firestore.batch();
    for (var tag in tags) {
      batch.delete(_firestore.collection(tagsCollectionPath).doc(tag));
    }
    await batch.commit();
  }

  // Get all books (one-time)
  Future<List<ReadingItem>> getBooks() async {
    final snapshot = await _firestore
        .collection(collectionPath)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return ReadingItem.fromJson(data);
    }).toList();
  }

  // Get all tags (one-time)
  Future<List<String>> getTags() async {
    final snapshot = await _firestore.collection(tagsCollectionPath).get();
    return snapshot.docs.map((doc) => doc.id).toList();
  }
}
