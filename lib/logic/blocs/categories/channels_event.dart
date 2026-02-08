part of 'channels_bloc.dart';

@immutable
abstract class ChannelsEvent {}

class GetChannels extends ChannelsEvent {
  final String catyId;
  final TypeCategory type;

  GetChannels(this.catyId, this.type);
}
