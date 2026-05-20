# Keep everything - no exceptions
-keep class com.pixelmind.varahiowner.** { *; }
-keepclassmembers class com.pixelmind.varahiowner.** {
    <init>(...);
    <fields>;
    <methods>;
}

# Keep ChangeNotifier and notifyListeners
-keep class * extends flutter.foundation.ChangeNotifier {
    <init>(...);
    <fields>;
    <methods>;
}
-keepclassmembers class * {
    void notifyListeners();
}

# Keep all model classes and their fromJson methods
-keepclassmembers class * {
    *** fromJson(...);
}

# Keep all fields in model classes
-keepclassmembers class com.pixelmind.varahiowner.model.** {
    <fields>;
}

# Ignore warnings
-ignorewarnings
-dontwarn **