package com.greenplayapp

import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log


class ServiceAdmin {
    private fun setServiceIntent(context: Context) {
        if (serviceIntent == null) {
            serviceIntent = Intent(context, SensorService::class.java)
        }
    }

    fun launchService(context: Context?) {
        val forceStart = !shallExpireSensorService(context!!)
        if (context == null) {
            return
        }
        val shallStartService = getAutoStartTracking(context) || forceStart
        if (!shallStartService) {
            return
        }

        val running = isMyServiceRunning(SensorService::class.java, context)
        if (running) return
        setServiceIntent(context)

        // depending on the version of Android we either launch the simple service (version<O)
        // or we start a foreground service
        if (Build.VERSION.SDK_INT >= 26) {
            context.startForegroundService(serviceIntent)
        } else {
            context.startService(serviceIntent)
        }
        Log.d(TAG, "launchService:  Service is starting....")
    }

    fun stopService(context: Context?) {
        if (context == null) {
            return
        }
        setServiceIntent(context)
        try {
            context.stopService(
                    serviceIntent
            )
        } catch (ex: Exception) {
            Log.e("greenplay onServiceStop", "Service manager can't stop service $ex")
        }
    }

    companion object {
        private const val TAG = "ServiceAdmin"
        private var serviceIntent: Intent? = null
    }
}
