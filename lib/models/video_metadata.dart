class VideoMetadata {
  final int videoId;
  final String videoTitle;
  final String videoUrl;

  VideoMetadata({
    required this.videoId,
    required this.videoTitle,
    required this.videoUrl,
  });

  // Factory constructor to create an instance from JSON
  factory VideoMetadata.fromJson(Map<String, dynamic> json) {
    return VideoMetadata(
      videoId: json['id'] ?? 0, // 'id' from API becomes 'videoId'
      videoTitle: json['title'] ?? 'Unknown Title',
      // The API doesn't give a video URL, so we use a sample one
      videoUrl:
          'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
    );
  }

  // Method to convert instance back to JSON for saving
  Map<String, dynamic> toJson() {
    return {'videoId': videoId, 'videoTitle': videoTitle, 'videoUrl': videoUrl};
  }
}
