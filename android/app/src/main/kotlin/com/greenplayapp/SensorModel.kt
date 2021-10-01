package com.greenplayapp

import com.google.gson.annotations.SerializedName

data class SensorModel(
    @SerializedName("x") val x: Float,
    @SerializedName("y") val y: Float,
    @SerializedName("z") val z: Float
)