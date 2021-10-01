package com.greenplayapp

import com.google.gson.annotations.SerializedName

data class SensorLog(
    @SerializedName("uid") var uid: String,
    @SerializedName("accelerometer") var accelerometer: SensorModel,
    @SerializedName("magnetometer") var gyro: SensorModel
)