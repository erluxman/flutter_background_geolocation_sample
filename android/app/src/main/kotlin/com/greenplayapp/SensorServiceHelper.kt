package com.greenplayapp

import android.app.ActivityManager
import android.content.Context
import android.content.Intent
import android.os.Build
import com.google.gson.Gson
import java.text.SimpleDateFormat
import java.util.*


const val GREEN_PLAY_SENSOR_LOGS = "green_play_sensor_logs"
const val GREEN_PLAY_SENSOR_PREFS = "green_play_sensor_prefs"
const val SETTING_AUTO_START_TRACKING = "auto_start_tracking"
const val SETTING_AUTO_START_TRACKING_LAST_ENABLED = "auto_start_tracking_last_enabled"


fun startSensorTracking(context: Context) {
    SensorService.shouldRestartService = true
    val running = isMyServiceRunning(SensorService::class.java, context)
    if (running) return
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
        RestartBroadcastReceiver.scheduleJob(context)
    } else {
        val serviceAdmin = ServiceAdmin()
        serviceAdmin.launchService(context)
    }
    saveAutoStartTracking(context, true)

}

fun stopSensorTracking(context: Context) {
    SensorService.shouldRestartService = false
    val running = isMyServiceRunning(SensorService::class.java, context)
    val stopIntent: Intent = Intent(
            context,
            SensorService::class.java
    )
    stopIntent.action = ACTION.STOPFOREGROUND_ACTION
    context.stopService(stopIntent)
    saveAutoStartTracking(context, false)

}

fun addSensorPoint(context: Context, log: SensorLog) {
    val prefs = context.getSharedPreferences(
            GREEN_PLAY_SENSOR_LOGS, Context.MODE_PRIVATE
    )
    val gson = Gson()
    val sensorString = gson.toJson(log, SensorLog::class.java)
    val editor = prefs.edit()
    editor.putString(log.uid, sensorString)
    editor.commit()
    val shallStopService = shallExpireSensorService(context)
    if(shallStopService){
        stopSensorTracking(context)
    }

}

fun getSensorLog(context: Context, logId: String?): SensorLog {
    val prefs = context.getSharedPreferences(
            GREEN_PLAY_SENSOR_LOGS, Context.MODE_PRIVATE
    )
    val logString = prefs.getString(logId, "")
    val gson = Gson()
    return gson.fromJson(logString, SensorLog::class.java)
}

fun getAllSensorPoint(context: Context): Map<String, *>? {
    val prefs = context.getSharedPreferences(
            GREEN_PLAY_SENSOR_LOGS, Context.MODE_PRIVATE
    )
    return prefs.all
}

fun clearSensorData(context: Context) {
    val prefs = context.getSharedPreferences(
            GREEN_PLAY_SENSOR_LOGS, Context.MODE_PRIVATE
    )
    val editor = prefs.edit()
    editor.clear()
    editor.apply()
}

fun removeSensorPoint(logId: String?, context: Context) {
    val prefs = context.getSharedPreferences(
            GREEN_PLAY_SENSOR_LOGS, Context.MODE_PRIVATE
    )
    val editor = prefs.edit()
    editor.remove(logId)
    editor.apply()
}

fun getAutoStartTracking(context: Context): Boolean {
    val prefs = context.getSharedPreferences(
            GREEN_PLAY_SENSOR_PREFS, Context.MODE_PRIVATE
    )
    return prefs.getBoolean(SETTING_AUTO_START_TRACKING, true)
}

fun getAutoStartTrackingLastEnabled(context: Context): Long {
    val prefs = context.getSharedPreferences(
            GREEN_PLAY_SENSOR_PREFS, Context.MODE_PRIVATE
    )
    return prefs.getLong(SETTING_AUTO_START_TRACKING_LAST_ENABLED, 0)
}

fun shallExpireSensorService(context: Context): Boolean {
    val lastEnabled = getAutoStartTrackingLastEnabled(context)
    val now = Calendar.getInstance().timeInMillis
    val diff = now - lastEnabled
    val msInFiveMinutes = 2 * 60 * 1000
    val shallStop = diff > msInFiveMinutes
    return shallStop;
}

private fun saveAutoStartTracking(context: Context, autoStart: Boolean) {
    val prefs = context.getSharedPreferences(
            GREEN_PLAY_SENSOR_PREFS, Context.MODE_PRIVATE
    )
    val editor = prefs.edit()
    editor.putBoolean(SETTING_AUTO_START_TRACKING, autoStart)
    if (autoStart) {
        val now = Calendar.getInstance();
        editor.putLong(SETTING_AUTO_START_TRACKING_LAST_ENABLED, now.timeInMillis)
    }
    editor.commit()
}

fun currentTimeISOString(): String {
    val df = SimpleDateFormat("yyyy-MM-dd'T'HH:mm", Locale.US)
    df.timeZone = TimeZone.getDefault()
    val now = Calendar.getInstance()
    val stringTillMinute = df.format(now.time)
    val flooredSecond = flooredFor10Seconds(now.get(Calendar.SECOND));
    return "$stringTillMinute:${getTwoDigitNumber(flooredSecond)}";
}

private fun flooredFor10Seconds(num: Int): Int {
    val second = if (num % 10 >= 5) (num - (num % 10) + 10) else (num - (num % 10))
    return second % 60;
}

private fun getTwoDigitNumber(number: Int): String {
    val prefix = if (number >= 10) "" else "0"
    return "$prefix$number"
}

fun isMyServiceRunning(serviceClass: Class<*>, context: Context): Boolean {
    val manager = context.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager?
    for (service in manager!!.getRunningServices(Int.MAX_VALUE)) {
        if (serviceClass.name == service.service.className) {
            return true
        }
    }
    return false
}


interface ACTION {
    companion object {
        const val MAIN_ACTION = "com.truiton.foregroundservice.action.main"
        const val PREV_ACTION = "com.truiton.foregroundservice.action.prev"
        const val PLAY_ACTION = "com.truiton.foregroundservice.action.play"
        const val NEXT_ACTION = "com.truiton.foregroundservice.action.next"
        const val STARTFOREGROUND_ACTION = "com.truiton.foregroundservice.action.startforeground"
        const val STOPFOREGROUND_ACTION = "com.truiton.foregroundservice.action.stopforeground"
    }
}