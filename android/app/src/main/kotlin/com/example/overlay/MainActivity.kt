package com.example.overlay

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.PixelFormat
import android.hardware.display.DisplayManager
import android.hardware.display.VirtualDisplay
import android.media.ImageReader
import android.media.projection.MediaProjection
import android.media.projection.MediaProjectionManager
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.provider.Settings
import android.util.DisplayMetrics
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.*
import java.io.File
import java.io.FileOutputStream

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.overlay/screenshot"
    private val REQUEST_CODE_SCREEN_CAPTURE = 1001
    private var mediaProjectionManager: MediaProjectionManager? = null
    private var mediaProjection: MediaProjection? = null
    private var virtualDisplay: VirtualDisplay? = null
    private var imageReader: ImageReader? = null
    private var screenshotResult: MethodChannel.Result? = null

    private val mediaProjectionCallback = object : MediaProjection.Callback() {
        override fun onStop() {
            Log.d("MainActivity", "MediaProjection stopped")
            mediaProjection?.unregisterCallback(this)
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        mediaProjectionManager = getSystemService(Context.MEDIA_PROJECTION_SERVICE) as MediaProjectionManager

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "requestPermission" -> {
                    requestScreenCapturePermission(result)
                }
                "takeScreenshot" -> {
                    if (mediaProjection == null) {
                        result.error("NO_PERMISSION", "Screen capture permission not granted", null)
                    } else {
                        captureScreen(result)
                    }
                }
                "hasPermission" -> {
                    result.success(mediaProjection != null)
                }
                "stopCapture" -> {
                    stopScreenCapture()
                    result.success(null)
                }
                "checkAccessibilityPermission" -> {
                    result.success(isAccessibilityServiceEnabled())
                }
                "requestAccessibilityPermission" -> {
                    openAccessibilitySettings()
                    result.success(null)
                }
                "startAutoScroll" -> {
                    startAutoScrollWithScreenshots(result)
                }
                "stopAutoScroll" -> {
                    AutoScrollService.getInstance()?.stopAutoScroll()
                    result.success(null)
                }
                "moveToBackground" -> {
                    moveTaskToBack(true)
                    result.success(null)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun requestScreenCapturePermission(result: MethodChannel.Result) {
        screenshotResult = result
        val intent = mediaProjectionManager?.createScreenCaptureIntent()
        startActivityForResult(intent, REQUEST_CODE_SCREEN_CAPTURE)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)

        if (requestCode == REQUEST_CODE_SCREEN_CAPTURE) {
            if (resultCode == Activity.RESULT_OK && data != null) {
                // Foreground Service 시작
                val serviceIntent = Intent(this, ScreenCaptureService::class.java)
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    startForegroundService(serviceIntent)
                } else {
                    startService(serviceIntent)
                }

                // Service가 완전히 시작될 때까지 대기 후 MediaProjection 시작
                Handler(Looper.getMainLooper()).postDelayed({
                    try {
                        mediaProjection = mediaProjectionManager?.getMediaProjection(resultCode, data)
                        mediaProjection?.registerCallback(mediaProjectionCallback, null)
                        screenshotResult?.success(true)
                    } catch (e: Exception) {
                        Log.e("MainActivity", "MediaProjection error: ${e.message}")
                        screenshotResult?.success(false)
                    }
                    screenshotResult = null
                }, 500)
            } else {
                screenshotResult?.success(false)
                screenshotResult = null
            }
        }
    }

    private fun captureScreen(result: MethodChannel.Result) {
        captureScreenInternal { path ->
            if (path != null) {
                result.success(path)
            } else {
                result.error("CAPTURE_FAILED", "Failed to capture screen", null)
            }
        }
    }

    private fun captureScreenInternal(callback: (String?) -> Unit) {
        try {
            // VirtualDisplay가 없으면 한 번만 생성
            if (virtualDisplay == null || imageReader == null) {
                val metrics = DisplayMetrics()
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                    display?.getRealMetrics(metrics)
                } else {
                    @Suppress("DEPRECATION")
                    windowManager.defaultDisplay.getRealMetrics(metrics)
                }

                val width = metrics.widthPixels
                val height = metrics.heightPixels
                val density = metrics.densityDpi

                imageReader = ImageReader.newInstance(width, height, PixelFormat.RGBA_8888, 2)
                virtualDisplay = mediaProjection?.createVirtualDisplay(
                    "ScreenCapture",
                    width, height, density,
                    DisplayManager.VIRTUAL_DISPLAY_FLAG_AUTO_MIRROR,
                    imageReader?.surface, null, null
                )
                Log.d("Screenshot", "Created new VirtualDisplay")
            }

            Handler(Looper.getMainLooper()).postDelayed({
                try {
                    val image = imageReader?.acquireLatestImage()
                    if (image != null) {
                        val planes = image.planes
                        val buffer = planes[0].buffer
                        val pixelStride = planes[0].pixelStride
                        val rowStride = planes[0].rowStride
                        val width = imageReader!!.width
                        val rowPadding = rowStride - pixelStride * width

                        val bitmap = Bitmap.createBitmap(
                            width + rowPadding / pixelStride,
                            imageReader!!.height,
                            Bitmap.Config.ARGB_8888
                        )
                        bitmap.copyPixelsFromBuffer(buffer)
                        image.close()

                        // Save bitmap to file
                        val filename = "screenshot_${System.currentTimeMillis()}.png"
                        val file = File(getExternalFilesDir(null), filename)
                        val outputStream = FileOutputStream(file)
                        bitmap.compress(Bitmap.CompressFormat.PNG, 100, outputStream)
                        outputStream.flush()
                        outputStream.close()
                        bitmap.recycle()

                        callback(file.absolutePath)
                        Log.d("Screenshot", "Saved to: ${file.absolutePath}")
                    } else {
                        Log.e("Screenshot", "acquireLatestImage returned null")
                        callback(null)
                    }
                } catch (e: Exception) {
                    Log.e("Screenshot", "Error: ${e.message}")
                    callback(null)
                }
            }, 300)
        } catch (e: Exception) {
            Log.e("Screenshot", "Setup error: ${e.message}")
            callback(null)
        }
    }

    private fun stopScreenCapture() {
        virtualDisplay?.release()
        imageReader?.close()
        mediaProjection?.unregisterCallback(mediaProjectionCallback)
        mediaProjection?.stop()
        mediaProjection = null

        // Foreground Service 중지
        val serviceIntent = Intent(this, ScreenCaptureService::class.java)
        stopService(serviceIntent)
    }

    private fun isAccessibilityServiceEnabled(): Boolean {
        val service = "${packageName}/${AutoScrollService::class.java.canonicalName}"
        val enabledServices = Settings.Secure.getString(
            contentResolver,
            Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES
        )
        return enabledServices?.contains(service) == true
    }

    private fun openAccessibilitySettings() {
        val intent = Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS)
        intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
        startActivity(intent)
    }

    private fun startAutoScrollWithScreenshots(result: MethodChannel.Result) {
        Log.d("MainActivity", "=== startAutoScrollWithScreenshots called ===")

        if (mediaProjection == null) {
            Log.e("MainActivity", "MediaProjection is null!")
            result.error("NO_PERMISSION", "Screen capture permission not granted", null)
            return
        }

        Log.d("MainActivity", "MediaProjection is ready")

        val service = AutoScrollService.getInstance()
        Log.d("MainActivity", "AutoScrollService instance: $service")

        // Accessibility Service가 있으면 자동 스크롤 + 스크린샷
        if (service != null) {
            Log.d("MainActivity", "Starting auto scroll with accessibility service")

            // 스크린샷 콜백
            val screenshotCallback: suspend () -> String? = {
                suspendCancellableCoroutine { continuation ->
                    captureScreenInternal { path ->
                        Log.d("MainActivity", "Screenshot captured: $path")
                        continuation.resume(path) {}
                    }
                }
            }

            // 완료 콜백
            val completeCallback: (List<String>) -> Unit = { paths ->
                Log.d("MainActivity", "Auto scroll completed with ${paths.size} screenshots")
                Handler(Looper.getMainLooper()).post {
                    result.success(paths)
                }
            }

            service.startAutoScroll(screenshotCallback, completeCallback)
        } else {
            // Accessibility Service 없으면 스크린샷만 찍음
            Log.d("MainActivity", "Taking single screenshot (no accessibility service)")
            captureScreenInternal { path ->
                Handler(Looper.getMainLooper()).post {
                    if (path != null) {
                        result.success(listOf(path))
                    } else {
                        result.success(emptyList<String>())
                    }
                }
            }
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        stopScreenCapture()
    }
}
