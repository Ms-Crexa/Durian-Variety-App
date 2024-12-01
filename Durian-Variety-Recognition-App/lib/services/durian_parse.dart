import 'dart:convert';
import 'package:durian_app/models/durian.dart';
import 'package:flutter/services.dart';

Future<List<Durian>> loadDurianData() async {
  final String response =
      await rootBundle.loadString('lib/assets/data/durian_data.json');
  final List<dynamic> data = json.decode(response);
  return data.map((json) => Durian.fromJson(json)).toList();
}
