import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Required for Platform Channels
import '../models/video_metadata.dart';
import '../services/data_service.dart';

class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({super.key});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late Future<VideoMetadata> _videoDataFuture;
  final DataService _dataService = DataService();

  // The MethodChannel matching Requirement 5 exactly
  static const platform = MethodChannel('com.fluttercast.pip/controller');

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _videoDataFuture = _dataService.fetchVideoMetadata();
    });
  }

  // Function to trigger native Android PiP mode
  Future<void> _enablePiP() async {
    try {
      await platform.invokeMethod('enablePictureInPicture');
    } on PlatformException catch (e) {
      print("Failed to enable PiP: '${e.message}'.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flutter PiP Player')),
      body: FutureBuilder<VideoMetadata>(
        future: _videoDataFuture,
        builder: (context, snapshot) {
          // 1. Loading State
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Error State (Requirement 10)
          if (snapshot.hasError) {
            return Center(
              child: Container(
                key: const Key('error-message-container'),
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Error: ${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      key: const Key('retry-button'),
                      onPressed: _loadData,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          // 3. Success State
          final data = snapshot.data!;
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  data.videoTitle,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              
              // Video Container (Requirement 6)
              Container(
                key: const Key('video-player-container'),
                height: 250,
                width: double.infinity,
                color: Colors.black,
                child: const Center(
                  child: Text(
                    'Video Loaded (Placeholder)',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Progress Bar (Requirement 6)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: LinearProgressIndicator(
                  key: Key('video-progress-bar'),
                  value: 0.0,
                ),
              ),
              const SizedBox(height: 20),
              
              // Controls Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Play/Pause Button (Requirement 6)
                  IconButton(
                    key: const Key('play-pause-button'),
                    onPressed: () => print("Play/Pause tapped"), // We will hook this up in Day 4
                    icon: const Icon(Icons.play_arrow),
                    iconSize: 32,
                  ),
                  
                  // PiP Mode Button (Requirement 6 & 7)
                  IconButton(
                    key: const Key('pip-mode-button'),
                    onPressed: _enablePiP, // Calls the native channel!
                    icon: const Icon(Icons.picture_in_picture_alt),
                    iconSize: 32,
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}