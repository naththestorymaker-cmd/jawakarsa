# Keep Flutter engine/embedding wrappers
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**

# Firebase / Firestore / Auth / Protobuf / gRPC
-keepattributes Signature
-keepattributes *Annotation*
-keepclassmembers class * extends com.google.protobuf.GeneratedMessageLite { *; }
-dontwarn com.google.errorprone.annotations.**
-dontwarn javax.annotation.**
-dontwarn org.codehaus.mojo.animal_sniffer.**

# Media3 / ExoPlayer (just_audio & video_player)
-dontwarn androidx.media3.**
-dontwarn com.google.android.exoplayer2.**

# Google Play Services Auth (google_sign_in)
-dontwarn com.google.android.gms.**
