import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';

part 'video_state.dart';

class VideoCubit extends Cubit<VideoState> {
  VideoCubit() : super(VideoInitial());

  void changeUrlVideo(bool isFull) {
    if (isFull) {
      emit(VideoFullScreen());
    } else {
      emit(VideoInitial());
    }
  }
}
