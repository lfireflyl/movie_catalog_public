import 'package:flutter/material.dart';
import 'package:movie_catalog/pages/film_card.dart';
import 'package:movie_catalog/style/movies_list_style.dart';
import '../services/favorite_service.dart';
import 'account_page.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  FavoritesPageState createState() => FavoritesPageState();
}

class FavoritesPageState extends State<FavoritesPage> {
  late Future<List<Map<String, String>>> _savedMoviesFuture;
  bool _isUserAuthorized = false;

  static const int _itemsPerPage = 5;
  int _currentPage = 0;
  List<Map<String, String>> _savedMovies = [];

  @override
  void initState() {
    super.initState();
    _checkAuthorizationStatus();
  }

  Future<void> _checkAuthorizationStatus() async {
    int? userId = await FavoriteService.getUserID();
    setState(() {
      _isUserAuthorized = userId != null;
    });

    if (_isUserAuthorized) {
      _loadFavoriteMovies(userId!);
    } else {
      setState(() {
        _savedMoviesFuture = Future.value([]);
      });
    }
  }

  Future<void> _loadFavoriteMovies(int userId) async {
    setState(() {
      _savedMoviesFuture = FavoriteService.getSavedMovies(userId);
    });

    List<Map<String, String>> movies = await _savedMoviesFuture;
    setState(() {
      _savedMovies = movies;
    });
  }

  List<Map<String, String>> get _currentPageItems {
    int start = _currentPage * _itemsPerPage;
    int end = start + _itemsPerPage;
    return _savedMovies.sublist(
      start,
      end > _savedMovies.length ? _savedMovies.length : end,
    );
  }

  void _nextPage() {
    if ((_currentPage + 1) * _itemsPerPage < _savedMovies.length) {
      setState(() {
        _currentPage++;
      });
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      setState(() {
        _currentPage--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Избранное'),
      ),
      body: _isUserAuthorized
          ? FutureBuilder<List<Map<String, String>>>(
              future: _savedMoviesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppStyles.primaryColor),
                  ));
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Ошибка загрузки данных'));
                }

                if (_savedMovies.isEmpty) {
                  return Center(child: Text('Пока нет избранных фильмов.'));
                }

                return Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: _currentPageItems.length,
                        itemBuilder: (context, index) {
                          var movie = _currentPageItems[index];
                          return Card(
                            margin: EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 16.0),
                            color: Color.fromARGB(227, 242, 253, 255),
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FilmCard(
                                      movieId: int.parse(movie['id']!),
                                      isFavorite: _savedMovies.any(
                                          (savedMovie) =>
                                              savedMovie['id'] ==
                                              movie['id']),
                                      onFavoriteChanged: (isFavorite, movieId) {
                                        _onFavoriteChanged(
                                            isFavorite, movieId);
                                      },
                                    ),
                                  ),
                                );
                              },
                              child: Row(
                                children: [
                                  movie['posterPath']?.isNotEmpty ?? false
                                      ? ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: Image.network(
                                            'https://image.tmdb.org/t/p/w200${movie['posterPath']}',
                                            width: 130,
                                            height: 195,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : SizedBox(width: 92, height: 138),
                                  SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(movie['title']!),
                                        SizedBox(height: 4),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.favorite,
                                      color: Colors.red,
                                    ),
                                    onPressed: () async {
                                      int? userID =
                                          await FavoriteService.getUserID();
                                      if (userID != null) {
                                        FavoriteService.toggleFavorite(
                                            userID,
                                            int.parse(movie['id']!),
                                            movie['title']!,
                                            movie['posterPath']!);
                                        _loadFavoriteMovies(userID);
                                      } else {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  AccountPage()),
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0, top: 8.0), 
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: _previousPage,
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: AppStyles.primaryColor,
                           ),
                            child: Text('Предыдущая'),
                          ),
                          SizedBox(width: 16), 
                          ElevatedButton(
                            onPressed: _nextPage,
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: AppStyles.primaryColor,
                            ),
                            child: Text('Следующая'),
                          ),
                        ],
                      ),
                    ),      
                  ],
                );
              },
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Чтобы просматривать избранное, авторизуйтесь.'),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AccountPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: AppStyles.primaryColor,
                    ),
                    child: Text('Авторизоваться'),
                  ),
                ],
              ),
            ),
    );
  }

  void _onFavoriteChanged(bool isFavorite, int movieId) async {
    int? userId = await FavoriteService.getUserID();
    if (userId != null) {
      String? title;
      String? posterPath;

      List<Map<String, String>> savedMovies =
          await FavoriteService.getSavedMovies(userId);
      var movie = savedMovies.firstWhere(
        (movie) => movie['id'] == movieId.toString(),
        orElse: () => {},
      );

      if (movie.isNotEmpty) {
        title = movie['title'];
        posterPath = movie['posterPath'];
      }

      if (title != null && posterPath != null) {
        FavoriteService.toggleFavorite(userId, movieId, title, posterPath);
      }
      _loadFavoriteMovies(userId);
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AccountPage()),
      );
    }
  }
}
