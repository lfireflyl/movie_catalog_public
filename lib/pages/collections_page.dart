import 'package:flutter/material.dart';
import 'package:movie_catalog/models/movies.dart';
import 'package:movie_catalog/services/api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/movie_collection.dart';
import '../services/admin_service.dart';
import '../services/favorite_service.dart';
import '../style/movies_list_style.dart';
import 'account_page.dart';
import 'film_card.dart';

class CollectionsPage extends StatefulWidget {
  const CollectionsPage({super.key});

  @override
  CollectionsPageState createState() => CollectionsPageState();
}

class CollectionsPageState extends State<CollectionsPage> {
  late Future<List<MovieCollection>> _collectionsFuture;

  @override
  void initState() {
    super.initState();
    _collectionsFuture = AdminService.getCollections();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Подборки'),
      ),
      body: FutureBuilder<List<MovieCollection>>(
        future: _collectionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppStyles.primaryColor),
            ));
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Ошибка загрузки подборок'));
          }

          List<MovieCollection>? collections = snapshot.data;
          if (collections == null || collections.isEmpty) {
            return const Center(child: Text('Подборок пока нет.'));
          }

          return ListView.builder(
            itemCount: collections.length,
            itemBuilder: (context, index) {
              final collection = collections[index];
              return ListTile(
                title: Text(collection.name),
                trailing: const Icon(Icons.arrow_forward),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          CollectionDetailsPage(collection: collection),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class CollectionDetailsPage extends StatefulWidget {
  final MovieCollection collection;

  const CollectionDetailsPage({super.key, required this.collection});

  @override
  CollectionDetailsPageState createState() => CollectionDetailsPageState();
}

class CollectionDetailsPageState extends State<CollectionDetailsPage> {
  late Future<List<Map<String, String>>> _savedMovies;

  @override
  void initState() {
    super.initState();
    _savedMovies = _getSavedMovies();
  }

  Future<List<Map<String, String>>> _getSavedMovies() async {
    final userId = await _getUserID();
    if (userId != null) {
      return await FavoriteService.getSavedMovies(userId);
    }
    return [];
  }

  Future<int?> _getUserID() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userID');
  }

  Future<void> _toggleFavorite(int userId, int movieId, String movieTitle,
      String posterPath) async {
    try {
      await FavoriteService.toggleFavorite(
        userId,
        movieId,
        movieTitle,
        posterPath,
      );

      setState(() {
        _savedMovies = _getSavedMovies();
      });
    } catch (e) {
      debugPrint('Ошибка при добавлении в избранное: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.collection.name),
      ),
      body: widget.collection.movieIds.isEmpty
          ? const Center(child: Text('Фильмы в подборке отсутствуют.'))
          : ListView.builder(
              itemCount: widget.collection.movieIds.length,
              itemBuilder: (context, index) {
                final movieId = widget.collection.movieIds[index];
                return FutureBuilder(
                  future: ApiService().fetchMovieDetails(movieId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppStyles.primaryColor),
                      ));
                    }

                    if (snapshot.hasError || snapshot.data == null) {
                      return const ListTile(title: Text('Ошибка загрузки фильма.'));
                    }

                    final movie = snapshot.data as Movie;
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FilmCard(
                              movieId: movie.id,
                              isFavorite: false, 
                              onFavoriteChanged: (isFavorite, id) {},
                            ),
                          ),
                        );
                      },
                      child: Card(
                        margin: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16.0),
                            color: Color.fromARGB(227, 242, 253, 255),
                        child: Row(
                          children: [
                            movie.posterPath.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      'https://image.tmdb.org/t/p/w200${movie.posterPath}',
                                      width: 130,
                                      height: 195,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : const SizedBox(width: 92, height: 138),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(movie.title),
                                  const SizedBox(height: 4),
                                  Text('Дата выхода: ${movie.releaseDate}'),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: FutureBuilder<List<Map<String, String>>>(
                                future: _savedMovies,
                                builder: (context, savedSnapshot) {
                                  if (savedSnapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Icon(Icons.favorite_border);
                                  }

                                  bool isFavorite = savedSnapshot.hasData &&
                                      savedSnapshot.data!.any((savedMovie) =>
                                          savedMovie['id'] ==
                                          movie.id.toString());
                                  return Icon(
                                    isFavorite
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: isFavorite
                                        ? Colors.red
                                        : Colors.grey,
                                  );
                                },
                              ),
                              onPressed: () async {
                                final userId = await _getUserID();
                                if (userId != null) {
                                  _toggleFavorite(
                                      userId,
                                      movie.id,
                                      movie.title,
                                      movie.posterPath);
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const AccountPage()),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
