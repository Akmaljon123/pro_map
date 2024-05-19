package com.example.pro_map

import android.app.Application
import com.yandex.mapkit.MapKitFactory;
import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugins.GeneratedPluginRegistrant


class MainActivity: FlutterActivity(){
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        MapKitFactory.setApiKey("00ff7c21-27ad-4bf9-b0a4-bdbd9a4df408")
        super.configureFlutterEngine(flutterEngine)
    }
}

