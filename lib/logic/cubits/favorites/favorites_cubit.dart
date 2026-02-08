import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';

import '../../../repository/api/api.dart'; // For FavoriteLocale
import '../../../repository/models/channel_live.dart';
import '../../../repository/models/channel_movie.dart';
import '../../../repository/models/channel_serie.dart';

part 'favorites_state.dart';

class FavoritesCubit extends Cubit<FavoritesState> {
  FavoritesCubit() : super(FavoritesInitial());

  Future<void> initialData() async {
    emit(FavoritesLoading());
    try {
      final live = await FavoriteLocale.getChannelLive();
      final movie = await FavoriteLocale.getMovies();
      final series = await FavoriteLocale.getSeries();

      emit(FavoritesSuccess(live, movie, series));
    } catch (e) {
      emit(FavoritesFailed(e.toString()));
    }
  }

  Future<void> addLive(ChannelLive channel) async {
    await FavoriteLocale.saveChannelLive(channel);
    initialData();
  }

  Future<void> removeLive(String streamId) async {
    await FavoriteLocale.removeChannelLive(streamId);
    initialData();
  }

  Future<void> addMovie(ChannelMovie movie) async {
    await FavoriteLocale.saveMovie(movie);
    initialData();
  }

  Future<void> removeMovie(String streamId) async {
    await FavoriteLocale.removeMovie(streamId);
    initialData();
  }

  Future<void> addSeries(ChannelSerie serie) async {
    await FavoriteLocale.saveSeries(serie);
    initialData();
  }

  Future<void> removeSeries(String seriesId) async {
    await FavoriteLocale.removeSeries(seriesId);
    initialData();
  }
}
