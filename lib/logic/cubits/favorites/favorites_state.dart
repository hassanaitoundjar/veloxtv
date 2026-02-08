part of 'favorites_cubit.dart';

@immutable
abstract class FavoritesState {}

class FavoritesInitial extends FavoritesState {}

class FavoritesLoading extends FavoritesState {}

class FavoritesSuccess extends FavoritesState {
  final List<ChannelLive> live;
  final List<ChannelMovie> movies;
  final List<ChannelSerie> series;

  FavoritesSuccess(this.live, this.movies, this.series);
}

class FavoritesFailed extends FavoritesState {
  final String message;
  FavoritesFailed(this.message);
}
