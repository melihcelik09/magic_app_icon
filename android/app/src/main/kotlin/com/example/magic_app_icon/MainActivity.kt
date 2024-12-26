package com.example.magic_app_icon

import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channel = "dynamic_icon_changer"
    private val tag = "MainActivity"

    private lateinit var sharedPreferences: SharedPreferences

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        sharedPreferences = getSharedPreferences("app_prefs", Context.MODE_PRIVATE)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channel).setMethodCallHandler { call, result ->
            when (call.method) {
                "updateIcon" -> {
                    val iconName = call.argument<String>("iconName")
                    if (iconName != null) {
                        try {
                            // iconName'ı SharedPreferences'e kaydediyoruz
                            sharedPreferences.edit().putString("iconName", iconName).apply()
                            result.success(true)
                            Log.i(tag, "Icon update triggered")

                            // Servisi başlatıyoruz
                            val intent = Intent(this, MagicIconService::class.java)
                            startService(intent)
                        } catch (e: Exception) {
                            result.error("ICON_UPDATE_FAILED", e.message, null)
                            Log.e(tag, "Icon update failed: ${e.message}")
                        }
                    } else {
                        result.error("INVALID_ARGUMENT", "iconName is required", null)
                        Log.e(tag, "iconName is required")
                    }
                }
                else -> result.notImplemented()
            }
        }
    }
}
