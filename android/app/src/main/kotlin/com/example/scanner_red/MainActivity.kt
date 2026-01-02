package com.example.scanner_red

import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.scanner_red/android_tools"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->
            if (call.method == "getAppName") {
                val uid = call.argument<Int>("uid")
                if (uid != null) {
                    val name = getAppNameFromUid(uid)
                    result.success(name)
                } else {
                    result.error("INVALID_UID", "UID is null", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun getAppNameFromUid(uid: Int): String {
        val pm = context.packageManager
        try {
            val packageName = pm.getNameForUid(uid)
            if (packageName != null) {
                val appInfo = pm.getApplicationInfo(packageName, 0)
                return pm.getApplicationLabel(appInfo).toString()
            }
        } catch (e: Exception) {
            // Ignore
        }
        return "UID:$uid"
    }
}
