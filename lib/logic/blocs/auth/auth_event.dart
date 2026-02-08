part of 'auth_bloc.dart';

@immutable
abstract class AuthEvent {}

class AuthLogin extends AuthEvent {
  final String username;
  final String password;
  final String url;

  AuthLogin(this.username, this.password, this.url);
}

class AuthLogout extends AuthEvent {}

class AuthGetUser extends AuthEvent {}
