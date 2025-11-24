import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_notes/crud_service.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final CrudService service = CrudService();
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController qtyCtrl = TextEditingController();

  bool showFavorites = false; // Filter toggle

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text("Firebase Quimbo"),
        centerTitle: true,
        backgroundColor: Colors.teal,

        // ⭐ Favorites filter switch button
        actions: [
          IconButton(
            icon: Icon(
              showFavorites ? Icons.star : Icons.star_border,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                showFavorites = !showFavorites;
              });
            },
          ),
        ],
      ),

      // 🔥 Updated real-time stream using safe CrudService
      body: StreamBuilder<QuerySnapshot>(
        stream: service.getItemsFiltered(showFavorites),
        builder: (context, snapshot) {
          // Still loading?
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Error handling (ex: missing index)
          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error loading items.\n${snapshot.error}",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return Center(
              child: Text(
                showFavorites
                    ? "No favorite items found"
                    : "No items found",
                style: const TextStyle(fontSize: 18),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final item = docs[index];
              final data = item.data() as Map<String, dynamic>;

              final bool isFavorite = data['favorite'] ?? false;

              return Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  title: Text(
                    data['name'],
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text("Quantity: ${data['quantity']}"),

                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ❤️ Toggle favorite
                      IconButton(
                        icon: Icon(
                          isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: isFavorite ? Colors.red : Colors.grey,
                        ),
                        onPressed: () {
                          service.toggleFavorite(item.id, isFavorite);
                        },
                      ),

                      // ✏ Edit
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.orange),
                        onPressed: () => openEditDialog(context, item),
                      ),

                      // 🗑 Delete
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => confirmDelete(context, item.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => openAddDialog(context),
      ),
    );
  }

  // DELETE CONFIRMATION
  void confirmDelete(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Item"),
        content: const Text("Are you sure you want to delete this item?"),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child:
                const Text("Delete", style: TextStyle(color: Colors.red)),
            onPressed: () {
              service.deleteItem(id);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  // ADD ITEM DIALOG
  void openAddDialog(BuildContext context) {
    nameCtrl.clear();
    qtyCtrl.clear();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Item"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(
                labelText: "Name",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: qtyCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Quantity",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            child: const Text("Save"),
            onPressed: () {
              if (nameCtrl.text.isNotEmpty &&
                  qtyCtrl.text.isNotEmpty) {
                service.addItem(
                    nameCtrl.text, int.parse(qtyCtrl.text));
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }

  // EDIT DIALOG
  void openEditDialog(BuildContext context, DocumentSnapshot item) {
    final data = item.data() as Map<String, dynamic>;

    nameCtrl.text = data['name'];
    qtyCtrl.text = data['quantity'].toString();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Item"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(
                labelText: "Name",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: qtyCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Quantity",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text("Update"),
            onPressed: () {
              if (nameCtrl.text.isNotEmpty &&
                  qtyCtrl.text.isNotEmpty) {
                service.updateItem(
                    item.id, nameCtrl.text, int.parse(qtyCtrl.text));
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }
}
