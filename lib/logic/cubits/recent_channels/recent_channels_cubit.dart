import 'package:bloc/bloc.dart';

import '../../../repository/api/api.dart';
import '../../../repository/models/channel_live.dart';

part 'recent_channels_state.dart';

class RecentChannelsCubit extends Cubit<RecentChannelsState> {
  RecentChannelsCubit() : super(RecentChannelsInitial());

  Future<void> initialData() async {
    emit(RecentChannelsLoading());
    try {
      final user = await LocaleApi.getUser();
      if (user != null) {
        final live = await RecentLocale.getRecentLive(user.id);
        emit(RecentChannelsSuccess(live));
      } else {
        emit(RecentChannelsFailed("User not found"));
      }
    } catch (e) {
      emit(RecentChannelsFailed(e.toString()));
    }
  }

  Future<void> addLive(ChannelLive channel) async {
    final user = await LocaleApi.getUser();
    if (user != null) {
      await RecentLocale.saveRecentLive(channel, user.id);
      initialData();
    }
  }

  Future<void> removeLive(String streamId) async {
    final user = await LocaleApi.getUser();
    if (user != null) {
      await RecentLocale.removeRecentLive(streamId, user.id);
      initialData();
    }
  }

  Future<void> clearLive() async {
    final user = await LocaleApi.getUser();
    if (user != null) {
      await RecentLocale.clearRecentLive(user.id);
      initialData();
    }
  }
}
