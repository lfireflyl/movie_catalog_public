import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movies.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  final String _apiKey = dotenv.get('API_KEY');
  final String _baseUrl = dotenv.get('BASE_URL');

  Future<List<Movie>> fetchTrendingMovies() async {
    final response = await _makeRequest(
      endpoint: '/trending/movie/day',
      params: {'language': 'ru-RU'},
    );

    final List<dynamic> data = response['results'];
    return data.map((json) => Movie.fromJson(json)).toList();
  }

  Future<Movie> fetchMovieDetails(int movieId) async {
    final response = await _makeRequest(
      endpoint: '/movie/$movieId',
      params: {'language': 'ru-RU'},
    );

    return Movie.fromJson(response);
  }

  Future<List<Movie>> searchMovies(String query,
      {String? year, int page = 1}) async {
    final yearFilter = year != null && year.isNotEmpty ? year : null;

    final response = await _makeRequest(
      endpoint: '/search/movie',
      params: {
        'query': query,
        if (yearFilter != null) 'year': yearFilter,
        'include_adult': 'false',
        'language': 'ru-RU',
        'page': page.toString(),
      },
    );

    final List<dynamic> data = response['results'];
    return data.map((json) => Movie.fromJson(json)).toList();
  }

  Future<List<Map<String, dynamic>>> fetchGenres() async {
    final response = await _makeRequest(
      endpoint: '/genre/movie/list',
      params: {'language': 'ru-RU'},
    );

    final List<dynamic> data = response['genres'];
    return data.map((genre) {
      return {'id': genre['id'], 'name': genre['name']};
    }).toList();
  }

  Future<T> _makeRequest<T>({
    required String endpoint,
    Map<String, String>? params,
  }) async {
    final uri = Uri.parse(_baseUrl + endpoint).replace(
      queryParameters: {
        'api_key': _apiKey,
        if (params != null) ...params,
      },
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return json.decode(response.body) as T;
    } else {
      throw Exception('Ошибка запроса: ${response.statusCode}');
    }
  }
}
