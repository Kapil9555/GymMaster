@echo off
set ANDROID_HOME=C:\Android\Sdk
set ANDROID_SDK_ROOT=C:\Android\Sdk
set JAVA_HOME=C:\Program Files\Microsoft\jdk-17.0.19.10-hotspot
set PATH=C:\flutter\bin;%JAVA_HOME%\bin;C:\Android\Sdk\cmdline-tools\latest\bin;C:\Android\Sdk\platform-tools;%PATH%
cd /d "d:\Kapil Data\live\force\GymMaster\mobile"
echo Building APK...
flutter build apk --release
echo Build finished with exit code %ERRORLEVEL%
pause
