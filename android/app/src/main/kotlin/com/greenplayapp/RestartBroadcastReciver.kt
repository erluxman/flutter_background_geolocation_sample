package com.greenplayapp

import android.app.job.JobInfo
import android.app.job.JobScheduler
import android.content.*
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.util.Log
import androidx.annotation.RequiresApi


class RestartBroadcastReceiver : BroadcastReceiver() {
    private var restartBroadcastReceiver: RestartBroadcastReceiver? = null
    override fun onReceive(context: Context, intent: Intent) {
        Log.i(
            RestartBroadcastReceiver::class.java.simpleName,
            "Service Stopped, but this is a never ending service."
        )
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            scheduleJob(context)
        } else {
            registerRestarterReceiver(context)
            val bck = ServiceAdmin()
            bck.launchService(context)
        }
    }

    private fun registerRestarterReceiver(context: Context) {

        // the context can be null if app just installed and this is called from restartsensorservice
        // https://stackoverflow.com/questions/24934260/intentreceiver-components-are-not-allowed-to-register-to-receive-intents-when
        // Final decision: in case it is called from installation of new version (i.e. from manifest, the application is
        // null. So we must use context.registerReceiver. Otherwise this will crash and we try with context.getApplicationContext
        if (restartBroadcastReceiver == null) restartBroadcastReceiver =
            RestartBroadcastReceiver() else try {
            context.unregisterReceiver(restartBroadcastReceiver)
        } catch (e: Exception) {
            // not registered
        }
        // give the time to run
        Handler(Looper.getMainLooper()).postDelayed({
            // see onDestroy of Service
            val filter = IntentFilter()
            filter.addAction(RESTART_INTENT)
            try {
                context.registerReceiver(restartBroadcastReceiver, filter)
            } catch (e: Exception) {
                try {
                    context.applicationContext.registerReceiver(restartBroadcastReceiver, filter)
                } catch (ex: Exception) {
                }
            }
        }, 1000)
    }

    companion object {
        private const val TAG = "RestartBroadcastReceive"
        private var jobScheduler: JobScheduler? = null

        @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
        fun scheduleJob(context: Context) {
            if (jobScheduler == null) {
                jobScheduler = context
                    .getSystemService(Context.JOB_SCHEDULER_SERVICE) as JobScheduler
            }
            val componentName = ComponentName(context, JobService::class.java)
            val jobInfo = JobInfo.Builder(
                1,
                componentName
            )   // setOverrideDeadline runs it immediately - you must have at least one constraint
                // https://stackoverflow.com/questions/51064731/firing-jobservice-without-constraints
                .setPeriodic(15 * 60 * 1000L)
                .setPersisted(true).build()
            jobScheduler?.schedule(jobInfo)
        }

        fun reStartTracker(context: Context) {
            // restart the never ending service
            Log.i(TAG, "Restarting tracker")
            val broadcastIntent: Intent = Intent(RESTART_INTENT)
            context.sendBroadcast(broadcastIntent)
        }
    }
}

const val RESTART_INTENT = "com.gahlot.neverendingservice"
