class Movie {
  final int id;
  final String title;
  final String overview;
  final String posterPath;
  final String releaseDate;
  final double voteAverage;
  final int runtime;
  final List<ProductionCompany> productionCompanies;
  final List<Genre> genre;
  bool isFavorite; 

  Movie({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.releaseDate,
    required this.voteAverage,
    required this.runtime,
    required this.productionCompanies,
    required this.genre,
    this.isFavorite = false, 
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 1,
      title: json['title'] ?? '',
      overview: json['overview'] ?? '',
      posterPath: json['poster_path'] ?? '',
      releaseDate: json['release_date'] ?? '',
      voteAverage: (json['vote_average'] is num ? json['vote_average'] : 0).toDouble(),
      runtime: json['runtime'] is int ? json['runtime'] : 0,
      productionCompanies: (json['production_companies'] as List?)?.map((e) => ProductionCompany.fromJson(e)).toList() ?? [],
      genre: (json['genres'] as List?)?.map((e) => Genre.fromJson(e)).toList() ?? [],
      isFavorite: json['isFavorite'] ?? false, 
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'overview': overview,
      'poster_path': posterPath,
      'release_date': releaseDate,
      'vote_average': voteAverage,
      'runtime': runtime,
      'production_companies': productionCompanies.map((e) => e.toJson()).toList(),
      'genres': genre.map((e) => e.toJson()).toList(),
      'isFavorite': isFavorite, 
    };
  }
}

class ProductionCompany {
  final int id;
  final String name;
  final String originCountry;
  final String? logoPath;

  ProductionCompany({
    required this.id,
    required this.name,
    required this.originCountry,
    this.logoPath,
  });

  factory ProductionCompany.fromJson(Map<String, dynamic> json) {
    return ProductionCompany(
      id: json['id'],
      name: json['name'],
      originCountry: json['origin_country'],
      logoPath: json['logo_path'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'origin_country': originCountry,
      'logo_path': logoPath,
    };
  }
}

class Genre {
  final int id;
  final String name;

  Genre({
    required this.id,
    required this.name,
  });

  factory Genre.fromJson(Map<String, dynamic> json) {
    return Genre(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}
