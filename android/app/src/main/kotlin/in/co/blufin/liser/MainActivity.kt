package `in`.co.blufin.liser

import android.content.Context
import android.media.AudioManager
import android.database.ContentObserver
import android.os.Handler
import android.os.Looper
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : AudioServiceActivity() {
    private val CHANNEL = "liser/volume_control"
    private val EVENT_CHANNEL = "liser/volume_events"

    private lateinit var audioManager: AudioManager
    private var volumeObserver: ContentObserver? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getVolume" -> {
                    val currentVolume = audioManager.getStreamVolume(AudioManager.STREAM_MUSIC)
                    val maxVolume = audioManager.getStreamMaxVolume(AudioManager.STREAM_MUSIC)
                    val volumeRatio = currentVolume.toDouble() / maxVolume.toDouble()
                    result.success(volumeRatio)
                }
                "setVolume" -> {
                    val volumeRatio = call.argument<Double>("volume") ?: 0.0
                    val maxVolume = audioManager.getStreamMaxVolume(AudioManager.STREAM_MUSIC)
                    val targetVolume = (volumeRatio * maxVolume).toInt()
                    audioManager.setStreamVolume(AudioManager.STREAM_MUSIC, targetVolume, 0)
                    result.success(null)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENT_CHANNEL).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    val handler = Handler(Looper.getMainLooper())
                    volumeObserver = object : ContentObserver(handler) {
                        override fun onChange(selfChange: Boolean) {
                            super.onChange(selfChange)
                            val currentVolume = audioManager.getStreamVolume(AudioManager.STREAM_MUSIC)
                            val maxVolume = audioManager.getStreamMaxVolume(AudioManager.STREAM_MUSIC)
                            val volumeRatio = currentVolume.toDouble() / maxVolume.toDouble()
                            events?.success(volumeRatio)
                        }
                    }
                    contentResolver.registerContentObserver(
                        Settings.System.CONTENT_URI, true, volumeObserver!!
                    )
                }

                override fun onCancel(arguments: Any?) {
                    volumeObserver?.let {
                        contentResolver.unregisterContentObserver(it)
                        volumeObserver = null
                    }
                }
            }
        )
    }
}
