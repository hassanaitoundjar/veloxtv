import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';

import '../../../repository/api/api.dart';
import '../../../repository/models/user.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthApi repo;

  AuthBloc(this.repo) : super(AuthInitial()) {
    on<AuthEvent>((event, emit) async {
      if (event is AuthLogin) {
        emit(AuthLoading());
        await Future.delayed(const Duration(seconds: 2));

        try {
          final user =
              await repo.login(event.username, event.password, event.url);
          if (user != null) {
            await LocaleApi.saveUser(user);
            emit(AuthSuccess(user));
          } else {
            emit(AuthFailed("Login Failed"));
          }
        } catch (e) {
          emit(AuthFailed(e.toString()));
        }
      } else if (event is AuthLoginM3u) {
        emit(AuthLoading());
        try {
          final user = await repo.loginM3u(event.name, event.m3uUrl);
          if (user != null) {
            await LocaleApi.saveUser(user);
            emit(AuthSuccess(user));
          } else {
            emit(AuthFailed("Invalid M3U URL or playlist is empty"));
          }
        } catch (e) {
          emit(AuthFailed(e.toString()));
        }
      } else if (event is AuthLoginStalker) {
        emit(AuthLoading());
        try {
          final user = await repo.loginStalker(
              event.name, event.portalUrl, event.macAddress);
          if (user != null) {
            await LocaleApi.saveUser(user);
            emit(AuthSuccess(user));
          } else {
            emit(AuthFailed(
                "Stalker Portal authentication failed. Check URL and MAC address."));
          }
        } catch (e) {
          emit(AuthFailed(e.toString()));
        }
      } else if (event is AuthGetUser) {
        try {
          final user = await LocaleApi.getUser();
          if (user != null) {
            emit(AuthSuccess(user));
          } else {
            final profiles = LocaleApi.getProfiles();
            if (profiles.isNotEmpty) {
              emit(AuthProfilesLoaded(profiles, activeUser: null));
            } else {
              emit(AuthFailed("User not found"));
            }
          }
        } catch (e) {
          emit(AuthFailed(e.toString()));
        }
      } else if (event is AuthLogout) {
        await LocaleApi.clearUser();
        emit(AuthInitial());
      } else if (event is AuthLoadProfiles) {
        try {
          final profiles = LocaleApi.getProfiles();
          final activeUser = await LocaleApi.getUser();
          emit(AuthProfilesLoaded(profiles, activeUser: activeUser));
        } catch (e) {
          emit(AuthFailed("Failed to load profiles"));
        }
      } else if (event is AuthSwitchProfile) {
        emit(AuthLoading());
        try {
          await LocaleApi.saveUser(event.user);
          emit(AuthSuccess(event.user));
        } catch (e) {
          emit(AuthFailed("Failed to switch profile"));
        }
      } else if (event is AuthDeleteProfile) {
        try {
          await LocaleApi.removeProfile(event.user);
          final profiles = LocaleApi.getProfiles();
          final activeUser = await LocaleApi.getUser();
          emit(AuthProfilesLoaded(profiles, activeUser: activeUser));
        } catch (e) {
          add(AuthLoadProfiles());
        }
      }
    });
  }
}
