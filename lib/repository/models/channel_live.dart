class ChannelLive {
  final int? num;
  final String? name;
  final String? streamType;
  final String? streamId;
  final String? streamIcon;
  final String? epgChannelId;
  final String? added;
  final String? categoryId;
  final String? customSid;
  final int? tvArchive;
  final String? directSource;
  final int? tvArchiveDuration;

  ChannelLive({
    this.num,
    this.name,
    this.streamType,
    this.streamId,
    this.streamIcon,
    this.epgChannelId,
    this.added,
    this.categoryId,
    this.customSid,
    this.tvArchive,
    this.directSource,
    this.tvArchiveDuration,
  });

  ChannelLive.fromJson(Map<String, dynamic> json)
      : num = int.tryParse(json['num'].toString()),
        name = json['name'].toString(),
        streamType = json['stream_type'].toString(),
        streamId = json['stream_id'].toString(),
        streamIcon = json['stream_icon'].toString(),
        epgChannelId = json['epg_channel_id'].toString(),
        added = json['added'].toString(),
        categoryId = json['category_id'].toString(),
        customSid = json['custom_sid'].toString(),
        tvArchive = int.tryParse(json['tv_archive'].toString()),
        directSource = json['direct_source'].toString(),
        tvArchiveDuration = int.tryParse(json['tv_archive_duration'].toString());

  Map<String, dynamic> toJson() => {
        'num': num,
        'name': name,
        'stream_type': streamType,
        'stream_id': streamId,
        'stream_icon': streamIcon,
        'epg_channel_id': epgChannelId,
        'added': added,
        'category_id': categoryId,
        'custom_sid': customSid,
        'tv_archive': tvArchive,
        'direct_source': directSource,
        'tv_archive_duration': tvArchiveDuration,
      };
}
