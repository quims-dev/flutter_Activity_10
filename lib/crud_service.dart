import 'package:cloud_firestore/cloud_firestore.dart';

class CrudService {
  final CollectionReference items =
      FirebaseFirestore.instance.collection('items');

  Future<void> addItem(String name, int quantity) {
    return items.add({
      'name': name,
      'quantity': quantity,
      'favorite': false,
      'createdAt': Timestamp.now(),
    });
  }

  Stream<QuerySnapshot> getItems() {
    return items.orderBy('createdAt', descending: true).snapshots();
  }

  Stream<QuerySnapshot> getItemsFiltered(bool favoritesOnly) {
    if (!favoritesOnly) {
      return getItems();
    }

    try {
      return items
          .where('favorite', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .snapshots();
    } catch (e) {
      print("🔥 Firestore index missing, falling back to all items: $e");
      return getItems();
    }
  }

  Future<void> updateItem(String id, String name, int quantity) {
    return items.doc(id).update({
      'name': name,
      'quantity': quantity,
    });
  }

  Future<void> toggleFavorite(String id, bool currentValue) {
    return items.doc(id).update({
      'favorite': !currentValue,
    });
  }

  Future<void> deleteItem(String id) {
    return items.doc(id).delete();
  }
}

