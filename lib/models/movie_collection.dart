class MovieCollection {
  final String name;
  final List<int> movieIds;

  MovieCollection({required this.name, required this.movieIds});

  Map<String, dynamic> toJson() => {
        'name': name,
        'movieIds': movieIds,
      };

  static MovieCollection fromJson(Map<String, dynamic> json) => MovieCollection(
        name: json['name'],
        movieIds: List<int>.from(json['movieIds']),
      );
}
