package com.larapapa.timetable

import io.flutter.embedding.android.FlutterActivity
import androidx.activity.enableEdgeToEdge

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: android.os.Bundle?) {
        enableEdgeToEdge()
        super.onCreate(savedInstanceState)
    }
}