library widgets;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:google_fonts/google_fonts.dart';

import '../../core/helpers/helpers.dart';
import '../../repository/models/category.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/blocs/categories/live_caty_bloc.dart';
import '../../logic/blocs/categories/movie_caty_bloc.dart';
import '../../logic/blocs/categories/series_caty_bloc.dart';
import '../../logic/cubits/favorites/favorites_cubit.dart';
import '../../repository/models/channel_movie.dart';
import '../../repository/models/channel_serie.dart';

part 'common.dart';
part 'welcome.dart';
part 'live.dart';
part 'tv_text_field.dart';
part 'favorite_button.dart';
part 'play_button.dart';
