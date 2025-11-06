package com.example.overlay

import android.annotation.SuppressLint
import android.app.Service
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.graphics.PixelFormat
import android.os.Build
import android.os.IBinder
import android.util.Log
import android.view.Gravity
import android.view.LayoutInflater
import android.view.View
import android.view.WindowManager
import android.widget.TextView
import org.json.JSONArray
import org.json.JSONObject

class MarkerOverlayService : Service() {
    companion object {
        private const val TAG = "MarkerOverlayService"
        private var instance: MarkerOverlayService? = null

        fun getInstance(): MarkerOverlayService? = instance

        const val ACTION_SHOW_MARKERS = "com.example.overlay.SHOW_MARKERS"
        const val ACTION_CLEAR_MARKERS = "com.example.overlay.CLEAR_MARKERS"
        const val EXTRA_MARKERS_DATA = "markers_data"

        // 브로드캐스트 액션
        const val ACTION_MARKER_CLICKED = "com.example.overlay.MARKER_CLICKED"
        const val EXTRA_MARKER_DATA = "marker_data"
    }

    private lateinit var windowManager: WindowManager
    private val markerViews = mutableListOf<View>()
    private val markerDataList = mutableListOf<JSONObject>()

    override fun onCreate() {
        super.onCreate()
        instance = this
        windowManager = getSystemService(Context.WINDOW_SERVICE) as WindowManager
        Log.d(TAG, "MarkerOverlayService created")
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        Log.d(TAG, "onStartCommand: action=${intent?.action}")

        when (intent?.action) {
            ACTION_SHOW_MARKERS -> {
                val markersJson = intent.getStringExtra(EXTRA_MARKERS_DATA)
                if (markersJson != null) {
                    showMarkers(markersJson)
                }
            }
            ACTION_CLEAR_MARKERS -> {
                clearMarkers()
            }
        }

        return START_STICKY
    }

    @SuppressLint("InflateParams")
    private fun showMarkers(markersJson: String) {
        try {
            // 기존 마커 제거
            clearMarkers()

            val markersArray = JSONArray(markersJson)
            Log.d(TAG, "Showing ${markersArray.length()} markers")

            for (i in 0 until markersArray.length()) {
                val marker = markersArray.getJSONObject(i)
                val x = marker.getDouble("x").toFloat()
                val y = marker.getDouble("y").toFloat()
                val score = marker.getInt("score")

                Log.d(TAG, "Creating marker at ($x, $y) with score $score")

                // 마커 데이터 저장
                markerDataList.add(marker)

                // 마커 뷰 생성 (인덱스 전달)
                val markerView = createMarkerView(score, i)

                // WindowManager 파라미터 설정 (클릭 가능하도록 FLAG 수정)
                val params = WindowManager.LayoutParams(
                    WindowManager.LayoutParams.WRAP_CONTENT,
                    WindowManager.LayoutParams.WRAP_CONTENT,
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
                    } else {
                        @Suppress("DEPRECATION")
                        WindowManager.LayoutParams.TYPE_PHONE
                    },
                    WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL or
                            WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN or
                            WindowManager.LayoutParams.FLAG_WATCH_OUTSIDE_TOUCH,
                    PixelFormat.TRANSLUCENT
                ).apply {
                    gravity = Gravity.TOP or Gravity.START
                    this.x = x.toInt()
                    this.y = y.toInt()
                }

                try {
                    windowManager.addView(markerView, params)
                    markerViews.add(markerView)
                    Log.d(TAG, "Marker added at ($x, $y)")
                } catch (e: Exception) {
                    Log.e(TAG, "Failed to add marker: ${e.message}")
                }
            }

            Log.d(TAG, "Total markers displayed: ${markerViews.size}")
        } catch (e: Exception) {
            Log.e(TAG, "Error showing markers: ${e.message}", e)
        }
    }

    private fun createMarkerView(score: Int, markerIndex: Int): View {
        // 간단한 원형 마커 생성
        val markerView = TextView(this).apply {
            text = score.toString()
            textSize = 16f
            setTextColor(Color.WHITE)
            gravity = Gravity.CENTER
            setPadding(8, 8, 8, 8)

            // 빨간색 원형 배경
            background = resources.getDrawable(android.R.drawable.ic_menu_mylocation, null)
            setBackgroundColor(Color.RED)

            // 원형으로 만들기
            val size = 100 // 픽셀
            layoutParams = WindowManager.LayoutParams(size, size)

            // 클릭 리스너 추가
            setOnClickListener {
                onMarkerClicked(markerIndex)
            }
        }

        return markerView
    }

    private fun onMarkerClicked(markerIndex: Int) {
        try {
            if (markerIndex < markerDataList.size) {
                val markerData = markerDataList[markerIndex]
                Log.d(TAG, "Marker clicked: $markerData")

                // 브로드캐스트로 MainActivity에 전달
                val intent = Intent(ACTION_MARKER_CLICKED).apply {
                    putExtra(EXTRA_MARKER_DATA, markerData.toString())
                }
                sendBroadcast(intent)
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error handling marker click: ${e.message}")
        }
    }

    private fun clearMarkers() {
        Log.d(TAG, "Clearing ${markerViews.size} markers")
        markerViews.forEach { view ->
            try {
                windowManager.removeView(view)
            } catch (e: Exception) {
                Log.e(TAG, "Failed to remove marker: ${e.message}")
            }
        }
        markerViews.clear()
        markerDataList.clear()
    }

    override fun onDestroy() {
        clearMarkers()
        instance = null
        super.onDestroy()
        Log.d(TAG, "MarkerOverlayService destroyed")
    }

    override fun onBind(intent: Intent?): IBinder? = null
}
