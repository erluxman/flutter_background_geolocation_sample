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

    private fun registerActivityTransitionBroadcastListener() {
        val transitionsList = mutableListOf<ActivityTransition>()

        //Add still listener
        transitionsList.add(
            ActivityTransition.Builder()
                .setActivityType(DetectedActivity.STILL)
                .setActivityTransition(ActivityTransition.ACTIVITY_TRANSITION_ENTER)
                .build()
        )
        transitionsList.add(
            ActivityTransition.Builder()
                .setActivityType(DetectedActivity.STILL)
                .setActivityTransition(ActivityTransition.ACTIVITY_TRANSITION_EXIT)
                .build()
        )


        //Add walk listener
        transitionsList.add(
            ActivityTransition.Builder()
                .setActivityType(DetectedActivity.WALKING)
                .setActivityTransition(ActivityTransition.ACTIVITY_TRANSITION_ENTER)
                .build()
        )
        transitionsList.add(
            ActivityTransition.Builder()
                .setActivityType(DetectedActivity.WALKING)
                .setActivityTransition(ActivityTransition.ACTIVITY_TRANSITION_EXIT)
                .build()
        )


        //Add Running listener
        transitionsList.add(
            ActivityTransition.Builder()
                .setActivityType(DetectedActivity.RUNNING)
                .setActivityTransition(ActivityTransition.ACTIVITY_TRANSITION_ENTER)
                .build()
        )
        transitionsList.add(
            ActivityTransition.Builder()
                .setActivityType(DetectedActivity.RUNNING)
                .setActivityTransition(ActivityTransition.ACTIVITY_TRANSITION_EXIT)
                .build()
        )


        //Add on foot listener
        transitionsList.add(
            ActivityTransition.Builder()
                .setActivityType(DetectedActivity.ON_FOOT)
                .setActivityTransition(ActivityTransition.ACTIVITY_TRANSITION_ENTER)
                .build()
        )
        transitionsList.add(
            ActivityTransition.Builder()
                .setActivityType(DetectedActivity.ON_FOOT)
                .setActivityTransition(ActivityTransition.ACTIVITY_TRANSITION_EXIT)
                .build()
        )

        //Add bicycle listener
        transitionsList.add(
            ActivityTransition.Builder()
                .setActivityType(DetectedActivity.ON_BICYCLE)
                .setActivityTransition(ActivityTransition.ACTIVITY_TRANSITION_ENTER)
                .build()
        )
        transitionsList.add(
            ActivityTransition.Builder()
                .setActivityType(DetectedActivity.ON_BICYCLE)
                .setActivityTransition(ActivityTransition.ACTIVITY_TRANSITION_EXIT)
                .build()
        )


        //Add vehicle listener
        transitionsList.add(
            ActivityTransition.Builder()
                .setActivityType(DetectedActivity.IN_VEHICLE)
                .setActivityTransition(ActivityTransition.ACTIVITY_TRANSITION_ENTER)
                .build()
        )
        transitionsList.add(
            ActivityTransition.Builder()
                .setActivityType(DetectedActivity.IN_VEHICLE)
                .setActivityTransition(ActivityTransition.ACTIVITY_TRANSITION_EXIT)
                .build()
        )


        val finalRequest = ActivityTransitionRequest(transitionsList)


//        val intent = Intent(DetectedActivityReceiver.RECEIVER_ACTION)
//        val pendingIntent = PendingIntent.getBroadcast(this, 0, intent, 0)
//
//        // creating the receiver
//        val receiver = DetectedActivityReceiver()
//
//        // registering the receiver
//        LocalBroadcastManager.getInstance(this).registerReceiver(
//            receiver, IntentFilter(DetectedActivityReceiver.RECEIVER_ACTION)
//        )

//        val task = ActivityRecognition.getClient(this)
//            .requestActivityTransitionUpdates(finalRequest, pendingIntent)

//        task.addOnSuccessListener {
//            Log.d("ActivityRecognition", "Transitions Api registered with success")
//        }
//
//        task.addOnFailureListener { e: Exception ->
//            Log.d(
//                "ActivityRecognition",
//                "Transitions Api could NOT be registered ${e.localizedMessage}"
//            )
//        }
    }

    private fun registerRestarterReceiver() {

        // the context can be null if app just installed and this is called from restartsensorservice
        // https://stackoverflow.com/questions/24934260/intentreceiver-components-are-not-allowed-to-register-to-receive-intents-when
        // Final decision: in case it is called from installation of new version (i.e. from manifest, the application is
        // null. So we must use context.registerReceiver. Otherwise this will crash and we try with context.getApplicationContext
        if (restartBroadcastReceiver == null) restartBroadcastReceiver =
            RestartBroadcastReceiver() else try {
            unregisterReceiver(restartBroadcastReceiver)
        } catch (e: Exception) {
            // not registered
        }
        //give the time to run
        Handler(Looper.getMainLooper()).postDelayed({
            val filter = IntentFilter()
            filter.addAction(RESTART_INTENT)
            try {
                registerReceiver(restartBroadcastReceiver, filter)
            } catch (e: Exception) {
                try {
                    applicationContext.registerReceiver(restartBroadcastReceiver, filter)
                } catch (ex: Exception) {
                }
            }
        }, 1000)
    }

    override fun onStopJob(jobParameters: JobParameters): Boolean {
        Log.i(TAG, "Stopping job")
        val broadcastIntent: Intent = Intent(RESTART_INTENT)
        sendBroadcast(broadcastIntent)
        // give the time to run
        Handler().postDelayed({ unregisterReceiver(restartBroadcastReceiver) }, 1000)
        return false
    }

    companion object {
        private const val TAG = "JobService"
        private var restartBroadcastReceiver: RestartBroadcastReceiver? = null
        private var instance: JobService? = null
        private var jobParameters: JobParameters? = null

        /**
         * called when the tracker is stopped for whatever reason
         * @param context
         */
        fun stopJob(context: Context?) {
            if (instance != null && jobParameters != null) {
                try {
                    instance!!.unregisterReceiver(restartBroadcastReceiver)
                } catch (e: Exception) {
                    // not registered
                }
                Log.i(TAG, "Finishing job")
                instance!!.jobFinished(jobParameters, true)
            }
        }
    }
}

//class DetectedActivityReceiver : BroadcastReceiver() {
//
//    companion object {
//        val RECEIVER_ACTION = BuildConfig.APPLICATION_ID + ".DetectedActivityReceiver"
//
//    }
//
//    override fun onReceive(context: Context?, intent: Intent) {
//        Log.d("ActivityRecognition", "Received a generic intent.")
//
//
//        if (RECEIVER_ACTION != intent.action) {
//            Log.d("ActivityRecognition", "Received an unsupported action.")
//            return
//        }
//        Log.d("ActivityRecognition", "Received a valid intent.")
//
//        if (ActivityTransitionResult.hasResult(intent)) {
//            val result = ActivityTransitionResult.extractResult(intent)
//            for (event in result!!.transitionEvents) {
//                val serviceAdmin = ServiceAdmin()
//
//                if (ActivityTransition.ACTIVITY_TRANSITION_ENTER == event.transitionType) {
//                    serviceAdmin.launchService(context)
//                } else {
//                    serviceAdmin.stopService(context)
//                }
//            }
//        }
//    }

//    private fun transitionType(transitionType: Int): String {
//        return when (transitionType) {
//            ActivityTransition.ACTIVITY_TRANSITION_ENTER -> "ENTER"
//            ActivityTransition.ACTIVITY_TRANSITION_EXIT -> "EXIT"
//            else -> "UNKNOWN"
//        }
//    }
//
//    private fun activityType(activity: Int): String {
//        return when (activity) {
//            DetectedActivity.IN_VEHICLE -> "IN_VEHICLE"
//            DetectedActivity.STILL -> "STILL"
//            DetectedActivity.WALKING -> "WALKING"
//            else -> "UNKNOWN"
//        }
//    }
//}