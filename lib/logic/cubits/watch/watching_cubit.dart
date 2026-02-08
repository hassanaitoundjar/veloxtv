import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:get_storage/get_storage.dart';
// We need to create this model or remove if unused

part 'watching_state.dart';

class WatchingCubit extends Cubit<WatchingState> {
  WatchingCubit() : super(WatchingInitial());
  final storage = GetStorage("watching");

  Future<void> initialData() async {
    emit(WatchingLoading());
    try {
      // Dummy implementation for catch-up/history
      // In a real app we'd read from storage
      emit(WatchingSuccess([]));
    } catch (e) {
      emit(WatchingFailed(e.toString()));
    }
  }

  Future<void> clearData() async {
    await storage.erase();
    emit(WatchingSuccess([]));
  }
}
