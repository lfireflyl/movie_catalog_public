import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class FavoriteService {
  static Future<int?> getUserID() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userID');
  }

  static Future<List<Map<String, String>>> getSavedMovies(int userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String key = 'user_$userId';
    String? savedMoviesJson = prefs.getString(key);
    if (savedMoviesJson == null) {
      return [];
    }

    return (json.decode(savedMoviesJson) as List<dynamic>)
        .map((movie) => (movie as Map<String, dynamic>)
            .map((key, value) => MapEntry(key.toString(), value.toString())))
        .toList();
  }

  static Future<void> toggleFavorite(int userId, int movieId, String title, String posterPath) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String key = 'user_$userId';
    String? savedMoviesJson = prefs.getString(key);

    List<Map<String, String>> savedMovies = savedMoviesJson != null
        ? (json.decode(savedMoviesJson) as List<dynamic>)
            .map((movie) => (movie as Map<String, dynamic>)
                .map((key, value) => MapEntry(key.toString(), value.toString())))
            .toList()
        : [];

    Map<String, String>? existingMovie = savedMovies.firstWhere(
      (movie) => movie['id'] == movieId.toString(),
      orElse: () => {},
    );

    if (existingMovie.isEmpty) {
      savedMovies.add({
        'id': movieId.toString(),
        'title': title,
        'posterPath': posterPath,
      });
    } else {
      savedMovies.remove(existingMovie);
    }

    await prefs.setString(key, json.encode(savedMovies));
  }
}
