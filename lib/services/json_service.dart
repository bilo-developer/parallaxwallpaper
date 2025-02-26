import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:parallax/models/wallpaper_model.dart';

class JsonService {
  static Future<List<Wallpaper>> loadWallpapers() async {
    final String response =
        await rootBundle.loadString('assets/data/wallpapers.json');
    final List<dynamic> data = jsonDecode(response);
    return data.map((json) => Wallpaper.fromJson(json)).toList();
  }

  static Future<String> getLocalPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<File> saveWallpaper(
      String path, String filename, String content) async {
    final localPath = await getLocalPath();
    final file = File('$localPath/$filename');
    return file
        .writeAsBytes(utf8.encode(content)); // Use writeAsBytes for binary data
  }
}
