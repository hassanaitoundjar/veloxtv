import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';

import '../../../repository/api/api.dart';
import '../../../repository/models/category.dart';

part 'series_caty_event.dart';
part 'series_caty_state.dart';

class SeriesCatyBloc extends Bloc<SeriesCatyEvent, SeriesCatyState> {
  final IpTvApi repo;
  SeriesCatyBloc(this.repo) : super(SeriesCatyInitial()) {
    on<SeriesCatyEvent>((event, emit) async {
      if (event is GetSeriesCategories) {
        emit(SeriesCatyLoading());
        try {
          final list = await repo.getCategories("get_series_categories");
          if (list.isNotEmpty) {
            emit(SeriesCatySuccess(list));
          } else {
            emit(SeriesCatyFailed("No categories found"));
          }
        } catch (e) {
          emit(SeriesCatyFailed(e.toString()));
        }
      }
    });
  }
}
