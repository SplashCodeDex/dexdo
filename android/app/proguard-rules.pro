# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Firebase missing classes
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**
-keep class com.google.firebase.** { *; }

# Keep home_widget package classes to prevent R8 from stripping them
-keep class es.antonborri.home_widget.** { *; }

# Keep the custom AppWidgetProvider and its members
-keep class com.dexify.dexdo.DexDoWidgetProvider { *; }

# Suppress warnings about missing Play Core classes used by Flutter's deferred components
-dontwarn com.google.android.play.core.**


