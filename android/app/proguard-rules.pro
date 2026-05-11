# Flutter wrappers for TDLib require keeping the native JNI classes
-keep class org.drinkless.tdlib.** { *; }

# Keep native methods and their callbacks
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep the client and its methods
-keep class org.drinkless.tdlib.Client { *; }
-keep class org.drinkless.tdlib.Client$* { *; }
