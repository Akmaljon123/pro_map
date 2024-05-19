package com.example.pro_map

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import com.yandex.mapkit.MapKitFactory
import io.flutter.embedding.engine.FlutterEngine
import androidx.annotation.NonNull


class MainActivity: FlutterActivity(){
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        MapKitFactory.setApiKey("00ff7c21-27ad-4bf9-b0a4-bdbd9a4df408")
        super.configureFlutterEngine(flutterEngine)
    }
}

