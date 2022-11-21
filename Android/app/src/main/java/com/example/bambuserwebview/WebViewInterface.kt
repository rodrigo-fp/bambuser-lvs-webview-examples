package com.example.bambuserwebview

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.provider.CalendarContract
import android.util.Log
import android.webkit.JavascriptInterface
import android.widget.Toast
import org.json.JSONObject
import java.text.SimpleDateFormat
import java.util.*

/** Instantiate the interface and set the context  */
class WebViewInterface(private val context: Context, private val activity: Activity) {

    /** Show a toast from the web page  */
    @JavascriptInterface
    fun showToast(toast: String) {
        Toast.makeText(context, toast, Toast.LENGTH_LONG).show()
    }

    @JavascriptInterface
    fun handleClose() {
        activity.finish();
    }

    @JavascriptInterface
    fun getCurrentCurrency(): String {
        return "USD";
    }

    @JavascriptInterface
    fun getCurrentLocale(): String {
        return "en-US";
    }

    @JavascriptInterface
    fun addToCalendar(json: String) {
        try {
            JSONObject(json).let {
                AddToCalendarEvent(
                    title = it.optString("title"),
                    description = it.optString("description"),
                    start = it.optString("start").toDate(),
                    duration = it.optLong("duration"),
                    url = it.optString("url")
                )
            }.let {
                val intent = Intent(Intent.ACTION_EDIT)
                intent.type = "vnd.android.cursor.item/event"
                intent.putExtra(CalendarContract.Events.TITLE, it.title)
                intent.putExtra(CalendarContract.Events.DESCRIPTION, it.description)
                intent.putExtra(CalendarContract.EXTRA_EVENT_BEGIN_TIME, it.start?.time)
                intent.putExtra(CalendarContract.EXTRA_EVENT_END_TIME, ((it.start?.time ?: 0L) + it.duration))
                intent.putExtra(CalendarContract.EXTRA_EVENT_ALL_DAY, false)
                context.startActivity(intent)
            }
        } catch (e: Exception) {
            Toast.makeText(context, "Could not add event to calendar", Toast.LENGTH_LONG).show()
        }
    }

    @JavascriptInterface
    fun share(json: String) {
        try {
            ShareEvent(
                JSONObject(json).optString("url")
            ).let {
                val shareIntent = Intent(Intent.ACTION_SEND)
                    .apply { type = "text/plain" }
                    .also { intent ->
                        intent.putExtra(
                            Intent.EXTRA_TEXT,
                            it.url
                        )
                    }
                context.startActivity(Intent.createChooser(shareIntent, "Insert your title here!"))
            }
        } catch (e: Exception) {
            Toast.makeText(context, "Could not perform sharing", Toast.LENGTH_LONG).show()
        }
    }
}