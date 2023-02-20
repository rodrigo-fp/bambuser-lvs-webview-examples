package com.example.bambuserwebview

import androidx.appcompat.app.AppCompatActivity
import android.annotation.SuppressLint
import android.os.Bundle
import android.view.View
import android.view.WindowManager.LayoutParams.*
import android.webkit.WebView

/**
 * An example full-screen activity that hides the system UI (i.e.
 * status bar and navigation/system bar) with user interaction.
 */
class WebViewActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        if (BuildConfig.DEBUG) {
            //For the cases you wish to debug with Google Chrome
            WebView.setWebContentsDebuggingEnabled(true)
        }

        setContentView(R.layout.activity_webview)

        // Set up the user interaction to manually show or hide the system UI.
        webViewSetup()
    }

    @SuppressLint("SetJavaScriptEnabled")
    private fun webViewSetup() {
        val webView = findViewById<View>(R.id.webview) as WebView

        webView.apply {
            // Here are a list of URLs to a sample embed page on different player states
            // Uncomment one at a time to test different scenarios

            // 1. Recorded show
            // loadUrl("https://demo.bambuser.shop/content/webview-landing-v2.html")

            // 2. Live Show (fake live to test chat)
            loadUrl("https://demo.bambuser.shop/content/webview-landing-v2.html?mockLiveBambuser=true")

            // 3. Countdown screen / Scheduled show
            // loadUrl("https://demo.bambuser.shop/content/webview-landing-v2.html?eventId=2iduPdz2hn6UKd0eQmJq")

            settings.javaScriptEnabled = true
        }

        webView.addJavascriptInterface(WebViewInterface(this@WebViewActivity, this@WebViewActivity), "Android")

    }
}