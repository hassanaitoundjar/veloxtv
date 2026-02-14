part of 'auth_bloc.dart';

@immutable
abstract class AuthEvent {}

class AuthLogin extends AuthEvent {
  final String username;
  final String password;
  final String url;

  AuthLogin(this.username, this.password, this.url);
}

class AuthLoginM3u extends AuthEvent {
  final String name;
  final String m3uUrl;

  AuthLoginM3u(this.name, this.m3uUrl);
}

class AuthLoginStalker extends AuthEvent {
  final String name;
  final String portalUrl;
  final String macAddress;

  AuthLoginStalker(this.name, this.portalUrl, this.macAddress);
}

class AuthGetUser extends AuthEvent {}

class AuthLogout extends AuthEvent {}

// New Events for Profiles
class AuthLoadProfiles extends AuthEvent {}

class AuthSwitchProfile extends AuthEvent {
  final UserModel user;
  AuthSwitchProfile(this.user);
}

class AuthDeleteProfile extends AuthEvent {
  final UserModel user;
  AuthDeleteProfile(this.user);
}
