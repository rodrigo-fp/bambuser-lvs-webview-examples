package com.example.bambuserwebview

import java.util.*

data class AddToCalendarEvent(
    val description: String,
    val duration: Long,
    val start: Date?,
    val title: String,
    val url: String
)

data class ShareEvent(
    val url: String
)