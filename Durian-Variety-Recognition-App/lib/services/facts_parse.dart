import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:durian_app/models/facts.dart';

Future<List<Fact>> loadFacts() async {
  final String response =
      await rootBundle.loadString('lib/assets/data/facts.json');
  final List<dynamic> data = json.decode(response);
  return data.map((json) => Fact.fromJson(json)).toList();
}
