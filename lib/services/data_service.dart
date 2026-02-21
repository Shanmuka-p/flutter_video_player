import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../models/video_metadata.dart';

class DataService {
  static const String _apiUrl = 'https://jsonplaceholder.typicode.com/posts/1';

  // Fetch data from API with headers to prevent 403 Forbidden errors
  Future<VideoMetadata> fetchVideoMetadata() async {
    try {
      final response = await http.get(
        Uri.parse(_apiUrl),
        headers: {
          'Accept': 'application/json',
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
        },
      );

      if (response.statusCode == 200) {
        final jsonMap = json.decode(response.body);
        final metadata = VideoMetadata.fromJson(jsonMap);
        
        await _saveToLocalFile(metadata);
        return metadata;
      } else {
        throw Exception('Server error! Status Code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Detailed Network Error: $e');
    }
  }

  // Save data to app_data/video_metadata.json (Requirement 4)
  Future<void> _saveToLocalFile(VideoMetadata data) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      
      final appDataDir = Directory('${directory.path}/app_data');
      if (!await appDataDir.exists()) {
        await appDataDir.create(recursive: true);
      }

      final file = File('${appDataDir.path}/video_metadata.json');
      await file.writeAsString(json.encode(data.toJson()));
      print('Saved metadata to: ${file.path}');
    } catch (e) {
      print('Error saving file: $e');
    }
  }
}