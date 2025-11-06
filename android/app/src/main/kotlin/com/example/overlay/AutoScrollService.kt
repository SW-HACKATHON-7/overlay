package com.example.overlay

import android.accessibilityservice.AccessibilityService
import android.accessibilityservice.GestureDescription
import android.graphics.Path
import android.util.Log
import android.view.accessibility.AccessibilityEvent
import kotlinx.coroutines.*
import java.io.File

class AutoScrollService : AccessibilityService() {
    private var isScrolling = false
    private var scrollJob: Job? = null

    companion object {
        private const val TAG = "AutoScrollService"
        private var instance: AutoScrollService? = null

        fun getInstance(): AutoScrollService? = instance

        var onScrollCompleteCallback: ((List<String>) -> Unit)? = null
    }

    override fun onCreate() {
        super.onCreate()
        instance = this
        Log.d(TAG, "AutoScrollService created")
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        // 스크롤 이벤트 감지 가능
    }

    override fun onInterrupt() {
        stopAutoScroll()
    }

    override fun onDestroy() {
        super.onDestroy()
        instance = null
    }

    fun startAutoScroll(
        screenshotCallback: (suspend () -> String?)? = null,
        onComplete: ((List<String>) -> Unit)? = null
    ) {
        if (isScrolling) {
            Log.d(TAG, "Already scrolling")
            return
        }

        isScrolling = true
        val screenshots = mutableListOf<String>()

        scrollJob = CoroutineScope(Dispatchers.Main).launch {
            try {
                Log.d(TAG, "Starting auto scroll")

                // 최대 20번 스크롤 (무한 루프 방지)
                var shouldStop = false
                for (i in 0 until 20) {
                    // 스크롤이 중단되었는지 체크
                    if (!isScrolling || shouldStop) {
                        Log.d(TAG, "Auto scroll stopped by user or duplicate detection")
                        break
                    }

                    // 첫 번째가 아니면 스크롤 먼저 실행
                    if (i > 0) {
                        performScroll()
                        // 스크롤 후 충분히 대기 (화면 안정화 + 애니메이션 완료)
                        delay(3000)
                    }

                    // 다시 한번 체크 (delay 후)
                    if (!isScrolling) {
                        Log.d(TAG, "Auto scroll stopped during delay")
                        break
                    }

                    // 스크린샷 촬영
                    val path = screenshotCallback?.invoke()

                    // 스크린샷 저장 완료될 때까지 대기
                    delay(500)

                    if (path != null) {
                        // 마지막 스크린샷과만 비교 (화면 끝 감지)
                        var isDuplicate = false
                        if (screenshots.isNotEmpty()) {
                            val lastScreenshot = screenshots.last()
                            if (isSimilarImage(lastScreenshot, path)) {
                                Log.d(TAG, "Similar to previous screen detected. Reached end. Stopping.")
                                File(path).delete() // 중복 파일 삭제
                                isDuplicate = true
                                shouldStop = true
                            }
                        }

                        if (!isDuplicate) {
                            screenshots.add(path)
                            Log.d(TAG, "Screenshot $i saved: $path")
                        }
                    } else {
                        Log.d(TAG, "Screenshot $i: null")
                    }
                }

                Log.d(TAG, "Auto scroll completed. Total screenshots: ${screenshots.size}")

                // 완료 콜백
                val validPaths = screenshots.filterNotNull()
                onComplete?.invoke(validPaths)
                onScrollCompleteCallback?.invoke(validPaths)
            } catch (e: Exception) {
                Log.e(TAG, "Error during auto scroll: ${e.message}")
            } finally {
                isScrolling = false
            }
        }
    }

    fun stopAutoScroll() {
        scrollJob?.cancel()
        isScrolling = false
        Log.d(TAG, "Auto scroll stopped")
    }

    private fun performScroll(): Boolean {
        val displayMetrics = resources.displayMetrics
        val screenHeight = displayMetrics.heightPixels
        val screenWidth = displayMetrics.widthPixels

        // 화면 중앙에서 아래로 스와이프
        val startY = (screenHeight * 0.7).toFloat()
        val endY = (screenHeight * 0.3).toFloat()
        val centerX = (screenWidth * 0.5).toFloat()

        val path = Path().apply {
            moveTo(centerX, startY)
            lineTo(centerX, endY)
        }

        val gestureBuilder = GestureDescription.Builder()
        val gesture = gestureBuilder
            .addStroke(GestureDescription.StrokeDescription(path, 0, 300))
            .build()

        return dispatchGesture(gesture, object : GestureResultCallback() {
            override fun onCompleted(gestureDescription: GestureDescription?) {
                Log.d(TAG, "Scroll gesture completed")
            }

            override fun onCancelled(gestureDescription: GestureDescription?) {
                Log.d(TAG, "Scroll gesture cancelled")
            }
        }, null)
    }

    fun isServiceEnabled(): Boolean {
        return instance != null
    }

    private fun isSimilarImage(path1: String, path2: String): Boolean {
        return try {
            val file1 = File(path1)
            val file2 = File(path2)

            // 파일 크기로만 비교 (간단하고 빠름)
            val size1 = file1.length()
            val size2 = file2.length()

            // 크기 차이를 절대값으로 계산
            val sizeDiff = kotlin.math.abs(size1 - size2)
            val avgSize = (size1 + size2) / 2.0
            val diffPercentage = (sizeDiff.toDouble() / avgSize) * 100

            Log.d(TAG, "File size comparison: $size1 vs $size2 (diff: ${String.format("%.2f", diffPercentage)}%)")

            // 3% 이내 차이면 같은 화면으로 판단
            if (diffPercentage <= 3.0) {
                Log.d(TAG, "Similar file sizes - likely same screen")
                return true
            }

            false
        } catch (e: Exception) {
            Log.e(TAG, "Error comparing images: ${e.message}")
            false
        }
    }
}
