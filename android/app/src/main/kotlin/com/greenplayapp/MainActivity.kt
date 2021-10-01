package com.greenplayapp


import android.content.ContextWrapper
import android.content.Intent
import android.content.IntentFilter
import android.os.BatteryManager
import android.os.Build
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

const val CHANNEL = "com.greenplay/sensors"

class MainActivity : FlutterActivity() {

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->
            invokeGenericChannelMethod(call, result)
        }
    }

    private fun invokeGenericChannelMethod(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getBatteryLevel" -> {
                val batteryLevel = getBatteryLevel()
                if (batteryLevel != -1) {
                    result.success(batteryLevel)
                } else {
                    result.error("UNAVAILABLE", "Battery level not available.", null)
                }
            }
            "getSensorLogs" -> {
                val sensorLog = getAllSensorPoint(applicationContext)
                if (sensorLog != null) {
                    result.success(sensorLog)
                } else {
                    result.error("UNAVAILABLE", "Sensor Logs not available.", null)
                }
            }

            "startSensorService" -> {
                try {
                    startSensorTracking(applicationContext)
                    result.success(null)
                } catch (e: Exception) {
                    result.error("UNAVAILABLE", "Start Sensor Tracker Failed", null)
                    result.success(null)
                }
            }

            "stopSensorService" -> {
                try {
                    stopSensorTracking(applicationContext)
                    result.success(null)
                } catch (e: Exception) {
                    result.error("UNAVAILABLE", "Stop Sensor Tracker Failed", null)
                }
            }

            "clearSensorLogs" -> {
                try {
                    clearSensorData(applicationContext)
                    result.success(null)
                } catch (e: Exception) {
                    result.error("UNAVAILABLE", "All Sensor Logs wiping not available.", null)
                }
            }

            "removeSensorLog" -> {
                try {
                    val payload = call.arguments.toString()
                    removeSensorPoint(payload, applicationContext)
                    result.success(null)
                } catch (e: Exception) {
                    result.error("UNAVAILABLE", "Sensor Log removal failed ${call.arguments}", null)
                }
            }
            else -> result.notImplemented()

        }
    }

    private fun randomFloat() = (Math.random() / 1000).toFloat();

    private fun getBatteryLevel(): Int {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            val batteryManager = getSystemService(BATTERY_SERVICE) as BatteryManager
            batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
        } else {
            val intent = ContextWrapper(applicationContext).registerReceiver(
                null, IntentFilter(
                    Intent.ACTION_BATTERY_CHANGED
                )
            )
            intent!!.getIntExtra(BatteryManager.EXTRA_LEVEL, -1) * 100 / intent.getIntExtra(
                BatteryManager.EXTRA_SCALE,
                -1
            )
        }
    }
}
