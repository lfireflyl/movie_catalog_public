import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api.dart';
import '../models/movies.dart';
import '../services/favorite_service.dart';
import '../style/film_card_style.dart';
import '../style/movies_list_style.dart';

class FilmCard extends StatefulWidget {
  final int movieId;
  final bool isFavorite;
  final void Function(bool isFavorite, int movieId) onFavoriteChanged; 

  const FilmCard({
    super.key,
    required this.movieId,
    required this.isFavorite,
    required this.onFavoriteChanged,
  });

  @override
  FilmCardState createState() => FilmCardState();
}

class FilmCardState extends State<FilmCard> {
  Future<int?> getUserID() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userID');
  }

  Future<List<Map<String, String>>> _getSavedMovies() async {
    int? userId = await getUserID();
    if (userId != null) {
      return await FavoriteService.getSavedMovies(userId);
    }
    return [];
  }

  Future<void> _toggleFavorite(Movie movie) async {
    int? userID = await getUserID();
    if (userID != null) {
      await FavoriteService.toggleFavorite(
        userID,
        movie.id,
        movie.title,
        movie.posterPath,
      );
      bool isFavorite = await _isFavorite(movie);
      widget.onFavoriteChanged(isFavorite, movie.id);
      setState(() {});
    }
  }

  Future<bool> _isFavorite(Movie movie) async {
    int? userId = await getUserID();
    if (userId != null) {
      var savedMovies = await FavoriteService.getSavedMovies(userId);
      return savedMovies.any((savedMovie) => savedMovie['id'] == movie.id.toString());
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Подробности фильма'),
      ),
      body: FutureBuilder<Movie>(
        future: ApiService().fetchMovieDetails(widget.movieId), 
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppStyles.primaryColor),
            ));
          }

          if (snapshot.hasError) {
            return Center(child: Text('Ошибка: ${snapshot.error}'));
          }

          if (snapshot.hasData) {
            final movie = snapshot.data!;

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            'https://image.tmdb.org/t/p/w500${movie.posterPath}',
                            width: 400,
                            height: 600,
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    movie.title,
                                    style: FilmCardStyle.movieTitleStyle,
                                  ),
                                  IconButton(
                                    icon: FutureBuilder<List<Map<String, String>>>( 
                                      future: _getSavedMovies(),
                                      builder: (BuildContext context, AsyncSnapshot<List<Map<String, String>>> snapshot) { 
                                        if (snapshot.connectionState == ConnectionState.waiting) {
                                          return Icon(Icons.favorite_border);
                                        }

                                        bool isFavorite = snapshot.hasData &&
                                            snapshot.data!.any((savedMovie) => savedMovie['id'] == widget.movieId.toString());
                                        return Icon(
                                          isFavorite ? Icons.favorite : Icons.favorite_border,
                                          color: isFavorite ? Colors.red : Colors.grey,
                                        );
                                      },
                                    ),
                                    onPressed: () => _toggleFavorite(movie),
                                  ),

                                ],
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Дата выпуска: ${movie.releaseDate}',
                                style: FilmCardStyle.dateStyle,
                              ),
                              SizedBox(height: 8),
                              Text(
                                movie.overview,
                                style: FilmCardStyle.movieDescriptionStyle,
                                textAlign: TextAlign.justify,
                              ),
                              SizedBox(height: 16),
                              Row(
                                children: [
                                  Icon(Icons.access_time_outlined),
                                  SizedBox(width: 8),
                                  Text(
                                    '${movie.runtime} минут',
                                    style: FilmCardStyle.movieDescriptionStyle,
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              Row(
                                children: [
                                  Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    movie.voteAverage.toString(),
                                    style: FilmCardStyle.ratingStyle,
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              Row(
                                children: [
                                  SizedBox(width: 12),
                                  Flexible(
                                    child: Text(
                                      'Жанры: ${movie.genre
                                          .map((genre) => genre.name)
                                          .join(', ')}',
                                      style: FilmCardStyle.movieDescriptionStyle,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  SizedBox(width: 12),
                                  Flexible(
                                    child: Text(
                                      'Продюсерские кинокомпании: ${movie.productionCompanies
                                          .map((company) => company.name)
                                          .join(', ')}',
                                      style: FilmCardStyle.movieDescriptionStyle,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Center(
                      child: ElevatedButton(
                        style: FilmCardStyle.backButtonStyle,
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Назад',
                          style: FilmCardStyle.textButtonStyle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return Center(child: Text('Нет доступных данных о фильме.'));
        },
      ),
    );
  }
}
