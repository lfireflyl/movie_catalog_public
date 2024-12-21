import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:movie_catalog/pages/account_page.dart';
import 'package:movie_catalog/widgets/app_drawer.dart';
import 'package:movie_catalog/services/api.dart';
import 'package:movie_catalog/models/movies.dart';
import 'package:movie_catalog/style/movies_list_style.dart';
import 'package:movie_catalog/pages/film_card.dart';
import 'package:movie_catalog/style/now_watching_style.dart';
import 'package:movie_catalog/services/favorite_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  late Future<List<Movie>> futureMovies;
  List<Movie> displayedMovies = [];
  int startIndex = 0;
  static const int pageSize = 5;
  final FavoriteService favoriteService = FavoriteService();

  Future<int?> getUserID() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userID');
  }

  @override
  void initState() {
    super.initState();
    futureMovies = ApiService().fetchTrendingMovies();
    _loadMoviesFromApi();
  }

  _loadMoviesFromApi() async {
    final movies = await futureMovies;
    setState(() {
      displayedMovies = movies.sublist(0, pageSize);
      startIndex = pageSize;
    });
  }

  void _loadMoreMovies() async {
    final movies = await futureMovies;
    final newMovies = movies.sublist(startIndex, (startIndex + pageSize).clamp(0, movies.length));

    setState(() {
      startIndex += pageSize;
      displayedMovies.addAll(newMovies);
    });
  }

  void _toggleCard(int userId, Movie movie) async {
    await FavoriteService.toggleFavorite(
      userId,
      movie.id,
      movie.title,
      movie.posterPath,
    );
    setState(() {});
  }

  Future<List<Map<String, String>>> _getSavedMovies() async {
    int? userId = await getUserID();
    if (userId != null) {
      return await FavoriteService.getSavedMovies(userId);
    }
    return [];
  }

  void _onFavoriteChanged(bool isFavorite, int movieId) {
    setState(() {
      final movie = displayedMovies.firstWhere((movie) => movie.id == movieId);
      movie.isFavorite = isFavorite;  
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Сейчас смотрят'),
        backgroundColor: AppStyles.primaryColor,
      ),
      drawer: AppDrawer(),
      body: FutureBuilder<List<Movie>>(
        future: futureMovies,
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
            final movies = snapshot.data!;

            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: displayedMovies.length,
                    itemBuilder: (context, index) {
                      final movie = displayedMovies[index];
                      double posterWidth = 150.0;
                      double posterHeight = 225.0;

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FilmCard(
                                  movieId: movie.id,
                                  isFavorite: movie.isFavorite,
                                  onFavoriteChanged: _onFavoriteChanged,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.all(8.0),
                            color: Colors.transparent,
                            child: Row(
                              children: [
                                movie.posterPath.isNotEmpty
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          'https://image.tmdb.org/t/p/w500${movie.posterPath}',
                                          width: posterWidth,
                                          height: posterHeight,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : SizedBox(width: posterWidth, height: posterHeight),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        movie.title,
                                        style: NowWatching.headingStyle,
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        movie.overview,
                                        style: NowWatching.movieDescriptionStyle,
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: FutureBuilder<List<Map<String, String>>>(  
                                    future: _getSavedMovies(),
                                    builder: (context, savedSnapshot) {
                                      if (savedSnapshot.connectionState == ConnectionState.waiting) {
                                        return Icon(Icons.favorite_border);
                                      }

                                      bool isFavorite = savedSnapshot.hasData &&
                                          savedSnapshot.data!
                                              .any((savedMovie) => savedMovie['id'] == movie.id.toString());
                                      return Icon(
                                        isFavorite ? Icons.favorite : Icons.favorite_border,
                                        color: isFavorite ? Colors.red : Colors.grey,
                                      );
                                    },
                                  ),
                                  onPressed: () async {
                                    int? userID = await getUserID();
                                    if (userID != null) {
                                      _toggleCard(userID, movie);  
                                    } else {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => AccountPage()),
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (startIndex + pageSize <= movies.length)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: ElevatedButton(
                      onPressed: _loadMoreMovies,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: AppStyles.primaryColor,
                    ),
                      child: Text('Еще'),
                  ),
                ),
              ],
            );
          }
          return Center(child: Text('Нет доступных фильмов.'));
        },
      ),
    );
  }
}
