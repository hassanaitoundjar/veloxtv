class WaitingModel {
  // Placeholder for watch history
  final String? streamId;
  final String? name;
  final int? duration;

  WaitingModel({this.streamId, this.name, this.duration});

  WaitingModel.fromJson(Map<String, dynamic> json)
      : streamId = json['stream_id'],
        name = json['name'],
        duration = json['duration'];
  
  Map<String, dynamic> toJson() => {
    'stream_id': streamId,
    'name': name,
    'duration': duration,
  };
}
