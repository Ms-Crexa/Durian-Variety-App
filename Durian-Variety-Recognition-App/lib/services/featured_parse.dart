import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:durian_app/models/featured.dart';

Future<List<FeaturedVariety>> loadFeaturedVarieties() async {
  final String response =
      await rootBundle.loadString('lib/assets/data/featured_variety.json');
  final List<dynamic> data = json.decode(response);
  return data.map((json) => FeaturedVariety.fromJson(json)).toList();
}
