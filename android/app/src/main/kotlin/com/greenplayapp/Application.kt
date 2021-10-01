package com.greenplayapp

import com.transistorsoft.locationmanager.adapter.BackgroundGeolocation
import io.flutter.app.FlutterApplication

class Application : FlutterApplication() {
    override fun onCreate() {
        super.onCreate()
        BackgroundGeolocation.getInstance(this).setBeforeInsertBlock { tsLocation ->
            val doInsert = true
            if (doInsert) tsLocation.toJson() else null
        }
    }
}