import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';

import '../../../repository/api/api.dart';
import '../../../repository/models/category.dart';

part 'movie_caty_event.dart';
part 'movie_caty_state.dart';

class MovieCatyBloc extends Bloc<MovieCatyEvent, MovieCatyState> {
  final IpTvApi repo;
  MovieCatyBloc(this.repo) : super(MovieCatyInitial()) {
    on<MovieCatyEvent>((event, emit) async {
      if (event is GetMovieCategories) {
        emit(MovieCatyLoading());
        try {
          final list = await repo.getCategories("get_vod_categories");
          if (list.isNotEmpty) {
            emit(MovieCatySuccess(list));
          } else {
            emit(MovieCatyFailed("No categories found"));
          }
        } catch (e) {
          emit(MovieCatyFailed(e.toString()));
        }
      }
    });
  }
}
