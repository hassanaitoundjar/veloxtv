import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:convert';

import '../../../repository/models/watching.dart';

part 'watching_state.dart';

class WatchingCubit extends Cubit<WatchingState> {
  final GetStorage _storage;

  WatchingCubit()
      : _storage = GetStorage("watching"),
        super(WatchingState.defaultData());

  void initialData() async {
    emit(WatchingState(
      movies: await _getWatchingMovies(),
      series: await _getWatchingSeries(),
      live: await _getWatchingLives(),
    ));
  }

  Future<List<WatchingModel>> _getWatchingMovies() async {
    final data = _storage.read('movies');
    if (data == null) return [];
    return (jsonDecode(data) as List)
        .map((e) => WatchingModel.fromJson(e))
        .toList();
  }

  Future<List<WatchingModel>> _getWatchingSeries() async {
    final data = _storage.read('series');
    if (data == null) return [];
    return (jsonDecode(data) as List)
        .map((e) => WatchingModel.fromJson(e))
        .toList();
  }

  Future<List<WatchingModel>> _getWatchingLives() async {
    final data = _storage.read('live');
    if (data == null) return [];
    return (jsonDecode(data) as List)
        .map((e) => WatchingModel.fromJson(e))
        .toList();
  }

  void addMovie(WatchingModel movie) async {
    final List<WatchingModel> editList = state.movies
        .where((element) => element.streamId != movie.streamId)
        .toList();
    editList.insert(0, movie);

    await _storage.write(
        'movies', jsonEncode(editList.map((e) => e.toJson()).toList()));
    emit(WatchingState(
      movies: editList,
      series: state.series,
      live: state.live,
    ));
  }

  void addSerie(WatchingModel serie) async {
    final List<WatchingModel> editList = state.series
        .where((element) => element.streamId != serie.streamId)
        .toList();
    editList.insert(0, serie);

    await _storage.write(
        'series', jsonEncode(editList.map((e) => e.toJson()).toList()));
    emit(WatchingState(
      movies: state.movies,
      series: editList,
      live: state.live,
    ));
  }

  void addLive(WatchingModel live) async {
    final List<WatchingModel> editList = state.live
        .where((element) => element.streamId != live.streamId)
        .toList();
    editList.insert(0, live);

    await _storage.write(
        'live', jsonEncode(editList.map((e) => e.toJson()).toList()));
    emit(WatchingState(
      movies: state.movies,
      series: state.series,
      live: editList,
    ));
  }

  Future<void> clearData() async {
    await _storage.erase();
    emit(WatchingState.defaultData());
  }
}
