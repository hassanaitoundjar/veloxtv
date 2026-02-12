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
            emit(AuthSuccess(user));
          } else {
            emit(AuthFailed("Login Failed"));
          }
        } catch (e) {
          emit(AuthFailed(e.toString()));
        }
      } else if (event is AuthGetUser) {
        final user = await LocaleApi.getUser();
        if (user != null) {
          emit(AuthSuccess(user));
        } else {
          emit(AuthFailed("User not found"));
        }
      } else if (event is AuthLogout) {
        await LocaleApi.clearUser();
        emit(AuthInitial());
      }
    });
  }
}
