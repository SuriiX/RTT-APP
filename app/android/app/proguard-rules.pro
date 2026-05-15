# --- Flutter / Dart ---
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**

# --- ExoPlayer / Media3 (usado por just_audio) ---
-keep class com.google.android.exoplayer2.** { *; }
-keep class androidx.media3.** { *; }
-dontwarn com.google.android.exoplayer2.**
-dontwarn androidx.media3.**

# --- audio_service / audio_session (Ryan Heise) ---
-keep class com.ryanheise.audioservice.** { *; }
-keep class com.ryanheise.audio_session.** { *; }
-keep class com.ryanheise.just_audio.** { *; }
-dontwarn com.ryanheise.**

# --- AndroidX MediaSession ---
-keep class androidx.media.** { *; }
-dontwarn androidx.media.**

# --- url_launcher / share_plus ---
-dontwarn io.flutter.plugins.urllauncher.**
-dontwarn dev.fluttercommunity.plus.share.**

# --- Conserva anotaciones y firmas necesarias para reflection ---
-keepattributes *Annotation*, InnerClasses, Signature, Exceptions
-keepattributes SourceFile, LineNumberTable
-renamesourcefileattribute SourceFile

# --- Modelos serializados (defensivo, por si más adelante se añade JSON) ---
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# --- Evita warnings del JDK / Java desugar ---
-dontwarn java.lang.invoke.StringConcatFactory
