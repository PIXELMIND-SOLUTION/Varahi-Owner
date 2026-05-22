# Keep all your model classes and their methods
-keep class com.varahiowner.models.** { *; }
-keepclassmembers class com.varahiowner.models.** {
    *;
}

# Keep all classes with fromJson methods
-keepclassmembers class * {
    *** fromJson(...);
    *** toJson(...);
}

# Keep type checks for Map and List (critical for your parsing)
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod
-keepattributes InnerClasses

# Keep all fields in model classes
-keepclassmembers class * {
    public final <fields>;
    public <methods>;
}

# Keep dart:core reflection
-keep class dart.** { *; }
-keep class io.flutter.** { *; }

# Keep DateTime parsing
-keep class java.time.** { *; }
-keep class org.joda.time.** { *; }

# Keep generic types for JSON
-keepattributes Signature

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep enum values
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Keep Parcelable implementations
-keep class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}

# Keep all classes in your package
-keep class com.varahiowner.** { *; }
-dontwarn com.varahiowner.**

# Keep all Dart classes
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep the text recognizer (since you're using ML Kit)
-keep class com.google.mlkit.** { *; }
-dontwarn com.google.mlkit.**