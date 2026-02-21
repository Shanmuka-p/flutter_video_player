import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
// Note: Adjust the import path below if your project name is different
import 'package:flutter_video_player/screens/video_player_screen.dart';

void main() {
  testWidgets('VideoPlayerScreen renders key UI elements', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MaterialApp(
      home: VideoPlayerScreen(),
    ));

    // Because the screen fetches data asynchronously on initState, 
    // it initially shows a CircularProgressIndicator. We need to pump 
    // the widget tree to allow the FutureBuilder to complete or hit the error state.
    // For a robust test, we pump and settle to reach the final UI state.
    await tester.pumpAndSettle();

    // Verify the Error/Success UI containers exist using the specific Keys
    // The test looks for either the success UI OR the error UI since it relies on network
    final hasVideoContainer = find.byKey(const Key('video-player-container')).evaluate().isNotEmpty;
    final hasErrorContainer = find.byKey(const Key('error-message-container')).evaluate().isNotEmpty;
    
    expect(hasVideoContainer || hasErrorContainer, isTrue, 
      reason: 'Should display either the video player container or the error container.');

    if (hasVideoContainer) {
      // Verify specific player controls if the video container loaded
      expect(find.byKey(const Key('play-pause-button')), findsOneWidget);
      expect(find.byKey(const Key('pip-mode-button')), findsOneWidget);
      expect(find.byKey(const Key('video-progress-bar')), findsOneWidget);
    } else if (hasErrorContainer) {
      // Verify retry button if the network call failed during the test
      expect(find.byKey(const Key('retry-button')), findsOneWidget);
    }
  });
}