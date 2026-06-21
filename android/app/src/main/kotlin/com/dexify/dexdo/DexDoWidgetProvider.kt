package com.dexify.dexdo

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin
import com.dexify.dexdo.R

class DexDoWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            val widgetData = HomeWidgetPlugin.getData(context)
            val views = RemoteViews(context.packageName, R.layout.dexdo_widget).apply {
                // Get count
                val count = widgetData.getInt("active_tasks_count", 0)
                setTextViewText(R.id.widget_task_count, "$count")
                setTextViewText(
                    R.id.widget_subtitle,
                    if (count == 1) "task remaining" else "tasks remaining"
                )

                // Get top 3 tasks
                val task0 = widgetData.getString("task_title_0", "")
                val task1 = widgetData.getString("task_title_1", "")
                val task2 = widgetData.getString("task_title_2", "")

                setTaskTextOrHide(this, R.id.widget_task_0, task0)
                setTaskTextOrHide(this, R.id.widget_task_1, task1)
                setTaskTextOrHide(this, R.id.widget_task_2, task2)

                // Setup launch intent when tapping the widget
                val intent = Intent(context, MainActivity::class.java)
                val pendingIntent = PendingIntent.getActivity(
                    context, 0, intent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
                setOnClickPendingIntent(R.id.widget_root, pendingIntent)
            }
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }

    private fun setTaskTextOrHide(views: RemoteViews, viewId: Int, text: String?) {
        if (!text.isNullOrEmpty()) {
            views.setViewVisibility(viewId, View.VISIBLE)
            views.setTextViewText(viewId, "• $text")
        } else {
            views.setViewVisibility(viewId, View.GONE)
        }
    }
}
