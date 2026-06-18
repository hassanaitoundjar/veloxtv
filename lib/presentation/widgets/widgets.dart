library widgets;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:intl/intl.dart';
import 'dart:async';

import '../../core/helpers/helpers.dart';
import '../../repository/models/category.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/blocs/categories/live_caty_bloc.dart';
import '../../logic/blocs/categories/movie_caty_bloc.dart';
import '../../logic/blocs/categories/series_caty_bloc.dart';

part 'common.dart';
part 'welcome.dart';
part 'live.dart';
