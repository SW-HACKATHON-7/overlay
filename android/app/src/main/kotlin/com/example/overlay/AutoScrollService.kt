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
                        delay(2000)
                    }

                    // 다시 한번 체크 (delay 후)
                    if (!isScrolling) {
                        Log.d(TAG, "Auto scroll stopped during delay")
                        break
                    }

                    // 스크린샷 촬영
                    val path = screenshotCallback?.invoke()
                    if (path != null) {
                        // 기존 스크린샷들과 유사도 비교
                        var isDuplicate = false
                        for (existingPath in screenshots) {
                            if (isSimilarImage(existingPath, path)) {
                                Log.d(TAG, "Similar screen detected. Stopping.")
                                File(path).delete() // 중복 파일 삭제
                                isDuplicate = true
                                shouldStop = true
                                break
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

    private fun isSimilarImage(path1: String, path2: String, threshold: Double = 0.92): Boolean {
        return try {
            val file1 = File(path1)
            val file2 = File(path2)

            // 파일 크기로 먼저 빠른 체크 (20% 이상 차이나면 다른 이미지)
            val size1 = file1.length()
            val size2 = file2.length()
            val sizeRatio = minOf(size1, size2).toDouble() / maxOf(size1, size2).toDouble()

            if (sizeRatio < 0.8) {
                Log.d(TAG, "Size diff too large: $sizeRatio - different images")
                return false
            }

            // 바이트 단위로 비교 (샘플링으로 속도 향상)
            val bytes1 = file1.readBytes()
            val bytes2 = file2.readBytes()

            // 크기가 다르면 다른 이미지
            if (bytes1.size != bytes2.size) {
                Log.d(TAG, "Byte size different: ${bytes1.size} vs ${bytes2.size}")
                return false
            }

            // 샘플링: 10바이트마다 1개씩만 비교 (속도 향상)
            val sampleRate = 10
            var matchingBytes = 0
            var totalSampled = 0

            for (i in bytes1.indices step sampleRate) {
                if (bytes1[i] == bytes2[i]) {
                    matchingBytes++
                }
                totalSampled++
            }

            val similarity = matchingBytes.toDouble() / totalSampled.toDouble()
            Log.d(TAG, "Image similarity (sampled): ${String.format("%.4f", similarity)} (${totalSampled} samples)")

            similarity >= threshold
        } catch (e: Exception) {
            Log.e(TAG, "Error comparing images: ${e.message}")
            false
        }
    }
}
