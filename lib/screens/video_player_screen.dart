import 'package:flutter/material.dart';

class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({super.key});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flutter PiP Player')),
      body: Column(
        children: [
          // 1. Video Container with specific Key
          Container(
            key: const Key('video-player-container'),
            height: 250,
            color: Colors.black, // Placeholder color
            child: const Center(
              child: Text(
                'Video Player Placeholder',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 2. Progress Bar with specific Key
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: LinearProgressIndicator(
              key: Key('video-progress-bar'),
              value: 0.0, // 0% progress for now
            ),
          ),
          const SizedBox(height: 20),

          // Controls Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // 3. Play/Pause Button with specific Key
              IconButton(
                key: const Key('play-pause-button'),
                onPressed: () {
                  print("Play/Pause tapped");
                },
                icon: const Icon(Icons.play_arrow),
                iconSize: 32,
              ),

              // 4. PiP Button with specific Key
              IconButton(
                key: const Key('pip-mode-button'),
                onPressed: () {
                  print("PiP tapped");
                },
                icon: const Icon(Icons.picture_in_picture_alt),
                iconSize: 32,
              ),
            ],
          ),
        ],
      ),
    );
  }
}