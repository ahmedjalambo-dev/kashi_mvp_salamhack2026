package com.example.kashi_mvp_salamhack2026

import android.os.Bundle
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Prevent the QR code screen from appearing in screenshots or the
        // Android task-switcher thumbnail (blocks bearer-token leakage).
        window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
    }
}
