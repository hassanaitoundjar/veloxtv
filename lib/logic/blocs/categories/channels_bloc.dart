import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';

import '../../../repository/api/api.dart';

import '../../../core/helpers/helpers.dart';

part 'channels_event.dart';
part 'channels_state.dart';

class ChannelsBloc extends Bloc<ChannelsEvent, ChannelsState> {
  final IpTvApi repo;
  ChannelsBloc(this.repo) : super(ChannelsInitial()) {
    on<ChannelsEvent>((event, emit) async {
      if (event is GetChannels) {
        emit(ChannelsLoading());
        try {
          if (event.type == TypeCategory.live) {
            final list = await repo.getLiveChannels(event.catyId);
            emit(ChannelsSuccess(list));
          } else if (event.type == TypeCategory.movies) {
            final list = await repo.getMovieChannels(event.catyId);
            emit(ChannelsSuccess(list));
          } else if (event.type == TypeCategory.series) {
            final list = await repo.getSeriesChannels(event.catyId);
            emit(ChannelsSuccess(list));
          }
        } catch (e) {
          emit(ChannelsFailed(e.toString()));
        }
      }
    });
  }
}
