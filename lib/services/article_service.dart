import 'dart:convert';
import 'package:facebook_replication/constants.dart';
import 'package:http/http.dart' as http;

class ArticleService {
  List listData = [];

  Future<List> getAllArticle() async {
    final response = await http.get(
      Uri.parse('$host/api/articles'),
      headers: {
        'Accept': 'application/json',
        'User-Agent': 'Dart/3.0 (Flutter)',
      },
    );

    if (response.statusCode == 200) {
      listData = jsonDecode(response.body);
      return listData;
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<Map> createArticle(dynamic article) async {
    Map mapData = {}; 
    final response = await http.post(
      Uri.parse('$host/api/articles'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(article),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      mapData = jsonDecode(response.body);
      return mapData;
    } else {
      throw Exception(
        'Failed to create article: ${response.statusCode} ${response.body}',  
      );
    }
  }

  Future<Map> updateArticle(String id, dynamic article) async {
    Map mapData = {};  
    final response = await http.put(
      Uri.parse('$host/api/articles/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(article),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      mapData = jsonDecode(response.body);
      return mapData;
    } else {
      throw Exception(
        'Failed to update article: ${response.statusCode} ${response.body}', 
      );
    }
  }
}
