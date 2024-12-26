package com.example.magic_app_icon

import android.app.Service
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.IBinder
import android.util.Log
import android.content.SharedPreferences

class MagicIconService : Service() {
    private val tag = "MagicIconService"

    private lateinit var sharedPreferences: SharedPreferences

    override fun onCreate() {
        super.onCreate()
        sharedPreferences = getSharedPreferences("app_prefs", Context.MODE_PRIVATE)
    }

    override fun onBind(intent: Intent?): IBinder? {
        return null
    }

    override fun onTaskRemoved(rootIntent: Intent?) {
        super.onTaskRemoved(rootIntent)
        changeAppIcon()
    }

    override fun onDestroy() {
        super.onDestroy()
        changeAppIcon()
    }

    private fun changeAppIcon() {
        val iconName = sharedPreferences.getString("iconName", "MainActivity")
        if (iconName != null) {
            val packageManager = packageManager
            val packageName = packageName
            val aliases = listOf(
                "MainActivity",
                "Red",
                "Purple",
            )

            aliases.forEach { alias ->
                val componentName = ComponentName(packageName, "$packageName.$alias")
                val state = if (alias == iconName) {
                    PackageManager.COMPONENT_ENABLED_STATE_ENABLED
                } else {
                    PackageManager.COMPONENT_ENABLED_STATE_DISABLED
                }
                packageManager.setComponentEnabledSetting(
                    componentName,
                    state,
                    PackageManager.DONT_KILL_APP
                )
                Log.i(tag, "Component $alias set to ${if (state == PackageManager.COMPONENT_ENABLED_STATE_ENABLED) "enabled" else "disabled"}")
            }
        }
    }
}
