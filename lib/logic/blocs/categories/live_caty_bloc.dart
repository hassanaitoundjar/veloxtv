import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';

import '../../../repository/api/api.dart';
import '../../../repository/models/category.dart';

part 'live_caty_event.dart';
part 'live_caty_state.dart';

class LiveCatyBloc extends Bloc<LiveCatyEvent, LiveCatyState> {
  final IpTvApi repo;
  LiveCatyBloc(this.repo) : super(LiveCatyInitial()) {
    on<LiveCatyEvent>((event, emit) async {
      if (event is GetLiveCategories) {
        emit(LiveCatyLoading());
        try {
          final list = await repo.getCategories("get_live_categories");
          if (list.isNotEmpty) {
            emit(LiveCatySuccess(list));
          } else {
            emit(LiveCatyFailed("No categories found"));
          }
        } catch (e) {
          emit(LiveCatyFailed(e.toString()));
        }
      }
    });
  }
}
