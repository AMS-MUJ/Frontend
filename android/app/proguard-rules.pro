# ------------------------------
# Fix R8 missing annotations
# (Google Tink / ErrorProne)
# ------------------------------

-dontwarn com.google.errorprone.annotations.**
-dontwarn javax.annotation.**
-dontwarn javax.annotation.concurrent.**

-keep class com.google.errorprone.annotations.** { *; }
-keep class javax.annotation.** { *; }
-keep class javax.annotation.concurrent.** { *; }
