package com.example.magic_app_icon

import android.content.ComponentName
import android.content.Context
import android.content.pm.PackageManager
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * Ana Activity sınıfı. Dinamik ikon değiştirme işlemlerini yönetir.
 */
class MainActivity : FlutterActivity() {
    companion object {
        // Flutter ile iletişim için kanal adı
        private const val CHANNEL = "dynamic_icon_changer"
        // Log mesajları için tag
        private const val TAG = "MagicAppIcon"
        // SharedPreferences için sabitler
        private const val PREFS_NAME = "IconPrefs"
        private const val PENDING_ICON_KEY = "pending_icon"
        private const val ERROR_COUNT_KEY = "error_count"
        // Maksimum hata deneme sayısı
        private const val MAX_ERROR_COUNT = 3

        // Hata mesajları için sabit tanımlamalar
        private val ERROR_MESSAGES = mapOf(
            "INVALID_ARGUMENT" to "İkon ismi boş olamaz",
            "INVALID_ICON" to "Geçersiz ikon ismi",
            "SAVE_ERROR" to "İkon değişim isteği kaydedilemedi",
            "MAX_RETRY" to "Maksimum deneme sayısına ulaşıldı"
        )

        // Kullanılabilir ikonların alias tanımlamaları
        private val iconAliases = mapOf(
            "default" to ".MainActivity",
            "red" to ".Red",
            "purple" to ".Purple"
        )
    }

    /**
     * Flutter engine yapılandırması ve method channel kurulumu
     */
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Method channel'ı oluştur ve method çağrılarını dinle
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "updateIcon" -> handleIconChange(call.argument("iconName"), result)
                    "getCurrentIcon" -> handleGetCurrentIcon(result)
                    else -> result.notImplemented()
                }
            }
    }

    /**
     * İkon değişim isteğini işler ve SharedPreferences'a kaydeder
     * @param iconName Değiştirilecek ikonun adı
     * @param result Flutter tarafına dönülecek sonuç
     */
    private fun handleIconChange(iconName: String?, result: MethodChannel.Result) {
        if (iconName == null) {
            handleError("INVALID_ARGUMENT", result)
            return
        }

        try {
            // İkon alias'ını kontrol et
            val alias = iconAliases[iconName] ?: run {
                handleError("INVALID_ICON", result, ": $iconName")
                return
            }

            // Hata sayısını kontrol et
            val prefs = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            val errorCount = prefs.getInt(ERROR_COUNT_KEY, 0)
            if (errorCount >= MAX_ERROR_COUNT) {
                handleError("MAX_RETRY", result)
                return
            }

            // İkon değişim isteğini kaydet
            prefs.edit().apply {
                putString(PENDING_ICON_KEY, iconName)
                putInt(ERROR_COUNT_KEY, 0) // Başarılı kayıt, hata sayısını sıfırla
                commit() // commit kullanıyoruz çünkü sonucun hemen kaydedilmesi önemli
            }

            result.success(true)
        } catch (e: Exception) {
            incrementErrorCount()
            handleError("SAVE_ERROR", result, ": ${e.localizedMessage}")
        }
    }

    /**
     * Hata sayacını bir artırır
     */
    private fun incrementErrorCount() {
        val prefs = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val currentCount = prefs.getInt(ERROR_COUNT_KEY, 0)
        prefs.edit().putInt(ERROR_COUNT_KEY, currentCount + 1).commit()
    }

    /**
     * Hata durumlarını yönetir ve Flutter tarafına hata mesajı döner
     */
    private fun handleError(errorCode: String, result: MethodChannel.Result, extra: String = "") {
        val message = ERROR_MESSAGES[errorCode] ?: "Bilinmeyen hata"
        Log.e(TAG, message + extra)
        result.error(errorCode, message + extra, null)
    }

    /**
     * Activity destroy edildiğinde bekleyen ikon değişimini gerçekleştirir
     */
    override fun onDestroy() {
        super.onDestroy()
        handlePendingIconChange()
    }

    /**
     * Bekleyen ikon değişim isteğini gerçekleştirir
     */
    private fun handlePendingIconChange() {
        val prefs = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val pendingIcon = prefs.getString(PENDING_ICON_KEY, null)

        if (pendingIcon != null) {
            try {
                val alias = iconAliases[pendingIcon] ?: return

                // Tüm activity alias'ları devre dışı bırak
                disableAllIcons()

                // Seçilen ikonu aktif et
                val componentName = ComponentName(packageName, packageName + alias)
                packageManager.setComponentEnabledSetting(
                    componentName,
                    PackageManager.COMPONENT_ENABLED_STATE_ENABLED,
                    PackageManager.DONT_KILL_APP
                )

                // İkon değişimi tamamlandı, isteği temizle
                prefs.edit().remove(PENDING_ICON_KEY).commit()
            } catch (e: Exception) {
                Log.e(TAG, "İkon değiştirme hatası: ${e.localizedMessage}")
                incrementErrorCount()
            }
        }
    }

    /**
     * Mevcut aktif ikonu getirir
     */
    private fun handleGetCurrentIcon(result: MethodChannel.Result) {
        try {
            val currentIcon = getCurrentIconName()
            result.success(currentIcon)
        } catch (e: Exception) {
            handleError("GET_ICON_ERROR", result, ": ${e.localizedMessage}")
        }
    }

    /**
     * Şu anda aktif olan ikonun adını bulur
     * @return Aktif ikonun adı, bulunamazsa "default"
     */
    private fun getCurrentIconName(): String {
        return iconAliases.entries.find { (_, alias) ->
            val componentName = ComponentName(packageName, packageName + alias)
            packageManager.getComponentEnabledSetting(componentName) == 
                PackageManager.COMPONENT_ENABLED_STATE_ENABLED
        }?.key ?: "default"
    }

    /**
     * Tüm activity alias'ları devre dışı bırakır
     */
    private fun disableAllIcons() {
        iconAliases.values.forEach { alias ->
            val componentName = ComponentName(packageName, packageName + alias)
            try {
                packageManager.setComponentEnabledSetting(
                    componentName,
                    PackageManager.COMPONENT_ENABLED_STATE_DISABLED,
                    PackageManager.DONT_KILL_APP
                )
            } catch (e: Exception) {
                Log.w(TAG, "İkon devre dışı bırakma hatası: $alias", e)
            }
        }
    }
}

