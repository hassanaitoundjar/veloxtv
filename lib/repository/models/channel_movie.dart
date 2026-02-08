class ChannelMovie {
  final int? num;
  final String? name;
  final String? streamType;
  final String? streamId;
  final String? streamIcon;
  final String? rating;
  final double? rating5based;
  final String? added;
  final String? categoryId;
  final String? customSid;
  final String? directSource;

  ChannelMovie({
    this.num,
    this.name,
    this.streamType,
    this.streamId,
    this.streamIcon,
    this.rating,
    this.rating5based,
    this.added,
    this.categoryId,
    this.customSid,
    this.directSource,
  });

  ChannelMovie.fromJson(Map<String, dynamic> json)
      : num = int.tryParse(json['num'].toString()),
        name = json['name'].toString(),
        streamType = json['stream_type'].toString(),
        streamId = json['stream_id'].toString(),
        streamIcon = json['stream_icon'].toString(),
        rating = json['rating'].toString(),
        rating5based = double.tryParse(json['rating_5based'].toString()),
        added = json['added'].toString(),
        categoryId = json['category_id'].toString(),
        customSid = json['custom_sid'].toString(),
        directSource = json['direct_source'].toString();

  Map<String, dynamic> toJson() => {
        'num': num,
        'name': name,
        'stream_type': streamType,
        'stream_id': streamId,
        'stream_icon': streamIcon,
        'rating': rating,
        'rating_5based': rating5based,
        'added': added,
        'category_id': categoryId,
        'custom_sid': customSid,
        'direct_source': directSource,
      };
}
