package com.greenplay.sensortracker.sensortracker

import android.content.Context
import android.content.SharedPreferences
import android.os.Handler
import android.os.Looper
import android.util.Log
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.util.concurrent.ExecutorService
import java.util.concurrent.LinkedBlockingQueue
import java.util.concurrent.ThreadPoolExecutor
import java.util.concurrent.TimeUnit

/** SensortrackerPlugin */
class SensortrackerPlugin : FlutterPlugin, MethodCallHandler {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private val SHARED_PREFERENCES_NAME: String = "green_play_sensor_prefs"

    // Fun fact: The following is a base64 encoding of the string "This is the prefix for a list."
    private val LIST_IDENTIFIER = "VGhpcyBpcyB0aGUgcHJlZml4IGZvciBhIGxpc3Qu"
    private val BIG_INTEGER_PREFIX = "VGhpcyBpcyB0aGUgcHJlZml4IGZvciBCaWdJbnRlZ2Vy"
    private val DOUBLE_PREFIX = "VGhpcyBpcyB0aGUgcHJlZml4IGZvciBEb3VibGUu"
    private lateinit var channel: MethodChannel

    private lateinit var preferences: SharedPreferences

    private lateinit var executor: ExecutorService
    private lateinit var handler: Handler

    override fun onAttachedToEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, "sensortracker")
        setupChannel(binding.binaryMessenger, binding.applicationContext);
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        Log.d("sensorPlugin","onMethodCall");

        if (call.method == "getPlatformVersion") {
            Log.d("sensorPlugin","getPlatformVersion");

            result.success("Android5.55")
        } else if (call.method == "lastHeadlessUpdate") {
            Log.d("sensorPlugin","lastHeadlessUpdate start");

            val doubleValue = (call.argument<Any>("value") as Number?)!!.toDouble()
            Log.d("sensorPlugin","lastHeadlessUpdate value $doubleValue");

            commitAsync(preferences.edit().putLong("heyhey", doubleValue.toLong()), result)
        } else {
            result.notImplemented()
        }
    }

    private fun setupChannel(messenger: BinaryMessenger, context: Context) {
        channel = MethodChannel(messenger, SHARED_PREFERENCES_NAME)
        preferences = context.getSharedPreferences(SHARED_PREFERENCES_NAME, Context.MODE_PRIVATE)
        executor = ThreadPoolExecutor(0, 1, 30L, TimeUnit.SECONDS, LinkedBlockingQueue())
        handler = Handler(Looper.getMainLooper())
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    private fun commitAsync(
            editor: SharedPreferences.Editor, result: Result) {
        executor.execute(
                Runnable {
                    val response = editor.commit()
                    handler.post(
                            Runnable { result.success(response) })
                })
    }

}

