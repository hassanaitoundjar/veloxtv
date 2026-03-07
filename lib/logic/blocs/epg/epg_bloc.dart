import 'package:bloc/bloc.dart';
// import 'package:equatable/equatable.dart'; // Removed to avoid dependency issues
import '../../../repository/api/api.dart';
import '../../../repository/models/epg.dart';

// Events
abstract class EpgEvent {
  const EpgEvent();
}

class LoadEpgForChannel extends EpgEvent {
  final String streamId;
  const LoadEpgForChannel(this.streamId);
}

// State
class EpgState {
  final Map<String, List<EpgModel>> epgMap; // Cache: fileId -> List<Epg>
  final Map<String, bool> loadingStatus; // streamId -> isLoading

  const EpgState({
    this.epgMap = const {},
    this.loadingStatus = const {},
  });

  EpgState copyWith({
    Map<String, List<EpgModel>>? epgMap,
    Map<String, bool>? loadingStatus,
  }) {
    return EpgState(
      epgMap: epgMap ?? this.epgMap,
      loadingStatus: loadingStatus ?? this.loadingStatus,
    );
  }
}

// Bloc
class EpgBloc extends Bloc<EpgEvent, EpgState> {
  final IpTvApi api;

  EpgBloc({required this.api}) : super(const EpgState()) {
    on<LoadEpgForChannel>(_onLoadEpg);
  }

  Future<void> _onLoadEpg(
      LoadEpgForChannel event, Emitter<EpgState> emit) async {
    if (state.epgMap.containsKey(event.streamId)) return; // Already loaded
    if (state.loadingStatus[event.streamId] == true) return; // Already loading

    emit(state.copyWith(
      loadingStatus: {...state.loadingStatus, event.streamId: true},
    ));

    try {
      final epgList = await IpTvApi.getEPGbyStreamId(event.streamId);

      emit(state.copyWith(
        epgMap: {...state.epgMap, event.streamId: epgList},
        loadingStatus: {...state.loadingStatus, event.streamId: false},
      ));
    } catch (e) {
      emit(state.copyWith(
        loadingStatus: {...state.loadingStatus, event.streamId: false},
      ));
    }
  }
}
