part of 'watching_cubit.dart';

@immutable
abstract class WatchingState {}

class WatchingInitial extends WatchingState {}

class WatchingLoading extends WatchingState {}

class WatchingSuccess extends WatchingState {
  final List<dynamic> watching; // Replace dynamic with WaitingModel if created
  WatchingSuccess(this.watching);
}

class WatchingFailed extends WatchingState {
  final String message;
  WatchingFailed(this.message);
}
