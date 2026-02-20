package com.example.flutter_video_player


import android.app.PendingIntent
import android.app.PictureInPictureParams
import android.app.RemoteAction
import android.content.Intent
import android.graphics.drawable.Icon
import android.os.Build
import android.util.Rational
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    // Must exactly match Requirement 5
    private val CHANNEL = "com.fluttercast.pip/controller"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "enablePictureInPicture") {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    val aspectRatio = Rational(16, 9)
                    
                    // Requirement 8: Custom remote actions (Play/Pause placeholder)
                    val intent = Intent("MEDIA_CONTROL")
                    val pendingIntent = PendingIntent.getBroadcast(this, 0, intent, PendingIntent.FLAG_IMMUTABLE)
                    // Using a default Android icon for the play button
                    val icon = Icon.createWithResource(this, android.R.drawable.ic_media_play)
                    val playAction = RemoteAction(icon, "Play", "Play Video", pendingIntent)
                    
                    val pipParams = PictureInPictureParams.Builder()
                        .setAspectRatio(aspectRatio)
                        .setActions(listOf(playAction)) // Adds the control to the PiP window
                        .build()
                        
                    enterPictureInPictureMode(pipParams)
                    result.success(true)
                } else {
                    result.error("UNSUPPORTED", "PiP not supported on this device.", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }
}
