import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../models/video_metadata.dart';

class DataService {
  // Use the URL from .env if possible, but fallback to this for now
  static const String _apiUrl = 'https://jsonplaceholder.typicode.com/posts/1';

  // Fetch data from API
  Future<VideoMetadata> fetchVideoMetadata() async {
    final response = await http.get(Uri.parse(_apiUrl));

    if (response.statusCode == 200) {
      final jsonMap = json.decode(response.body);
      final metadata = VideoMetadata.fromJson(jsonMap);
      
      // Save to local file immediately after fetching
      await _saveToLocalFile(metadata);
      
      return metadata;
    } else {
      throw Exception('Failed to load video metadata');
    }
  }

  // Save data to app_data/video_metadata.json
  Future<void> _saveToLocalFile(VideoMetadata data) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      
      // Ensure the app_data directory exists
      final appDataDir = Directory('${directory.path}/app_data');
      if (!await appDataDir.exists()) {
        await appDataDir.create(recursive: true);
      }

      final file = File('${appDataDir.path}/video_metadata.json');
      await file.writeAsString(json.encode(data.toJson()));
      print('Saved metadata to: ${file.path}');
    } catch (e) {
      print('Error saving file: $e');
      // We don't throw here because the app can still function even if saving fails
    }
  }
}