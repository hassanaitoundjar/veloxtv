part of 'recent_channels_cubit.dart';

abstract class RecentChannelsState {}

class RecentChannelsInitial extends RecentChannelsState {}

class RecentChannelsLoading extends RecentChannelsState {}

class RecentChannelsSuccess extends RecentChannelsState {
  final List<ChannelLive> live;
  RecentChannelsSuccess(this.live);
}

class RecentChannelsFailed extends RecentChannelsState {
  final String msg;
  RecentChannelsFailed(this.msg);
}
