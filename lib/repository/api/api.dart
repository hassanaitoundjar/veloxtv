library api;

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:get_storage/get_storage.dart';

import '../models/category.dart';
import '../models/channel_live.dart';
import '../models/channel_movie.dart';
import '../models/channel_serie.dart';
import '../models/epg.dart';
import '../models/movie_detail.dart';
import '../models/serie_details.dart';
import '../models/user.dart';

part 'iptv.dart';
part 'auth.dart';
part 'm3u_parser.dart';
part 'stalker_api.dart';
part '../locale/locale.dart';
part '../locale/favorites.dart';

final _dio = Dio();
final locale = GetStorage();
final favoritesLocale = GetStorage("favorites");
