part of 'channels_bloc.dart';

@immutable
abstract class ChannelsState {}

class ChannelsInitial extends ChannelsState {}

class ChannelsLoading extends ChannelsState {}

class ChannelsSuccess extends ChannelsState {
  final List<dynamic> channels;
  ChannelsSuccess(this.channels);
}

class ChannelsFailed extends ChannelsState {
  final String message;
  ChannelsFailed(this.message);
}
