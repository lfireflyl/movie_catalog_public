import 'package:flutter/material.dart';
import 'package:movie_catalog/services/api.dart';
import '../models/movie_collection.dart';
import '../models/movies.dart';
import '../services/admin_service.dart';
import '../style/movies_list_style.dart';

class EditCollectionScreen extends StatefulWidget {
  final MovieCollection collection;
  final VoidCallback onCollectionUpdated;

  const EditCollectionScreen({
    super.key,
    required this.collection,
    required this.onCollectionUpdated,
  });

  @override
  EditCollectionScreenState createState() => EditCollectionScreenState();
}

class EditCollectionScreenState extends State<EditCollectionScreen> {
  late TextEditingController _searchController;
  late List<Movie> _searchResults;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchResults = [];
  }

  Future<void> _searchMovies() async {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      try {
        final results = await ApiService().searchMovies(query);
        setState(() {
          _searchResults = results;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ошибка поиска фильмов')),
        );
      }
    }
  }

  void _addMovieToCollection(int movieId) {
    if (!widget.collection.movieIds.contains(movieId)) {
      setState(() {
        widget.collection.movieIds.add(movieId);
      });
    }
  }

  void _removeMovieFromCollection(int movieId) {
    setState(() {
      widget.collection.movieIds.remove(movieId);
    });
  }

  Future<void> _saveCollection() async {
    final collections = await AdminService.getCollections();
    collections.removeWhere((col) => col.name == widget.collection.name);
    collections.add(widget.collection);
    await AdminService.saveCollections(collections);
    widget.onCollectionUpdated();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Редактировать подборку')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Поиск фильмов',
                labelStyle: const TextStyle(color: Colors.grey),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search, color: AppStyles.primaryColor),
                  onPressed: _searchMovies,
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: AppStyles.primaryColor, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.grey, width: 1),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              cursorColor: AppStyles.primaryColor,
              onSubmitted: (value) {
                _searchMovies();
              },
            )

          ),
          Expanded(
            child: ListView.builder(
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final movie = _searchResults[index];
                return ListTile(
                  leading: movie.posterPath.isNotEmpty
                      ? Image.network(
                          'https://image.tmdb.org/t/p/w92${movie.posterPath}',
                          fit: BoxFit.cover,
                        )
                      : null,
                  title: Text(movie.title),
                  subtitle: Text(movie.releaseDate),
                  trailing: IconButton(
                    icon: const Icon(Icons.add,
                        color: AppStyles.primaryColor),
                    onPressed: () => _addMovieToCollection(movie.id),
                  ),
                );
              },
            ),
          ),
          const Divider(),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Добавленные фильмы',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: widget.collection.movieIds.length,
                    itemBuilder: (context, index) {
                      final movieId = widget.collection.movieIds[index];
                      return FutureBuilder(
                        future: ApiService().fetchMovieDetails(movieId),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(AppStyles.primaryColor),
                                ));
                          }

                          if (snapshot.hasError || snapshot.data == null) {
                            return const ListTile(
                              title: Text('Ошибка загрузки данных фильма'),
                            );
                          }

                          final movie = snapshot.data as Movie;
                          return ListTile(
                            leading: movie.posterPath.isNotEmpty
                                ? Image.network(
                                    'https://image.tmdb.org/t/p/w92${movie.posterPath}',
                                    fit: BoxFit.cover,
                                  )
                                : null,
                            title: Text(movie.title),
                            subtitle: Text(movie.releaseDate),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete,
                                  color: Colors.red),
                              onPressed: () =>
                                  _removeMovieFromCollection(movieId),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0, top: 8.0),
            child: ElevatedButton(
              onPressed: _saveCollection,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: AppStyles.primaryColor,
              ),
              child: const Text('Сохранить подборку'),
            ),
          ),
        ],
      ),
    );
  }
}
