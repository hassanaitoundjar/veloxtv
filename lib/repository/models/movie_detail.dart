class MovieDetail {
  final Info? info;
  final MovieData? movieData;

  MovieDetail({this.info, this.movieData});

  MovieDetail.fromJson(Map<String, dynamic> json)
      : info = json['info'] != null ? Info.fromJson(json['info']) : null,
        movieData = json['movie_data'] != null
            ? MovieData.fromJson(json['movie_data'])
            : null;
}

class Info {
  final String? movieImage;
  final String? tmdbId;
  final String? plot;
  final String? cast;
  final String? rating;
  final String? director;
  final String? genre;
  final String? releaseDate;

  Info({
    this.movieImage,
    this.tmdbId,
    this.plot,
    this.cast,
    this.rating,
    this.director,
    this.genre,
    this.releaseDate,
  });

  Info.fromJson(Map<String, dynamic> json)
      : movieImage = json['movie_image'].toString(),
        tmdbId = json['tmdb_id'].toString(),
        plot = json['plot'].toString(),
        cast = json['cast'].toString(),
        rating = json['rating'].toString(),
        director = json['director'].toString(),
        genre = json['genre'].toString(),
        releaseDate = json['releasedate'].toString();
}

class MovieData {
  final String? streamId;
  final String? name;
  final String? containerExtension;

  MovieData({this.streamId, this.name, this.containerExtension});

  MovieData.fromJson(Map<String, dynamic> json)
      : streamId = json['stream_id'].toString(),
        name = json['name'].toString(),
        containerExtension = json['container_extension'].toString();
}
