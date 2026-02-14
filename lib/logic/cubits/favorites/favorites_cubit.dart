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
      final user = await LocaleApi.getUser();
      if (user != null) {
        final live = await FavoriteLocale.getChannelLive(user.id);
        final movie = await FavoriteLocale.getMovies(user.id);
        final series = await FavoriteLocale.getSeries(user.id);
        emit(FavoritesSuccess(live, movie, series));
      } else {
        emit(FavoritesFailed("User not found"));
      }
    } catch (e) {
      emit(FavoritesFailed(e.toString()));
    }
  }

  Future<void> addLive(ChannelLive channel) async {
    final user = await LocaleApi.getUser();
    if (user != null) {
      await FavoriteLocale.saveChannelLive(channel, user.id);
      initialData();
    }
  }

  Future<void> removeLive(String streamId) async {
    final user = await LocaleApi.getUser();
    if (user != null) {
      await FavoriteLocale.removeChannelLive(streamId, user.id);
      initialData();
    }
  }

  Future<void> addMovie(ChannelMovie movie) async {
    final user = await LocaleApi.getUser();
    if (user != null) {
      await FavoriteLocale.saveMovie(movie, user.id);
      initialData();
    }
  }

  Future<void> removeMovie(String streamId) async {
    final user = await LocaleApi.getUser();
    if (user != null) {
      await FavoriteLocale.removeMovie(streamId, user.id);
      initialData();
    }
  }

  Future<void> addSeries(ChannelSerie serie) async {
    final user = await LocaleApi.getUser();
    if (user != null) {
      await FavoriteLocale.saveSeries(serie, user.id);
      initialData();
    }
  }

  Future<void> removeSeries(String seriesId) async {
    final user = await LocaleApi.getUser();
    if (user != null) {
      await FavoriteLocale.removeSeries(seriesId, user.id);
      initialData();
    }
  }

  Future<void> clearLive() async {
    final user = await LocaleApi.getUser();
    if (user != null) {
      await FavoriteLocale.clearLive(user.id);
      initialData();
    }
  }

  Future<void> clearMovies() async {
    final user = await LocaleApi.getUser();
    if (user != null) {
      await FavoriteLocale.clearMovies(user.id);
      initialData();
    }
  }

  Future<void> clearSeries() async {
    final user = await LocaleApi.getUser();
    if (user != null) {
      await FavoriteLocale.clearSeries(user.id);
      initialData();
    }
  }
}
