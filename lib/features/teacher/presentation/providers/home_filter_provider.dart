import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'home_filter.dart';

final homeFilterProvider = StateProvider<HomeFilter>((ref) => HomeFilter.all);
