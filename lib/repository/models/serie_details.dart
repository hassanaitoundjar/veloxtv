class SerieDetails {
  final List<Season>? seasons;
  final InfoSerie? info;
  final Map<String, List<Episode>>? episodes;

  SerieDetails({this.seasons, this.info, this.episodes});

  SerieDetails.fromJson(Map<String, dynamic> json)
      : seasons = (json['seasons'] as List?)
            ?.map((e) => Season.fromJson(e))
            .toList(),
        info = json['info'] != null ? InfoSerie.fromJson(json['info']) : null,
        episodes = (json['episodes'] as Map<String, dynamic>?)?.map(
          (key, value) => MapEntry(
            key,
            (value as List).map((e) => Episode.fromJson(e)).toList(),
          ),
        );
}

class Season {
  final String? airDate;
  final int? episodeCount;
  final int? id;
  final String? name;
  final String? overview;
  final int? seasonNumber;
  final String? voteAverage;
  final String? cover;
  final String? coverBig;

  Season({
    this.airDate,
    this.episodeCount,
    this.id,
    this.name,
    this.overview,
    this.seasonNumber,
    this.voteAverage,
    this.cover,
    this.coverBig,
  });

  Season.fromJson(Map<String, dynamic> json)
      : airDate = json['air_date'].toString(),
        episodeCount = int.tryParse(json['episode_count'].toString()),
        id = int.tryParse(json['id'].toString()),
        name = json['name'].toString(),
        overview = json['overview'].toString(),
        seasonNumber = int.tryParse(json['season_number'].toString()),
        voteAverage = json['vote_average'].toString(),
        cover = json['cover'].toString(),
        coverBig = json['cover_big'].toString();
}

class InfoSerie {
  final String? name;
  final String? cover;
  final String? plot;
  final String? cast;
  final String? director;
  final String? genre;
  final String? releaseDate;
  final String? lastModified;
  final String? rating;
  final String? rating5based;
  final List<String>? backdropPath;
  final String? youtubeTrailer;
  final String? episodeRunTime;
  final String? categoryId;

  InfoSerie({
    this.name,
    this.cover,
    this.plot,
    this.cast,
    this.director,
    this.genre,
    this.releaseDate,
    this.lastModified,
    this.rating,
    this.rating5based,
    this.backdropPath,
    this.youtubeTrailer,
    this.episodeRunTime,
    this.categoryId,
  });

  InfoSerie.fromJson(Map<String, dynamic> json)
      : name = json['name'].toString(),
        cover = json['cover'].toString(),
        plot = json['plot'].toString(),
        cast = json['cast'].toString(),
        director = json['director'].toString(),
        genre = json['genre'].toString(),
        releaseDate = json['releaseDate'].toString(),
        lastModified = json['last_modified'].toString(),
        rating = json['rating'].toString(),
        rating5based = json['rating_5based'].toString(),
        backdropPath = (json['backdrop_path'] as List?)
            ?.map((e) => e.toString())
            .toList(),
        youtubeTrailer = json['youtube_trailer'].toString(),
        episodeRunTime = json['episode_run_time'].toString(),
        categoryId = json['category_id'].toString();
}

class Episode {
  final String? id;
  final int? episodeNum;
  final String? title;
  final String? containerExtension;
  final String? info;
  final int? duration;

  Episode({
    this.id,
    this.episodeNum,
    this.title,
    this.containerExtension,
    this.info,
    this.duration,
  });

  Episode.fromJson(Map<String, dynamic> json)
      : id = json['id'].toString(),
        episodeNum = int.tryParse(json['episode_num'].toString()),
        title = json['title'].toString(),
        containerExtension = json['container_extension'].toString(),
        info = json['info'].toString(),
        duration = int.tryParse(json['duration'].toString());
}
