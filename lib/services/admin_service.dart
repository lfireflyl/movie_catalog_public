import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/movie_collection.dart';

class AdminService {
  static const String _collectionsKey = 'collections';

  static Future<List<MovieCollection>> getCollections() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? collectionsJson = prefs.getString(_collectionsKey);
    if (collectionsJson == null) return [];
    List<dynamic> collectionsList = json.decode(collectionsJson);
    return collectionsList.map((col) => MovieCollection.fromJson(col)).toList();
  }

  static Future<void> saveCollections(List<MovieCollection> collections) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(
        _collectionsKey, json.encode(collections.map((c) => c.toJson()).toList()));
  }

  static Future<void> addCollection(MovieCollection collection) async {
    List<MovieCollection> collections = await getCollections();
    collections.add(collection);
    await saveCollections(collections);
  }

  static Future<void> deleteCollection(String name) async {
    List<MovieCollection> collections = await getCollections();
    collections.removeWhere((col) => col.name == name);
    await saveCollections(collections);
  }
}
