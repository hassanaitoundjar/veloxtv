part of 'auth_bloc.dart';

@immutable
abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final UserModel user;
  AuthSuccess(this.user);
}

class AuthProfilesLoaded extends AuthState {
  final List<UserModel> profiles;
  final UserModel? activeUser; // Added to identify current active profile
  AuthProfilesLoaded(this.profiles, {this.activeUser});
}

class AuthFailed extends AuthState {
  final String message;
  AuthFailed(this.message);
}
