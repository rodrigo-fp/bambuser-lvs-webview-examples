package com.example.bambuserwebview

import java.text.SimpleDateFormat
import java.util.*

fun String.toDate() : Date? {
    val format = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", Locale.US)
    return try {
        format.parse(this)
    } catch (e: Exception) {
        e.printStackTrace()
        null
    }
}