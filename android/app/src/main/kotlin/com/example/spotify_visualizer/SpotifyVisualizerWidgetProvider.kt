package com.example.spotify_visualizer

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.graphics.*
import android.widget.RemoteViews
import org.json.JSONArray
import kotlin.math.sin

class SpotifyVisualizerWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    private fun updateAppWidget(context: Context, appWidgetManager: AppWidgetManager, appWidgetId: Int) {
        val views = RemoteViews(context.packageName, R.layout.spotify_visualizer_widget)
        
        // Get widget data from shared preferences
        val prefs = context.getSharedPreferences("flutter.spotify_visualizer_preferences", Context.MODE_PRIVATE)
        val trackName = prefs.getString("flutter.track_name", "No track playing") ?: "No track playing"
        val artistName = prefs.getString("flutter.artist_name", "") ?: ""
        val isPlaying = prefs.getBoolean("flutter.is_playing", false)
        val waveformData = prefs.getString("flutter.waveform_data", "[]") ?: "[]"
        val primaryColor = prefs.getInt("flutter.primary_color", Color.GREEN)

        // Update text views
        views.setTextViewText(R.id.track_name, trackName)
        views.setTextViewText(R.id.artist_name, artistName)
        
        // Update play/pause icon
        views.setImageViewResource(R.id.play_pause_icon, 
            if (isPlaying) android.R.drawable.ic_media_pause else android.R.drawable.ic_media_play)

        // Generate and set visualizer bitmap
        val visualizerBitmap = generateVisualizerBitmap(waveformData, primaryColor, isPlaying)
        views.setImageViewBitmap(R.id.visualizer_view, visualizerBitmap)

        // Set click intent to open main app
        val intent = Intent(context, MainActivity::class.java)
        val pendingIntent = PendingIntent.getActivity(context, 0, intent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)
        views.setOnClickPendingIntent(R.id.widget_container, pendingIntent)

        appWidgetManager.updateAppWidget(appWidgetId, views)
    }

    private fun generateVisualizerBitmap(waveformDataJson: String, primaryColor: Int, isPlaying: Boolean): Bitmap {
        val width = 300
        val height = 100
        val bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)
        
        // Parse waveform data
        val amplitudes = try {
            val jsonArray = JSONArray(waveformDataJson)
            FloatArray(jsonArray.length()) { i -> jsonArray.getDouble(i).toFloat() }
        } catch (e: Exception) {
            // Default waveform if parsing fails
            FloatArray(50) { 0.5f + sin(it * 0.2f) * 0.3f }
        }

        // Set up paint
        val paint = Paint().apply {
            color = if (isPlaying) primaryColor else Color.argb(128, Color.red(primaryColor), Color.green(primaryColor), Color.blue(primaryColor))
            strokeWidth = 2f
            style = Paint.Style.FILL
            isAntiAlias = true
        }

        // Draw simplified bar visualizer
        val barCount = minOf(amplitudes.size, 32)
        val barWidth = width.toFloat() / barCount * 0.8f
        val barSpacing = width.toFloat() / barCount

        for (i in 0 until barCount) {
            val amplitude = amplitudes[i * amplitudes.size / barCount]
            val barHeight = amplitude * height * (if (isPlaying) 0.8f else 0.4f)
            val x = i * barSpacing + (barSpacing - barWidth) / 2
            val y = height - barHeight
            
            val rect = RectF(x, y, x + barWidth, height.toFloat())
            canvas.drawRoundRect(rect, barWidth / 4, barWidth / 4, paint)
        }

        return bitmap
    }

    override fun onEnabled(context: Context) {
        super.onEnabled(context)
    }

    override fun onDisabled(context: Context) {
        super.onDisabled(context)
    }
}