import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/video_metadata.dart';
import '../services/data_service.dart';

class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({super.key});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

// Added WidgetsBindingObserver to detect when app goes to background
class _VideoPlayerScreenState extends State<VideoPlayerScreen> with WidgetsBindingObserver {
  final DataService _dataService = DataService();
  VideoMetadata? _metadata;
  VideoPlayerController? _controller;
  
  bool _isLoading = true;
  String? _errorMessage;

  static const platform = MethodChannel('com.fluttercast.pip/controller');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // Start listening to app lifecycle
    _initializeDataAndPlayer();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // Stop listening
    _savePlaybackPosition(); // Save before closing
    _controller?.dispose();
    super.dispose();
  }

  // Detects when the app goes to background or PiP mode (Requirement 9)
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _savePlaybackPosition();
    }
  }

  Future<void> _initializeDataAndPlayer() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 1. Fetch Metadata
      final data = await _dataService.fetchVideoMetadata();
      
      // 2. Initialize Video Player
      _controller = VideoPlayerController.networkUrl(Uri.parse(data.videoUrl));
      await _controller!.initialize();
      
      // 3. Load Saved Position (Requirement 9)
      final prefs = await SharedPreferences.getInstance();
      final savedSeconds = prefs.getInt('last_playback_position_seconds') ?? 0;
      if (savedSeconds > 0) {
        await _controller!.seekTo(Duration(seconds: savedSeconds));
      }

      // 4. Listen for video progress to update the UI
      _controller!.addListener(() {
        setState(() {}); // Rebuilds to update progress bar
      });

      setState(() {
        _metadata = data;
        _isLoading = false;
      });
      
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  // Save Position Logic (Requirement 9)
  Future<void> _savePlaybackPosition() async {
    if (_controller != null && _controller!.value.isInitialized) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('last_playback_position_seconds', _controller!.value.position.inSeconds);
      print("Saved position: ${_controller!.value.position.inSeconds}s");
    }
  }

  void _togglePlayPause() {
    if (_controller != null) {
      if (_controller!.value.isPlaying) {
        _controller!.pause();
        _savePlaybackPosition(); // Save position when paused
      } else {
        _controller!.play();
      }
      setState(() {});
    }
  }

  Future<void> _enablePiP() async {
    try {
      _savePlaybackPosition(); // Save before entering PiP
      await platform.invokeMethod('enablePictureInPicture');
    } on PlatformException catch (e) {
      print("Failed to enable PiP: '${e.message}'.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flutter PiP Player')),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    // 1. Loading State
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // 2. Error State
    if (_errorMessage != null) {
      return Center(
        child: Container(
          key: const Key('error-message-container'),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Error: $_errorMessage', textAlign: TextAlign.center),
              const SizedBox(height: 10),
              ElevatedButton(
                key: const Key('retry-button'),
                onPressed: _initializeDataAndPlayer,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // 3. Success State
    final isPlaying = _controller?.value.isPlaying ?? false;
    final position = _controller?.value.position.inMilliseconds.toDouble() ?? 0.0;
    final duration = _controller?.value.duration.inMilliseconds.toDouble() ?? 1.0;
    final progress = (duration > 0) ? (position / duration) : 0.0;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            _metadata!.videoTitle,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
        
        // Video Container
        Container(
          key: const Key('video-player-container'),
          color: Colors.black,
          child: _controller != null && _controller!.value.isInitialized
              ? AspectRatio(
                  aspectRatio: _controller!.value.aspectRatio,
                  child: VideoPlayer(_controller!),
                )
              : const SizedBox(
                  height: 250,
                  child: Center(child: CircularProgressIndicator()),
                ),
        ),
        const SizedBox(height: 20),
        
        // Progress Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: LinearProgressIndicator(
            key: const Key('video-progress-bar'),
            value: progress,
          ),
        ),
        const SizedBox(height: 20),
        
        // Controls Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              key: const Key('play-pause-button'),
              onPressed: _togglePlayPause,
              icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
              iconSize: 32,
            ),
            IconButton(
              key: const Key('pip-mode-button'),
              onPressed: _enablePiP,
              icon: const Icon(Icons.picture_in_picture_alt),
              iconSize: 32,
            ),
          ],
        ),
      ],
    );
  }
}