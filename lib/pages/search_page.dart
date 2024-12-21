import 'package:flutter/material.dart';
import 'package:movie_catalog/services/api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/movies.dart';
import '../services/favorite_service.dart';
import '../style/movies_list_style.dart';
import '../widgets/year_input_widget.dart';
import 'account_page.dart';
import 'film_card.dart';
import 'package:flutter/foundation.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  SearchPageState createState() => SearchPageState();
}

class SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  List<Movie> _movies = [];
  bool _isLoading = false;
  int _currentPage = 1;
  bool _hasNextPage = true;

  Future<void> _searchMovies() async {
    setState(() {
      _isLoading = true;
      _hasNextPage = true;
    });

    try {
      final movies = await ApiService().searchMovies(
        _searchController.text,
        year: _yearController.text.isNotEmpty ? _yearController.text : null,
        page: _currentPage,
      );

      setState(() {
        if (movies.isEmpty) {
          _hasNextPage = false;
        } else {
          _movies = movies;
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка поиска фильмов: $e');
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadNextPage() async {
    if (_hasNextPage) {
      setState(() {
        _currentPage++;
      });
      await _searchMovies();
    }
  }

  Future<void> _loadPreviousPage() async {
    if (_hasNextPage) {
      setState(() {
        _currentPage--;
      });
      await _searchMovies();
    }
  }

  Future<int?> getUserID() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userID');
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
      final movie = _movies.firstWhere((movie) => movie.id == movieId);
      movie.isFavorite = isFavorite; 
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Поиск фильмов')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Введите название фильма',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  width: 2.0,
                  color: AppStyles.primaryColor), 
                ),
              ),
              cursorColor: AppStyles.primaryColor,
              onSubmitted: (_) => _searchMovies(),
            ),
            SizedBox(height: 10),
            YearInputWidget(
              yearController: _yearController,
              onYearChanged: (_) => _searchMovies(),
            ),
            SizedBox(height: 10),
            _isLoading
                ? CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppStyles.primaryColor),
                )
                : Expanded(
                    child: ListView.builder(
                      itemCount: _movies.length,
                      itemBuilder: (context, index) {
                        final movie = _movies[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FilmCard(
                                  movieId: movie.id,
                                  isFavorite: movie.isFavorite, 
                                  onFavoriteChanged: (isFavorite, movieId) {
                                    _onFavoriteChanged(isFavorite, movieId); 
                                  },
                                ),
                              ),
                            );
                          },
                          child: Card(
                            margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
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
                                    : SizedBox(width: 92, height: 138),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(movie.title),
                                      SizedBox(height: 4),
                                      Text('Дата выхода: ${movie.releaseDate}'),
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
                        );
                      },
                    ),
                  ),
            if (!_isLoading)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_currentPage > 1)
                      ElevatedButton(
                        onPressed: _loadPreviousPage,
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: AppStyles.primaryColor,
                    ),
                        child: Text('Назад'),
                      ),
                    SizedBox(width: 16),
                    if (_hasNextPage)
                      ElevatedButton(
                        onPressed: _loadNextPage,
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: AppStyles.primaryColor,
                    ),
                        child: Text('Вперед'),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
