class WatchingModel {
  final String streamId;
  final String image;
  final String title;

  double sliderValue;
  final double durationStrm;
  final String stream;

  WatchingModel({
    required this.streamId,
    required this.image,
    required this.title,
    required this.stream,
    required this.sliderValue,
    required this.durationStrm,
  });

  factory WatchingModel.fromJson(Map<String, dynamic> json) {
    return WatchingModel(
      streamId: json["streamId"]?.toString() ?? '',
      image: json["image"]?.toString() ?? '',
      title: json["title"]?.toString() ?? '',
      sliderValue: double.tryParse(json["sliderValue"]?.toString() ?? '') ?? 0.0,
      stream: json["stream"]?.toString() ?? '',
      durationStrm: double.tryParse(json['durationStrm']?.toString() ?? '') ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "streamId": streamId,
      "image": image,
      "title": title,
      "sliderValue": sliderValue,
      "stream": stream,
      'durationStrm': durationStrm,
    };
  }

//
}
