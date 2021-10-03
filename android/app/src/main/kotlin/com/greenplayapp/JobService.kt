package com.greenplayapp

import android.app.PendingIntent
import android.app.job.JobParameters
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.util.Log
import androidx.annotation.RequiresApi
import androidx.localbroadcastmanager.content.LocalBroadcastManager
import com.google.android.gms.location.*


@RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
class JobService : android.app.job.JobService() {
    override fun onStartJob(jobParameters: JobParameters): Boolean {
        //I think we should listen to activity recognition/activity changed listener here and
        // Only fire the Service when significant movement is received and cancel service when activity
        // Recognition says the app has stopped moving.
        val serviceAdmin = ServiceAdmin()
        serviceAdmin.launchService(this)
        // instance = this
        // Companion.jobParameters = jobParameters


        //I think we should make it true, so that it will fire in relative fast successions
        // but only display the service when significant motion callback is received
        return false
    }

    override fun onStopJob(jobParameters: JobParameters): Boolean {
        Log.i(TAG, "Stopping job")
        val broadcastIntent: Intent = Intent(RESTART_INTENT)
        sendBroadcast(broadcastIntent)
        RestartBroadcastReceiver.scheduleJob(this)
        // give the time to run
        Handler().postDelayed({ unregisterReceiver(restartBroadcastReceiver) }, 1000)
        return false
    }

    companion object {
        private const val TAG = "JobService"
        private var restartBroadcastReceiver: RestartBroadcastReceiver? = null

        /**
         * called when the tracker is stopped for whatever reason
         * @param context
         */

    }
}

class DetectedActivityReceiver : BroadcastReceiver() {

    companion object {
        val RECEIVER_ACTION = BuildConfig.APPLICATION_ID + ".DetectedActivityReceiver"

    }

    override fun onReceive(context: Context?, intent: Intent) {
        Log.d("ActivityRecognition", "Received a generic intent.")


        if (RECEIVER_ACTION != intent.action) {
            Log.d("ActivityRecognition", "Received an unsupported action.")
            return
        }
        Log.d("ActivityRecognition", "Received a valid intent.")

        if (ActivityTransitionResult.hasResult(intent)) {
            val result = ActivityTransitionResult.extractResult(intent)
            for (event in result!!.transitionEvents) {
            }
        }
    }
}

fun registerActivityTransitionBroadcastListener(context: Context) {
    val transitionsList = mutableListOf<ActivityTransition>()

    //Add still listener
    transitionsList.add(
            ActivityTransition.Builder()
                    .setActivityType(DetectedActivity.STILL)
                    .setActivityTransition(ActivityTransition.ACTIVITY_TRANSITION_ENTER)
                    .build()
    )

    //Add walk listener
    transitionsList.add(
            ActivityTransition.Builder()
                    .setActivityType(DetectedActivity.WALKING)
                    .setActivityTransition(ActivityTransition.ACTIVITY_TRANSITION_ENTER)
                    .build()
    )


    //Add Running listener
    transitionsList.add(
            ActivityTransition.Builder()
                    .setActivityType(DetectedActivity.RUNNING)
                    .setActivityTransition(ActivityTransition.ACTIVITY_TRANSITION_ENTER)
                    .build()
    )

    //Add on foot listener
    transitionsList.add(
            ActivityTransition.Builder()
                    .setActivityType(DetectedActivity.ON_FOOT)
                    .setActivityTransition(ActivityTransition.ACTIVITY_TRANSITION_ENTER)
                    .build()
    )


    //Add bicycle listener
    transitionsList.add(
            ActivityTransition.Builder()
                    .setActivityType(DetectedActivity.ON_BICYCLE)
                    .setActivityTransition(ActivityTransition.ACTIVITY_TRANSITION_ENTER)
                    .build()
    )


    //Add vehicle listener
    transitionsList.add(
            ActivityTransition.Builder()
                    .setActivityType(DetectedActivity.IN_VEHICLE)
                    .setActivityTransition(ActivityTransition.ACTIVITY_TRANSITION_ENTER)
                    .build()
    )


    val finalRequest = ActivityTransitionRequest(transitionsList)


    val intent = Intent(DetectedActivityReceiver.RECEIVER_ACTION)
    val pendingIntent = PendingIntent.getBroadcast(context, 0, intent, 0)

    // creating the receiver
    val receiver = DetectedActivityReceiver()

    // registering the receiver
    LocalBroadcastManager.getInstance(context).registerReceiver(
            receiver, IntentFilter(DetectedActivityReceiver.RECEIVER_ACTION)
    )

    val task = ActivityRecognition.getClient(context)
            .requestActivityTransitionUpdates(finalRequest, pendingIntent)

    task.addOnSuccessListener {
        Log.d("ActivityRecognition", "Transitions Api registered with success")
    }

    task.addOnFailureListener { e: Exception ->
        Log.d(
                "ActivityRecognition",
                "Transitions Api could NOT be registered ${e.localizedMessage}"
        )
    }
}