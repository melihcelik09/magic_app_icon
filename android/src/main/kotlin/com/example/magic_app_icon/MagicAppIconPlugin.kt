package com.example.magic_app_icon

import android.content.ComponentName
import android.content.pm.PackageManager
import android.util.Log
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class MagicAppIconPlugin: FlutterPlugin, MethodCallHandler {
  private lateinit var channel : MethodChannel
  private lateinit var packageManager: PackageManager
  private lateinit var packageName: String
  private val TAG = "MagicAppIcon"

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "magic_app_icon")
    channel.setMethodCallHandler(this)
    packageManager = flutterPluginBinding.applicationContext.packageManager
    packageName = flutterPluginBinding.applicationContext.packageName
    Log.d(TAG, "Plugin initialized with package: $packageName")
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    Log.d(TAG, "Method called: ${call.method}")
    when (call.method) {
      "changeIcon" -> {
        val iconName = call.argument<String>("iconName") ?: return result.error("INVALID_ARGUMENT", "Icon name is required", null)
        Log.d(TAG, "Changing icon to: $iconName")
        changeIcon(iconName, result)
      }
      "getCurrentIcon" -> {
        Log.d(TAG, "Getting current icon")
        getCurrentIcon(result)
      }
      else -> {
        Log.w(TAG, "Method not implemented: ${call.method}")
        result.notImplemented()
      }
    }
  }

  private fun changeIcon(iconName: String, result: Result) {
    try {
      // Disable all activity-aliases first
      Log.d(TAG, "Disabling all activity-aliases")
      packageManager.getPackageInfo(packageName, PackageManager.GET_ACTIVITIES)
        .activities
        ?.filter { it.name.startsWith(packageName) }
        ?.forEach { activityInfo ->
          val component = ComponentName(packageName, activityInfo.name)
          Log.d(TAG, "Disabling component: ${activityInfo.name}")
          packageManager.setComponentEnabledSetting(
            component,
            PackageManager.COMPONENT_ENABLED_STATE_DISABLED,
            PackageManager.DONT_KILL_APP
          )
        }

      // Enable the selected icon
      val componentName = when (iconName) {
        "default" -> ComponentName(packageName, "$packageName.MainActivity")
        else -> ComponentName(packageName, "$packageName.${iconName.toLowerCase()}")
      }
      Log.d(TAG, "Enabling component: ${componentName.className}")

      packageManager.setComponentEnabledSetting(
        componentName,
        PackageManager.COMPONENT_ENABLED_STATE_ENABLED,
        PackageManager.DONT_KILL_APP
      )

      result.success(true)
    } catch (e: Exception) {
      Log.e(TAG, "Error changing icon", e)
      result.error("ICON_CHANGE_FAILED", e.message, e.stackTraceToString())
    }
  }

  private fun getCurrentIcon(result: Result) {
    try {
      val mainComponent = ComponentName(packageName, "$packageName.MainActivity")
      Log.d(TAG, "Checking main component: ${mainComponent.className}")
      
      if (packageManager.getComponentEnabledSetting(mainComponent) == PackageManager.COMPONENT_ENABLED_STATE_ENABLED) {
        Log.d(TAG, "Default icon is active")
        return result.success("default")
      }

      Log.d(TAG, "Searching for active icon")
      val currentIcon = packageManager.getPackageInfo(packageName, PackageManager.GET_ACTIVITIES)
        .activities
        ?.filter { it.name.startsWith(packageName) }
        ?.also { Log.d(TAG, "Found ${it.size} activities: ${it.map { it.name }}") }
        ?.find { activityInfo ->
          val component = ComponentName(packageName, activityInfo.name)
          val isEnabled = packageManager.getComponentEnabledSetting(component) == PackageManager.COMPONENT_ENABLED_STATE_ENABLED
          Log.d(TAG, "Checking component ${activityInfo.name}: $isEnabled")
          isEnabled
        }
        ?.name
        ?.substringAfterLast(".")
        ?.toLowerCase() ?: "default"

      Log.d(TAG, "Current icon: $currentIcon")
      result.success(currentIcon)
    } catch (e: Exception) {
      Log.e(TAG, "Error getting current icon", e)
      result.error("GET_CURRENT_ICON_ERROR", e.message, e.stackTraceToString())
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    Log.d(TAG, "Plugin detached")
    channel.setMethodCallHandler(null)
  }
} 