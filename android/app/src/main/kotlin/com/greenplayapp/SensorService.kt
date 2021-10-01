package com.greenplayapp

import android.app.Notification
import android.app.Notification.Builder
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Context
import android.content.Intent
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.os.Build
import android.os.IBinder
import android.util.Log
import java.util.*


internal class SensorService : Service() {
    private var accelerometerModel: SensorModel? = SensorModel(x = 0f, y = 0f, z = 0f)
    private var magnetoMeterModel: SensorModel? = SensorModel(x = 0f, y = 0f, z = 0f)
    private lateinit var sensorManager: SensorManager
    override fun onBind(intent: Intent): IBinder? {
        return null
    }


    override fun onCreate() {
        super.onCreate()
        startForeground()
    }

    private fun startForeground() {
        if (Build.VERSION.SDK_INT >= 26) {
            val CHANNEL_ID = "greenplay"
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Greenplay Tracking",
                NotificationManager.IMPORTANCE_LOW
            )
            (getSystemService(NOTIFICATION_SERVICE) as NotificationManager).createNotificationChannel(
                channel
            )
            val notification: Notification = Builder(this, CHANNEL_ID)
                .setContentTitle("Greenplay")
                .setSmallIcon(R.mipmap.ic_notification)
                .setBadgeIconType(R.mipmap.ic_notification)

                .setContentText("Collecting sensors").build()
            startForeground(9942586, notification)
            //startForeground(9942585, notification)
        }
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        super.onStartCommand(intent, flags, startId)
        startForeground()
        listenToSensors(this)
        return START_NOT_STICKY;
    }

    override fun onDestroy() {
        super.onDestroy()
        Log.i("service on destory", "onDestroy: Service is destroyed :( ")
        val broadcastIntent = Intent(
            this,
            RestartBroadcastReceiver::class.java
        )

        if (shouldRestartService) sendBroadcast(broadcastIntent)
        stopSensors()

    }

    //We need to share same notification for sensor data and location tracker so we need to learn to
    //Show only one notification with two services.
    //https://stackoverflow.com/questions/37880432/single-notification-for-multiple-foreground-services-using-startforeground-cal
    private fun listenToSensors(context: Context?) {
        sensorManager = getSystemService(SENSOR_SERVICE) as SensorManager
        val accelerometerSensor = sensorManager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER)
        val magnetoMeterSensor = sensorManager.getDefaultSensor(Sensor.TYPE_MAGNETIC_FIELD)

        sensorManager.registerListener(
            accSensor,
            accelerometerSensor,
            SensorManager.SENSOR_DELAY_NORMAL
        )

        sensorManager.registerListener(
            magSensor,
            magnetoMeterSensor,
            SensorManager.SENSOR_DELAY_NORMAL
        )

    }

    private fun stopSensors() {
        sensorManager.unregisterListener(accSensor)
        sensorManager.unregisterListener(magSensor)
        //Release sensor subscriptions when its stopped
    }

    private val accSensor = object : SensorEventListener {
        override fun onSensorChanged(event: SensorEvent) {
            val axisX = event.values[0]
            val axisY = event.values[1]
            val axisZ = event.values[2]
            accelerometerModel = SensorModel(axisX, axisY, axisZ)
            logSensorChange()
        }

        override fun onAccuracyChanged(sensor: Sensor, accuracy: Int) {}
    }
    private val magSensor = object : SensorEventListener {
        override fun onSensorChanged(event: SensorEvent) {
            val axisX = event.values[0]
            val axisY = event.values[1]
            val axisZ = event.values[2]
            magnetoMeterModel = SensorModel(axisX, axisY, axisZ)
            logSensorChange()
        }

        override fun onAccuracyChanged(sensor: Sensor, accuracy: Int) {}
    }

    fun logSensorChange() {
        val now = Calendar.getInstance()
        val currentMS = now.time.time
        val diff = currentMS - lastLoggedTS;
        if (diff < 4500) {
            return
        }
        val sensorLog = SensorLog(
            currentTimeISOString(), accelerometerModel!!, magnetoMeterModel!!
        )
        addSensorPoint(this, sensorLog)
        lastLoggedTS = currentMS
    }

    companion object {
        var shouldRestartService: Boolean = true
        var lastLoggedTS :Long = 0
    }
}
