import 'package:flutter/material.dart';
import '../services/admin_service.dart';
import '../models/movie_collection.dart';
import '../style/movies_list_style.dart';
import 'edit_collection_screen.dart';

class AdminPanel extends StatefulWidget {
  const AdminPanel({super.key});

  @override
  AdminPanelState createState() => AdminPanelState();
}

class AdminPanelState extends State<AdminPanel> {
  late Future<List<MovieCollection>> _collectionsFuture;

  @override
  void initState() {
    super.initState();
    _loadCollections();
  }

  void _loadCollections() {
    setState(() {
      _collectionsFuture = AdminService.getCollections();
    });
  }

  void _createCollection() async {
    TextEditingController nameController = TextEditingController();
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Создать подборку'),
          content: TextField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: 'Название подборки',
              labelStyle: TextStyle(color: Colors.grey), 
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppStyles.primaryColor), 
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppStyles.primaryColor), 
              ),
            ),
            cursorColor: AppStyles.primaryColor,
          ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: AppStyles.primaryColor,
            ),
            child: Text('Отмена'),
          ),
          TextButton(
            onPressed: () async {
              String name = nameController.text.trim();
              if (name.isNotEmpty) {
                await AdminService.addCollection(
                    MovieCollection(name: name, movieIds: []));
                _loadCollections();
              }
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: AppStyles.primaryColor,
            ),
            child: Text('Создать'),
          ),
        ],
      ),
    );
  }

  void _deleteCollection(String name) async {
    await AdminService.deleteCollection(name);
    _loadCollections();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Управление подборками')),
      body: FutureBuilder<List<MovieCollection>>(
        future: _collectionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppStyles.primaryColor),
            ));
          }

          if (snapshot.hasError) {
            return Center(child: Text('Ошибка загрузки подборок'));
          }

          List<MovieCollection>? collections = snapshot.data;
          if (collections == null || collections.isEmpty) {
            return Center(child: Text('Подборок пока нет.'));
          }

          return ListView.builder(
            itemCount: collections.length,
            itemBuilder: (context, index) {
              final collection = collections[index];
              return ListTile(
                title: Text(collection.name),
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteCollection(collection.name),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditCollectionScreen(
                        collection: collection,
                        onCollectionUpdated: _loadCollections,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createCollection,
        foregroundColor: Colors.white,
        backgroundColor: AppStyles.primaryColor,
        child: Icon(Icons.add),
      ),
    );
  }
}
