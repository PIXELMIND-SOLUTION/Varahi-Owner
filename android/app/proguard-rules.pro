# This tells R8 to ignore the missing classes error
-ignorewarnings
-keepattributes *Annotation*
-keepattributes Signature
-dontwarn **

# If the error specifically mentioned missing rules, 
# you can also add this more specific line:
-dontwarn com.google.errorprone.annotations.**