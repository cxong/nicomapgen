# Package

version = "0.1.0"
author = "congusbongus"
description = "nicomapgen"
license = "?"

# Deps
requires "nim >= 1.2.0"
requires "nico >= 0.2.5"

srcDir = "src"

import strformat

const releaseOpts = "-d:danger"
const debugOpts = "-d:debug"

task runr, "Runs nicomapgen for current platform":
 exec &"nim c -r {releaseOpts} -o:nicomapgen src/main.nim"

task rund, "Runs debug nicomapgen for current platform":
 exec &"nim c -r {debugOpts} -o:nicomapgen src/main.nim"

task release, "Builds nicomapgen for current platform":
 exec &"nim c {releaseOpts} -o:nicomapgen src/main.nim"

task webd, "Builds debug nicomapgen for web":
 exec &"nim c {debugOpts} -d:emscripten -o:nicomapgen.html src/main.nim"

task webr, "Builds release nicomapgen for web":
 exec &"nim c {releaseOpts} -d:emscripten -o:nicomapgen.html src/main.nim"

task debug, "Builds debug nicomapgen for current platform":
 exec &"nim c {debugOpts} -o:nicomapgen_debug src/main.nim"

task deps, "Downloads dependencies":
 if defined(windows):
  exec "curl https://www.libsdl.org/release/SDL2-2.0.18-win32-x64.zip -o SDL2_x64.zip"
  exec "unzip SDL2_x64.zip"
 elif defined(macosx) and findExe("brew") != "":
  exec "brew list sdl2 || brew install sdl2"
 else:
  echo "I don't know how to install SDL on your OS! 😿"

task androidr, "Release build for android":
  if defined(windows):
    exec &"nicoandroid.cmd"
  else:
    exec &"nicoandroid"
  exec &"nim c -c --nimcache:android/app/jni/src/armeabi {releaseOpts}  --cpu:arm   --os:android -d:androidNDK --noMain --genScript src/main.nim"
  exec &"nim c -c --nimcache:android/app/jni/src/arm64   {releaseOpts}  --cpu:arm64 --os:android -d:androidNDK --noMain --genScript src/main.nim"
  exec &"nim c -c --nimcache:android/app/jni/src/x86     {releaseOpts}  --cpu:i386  --os:android -d:androidNDK --noMain --genScript src/main.nim"
  exec &"nim c -c --nimcache:android/app/jni/src/x86_64  {releaseOpts}  --cpu:amd64 --os:android -d:androidNDK --noMain --genScript src/main.nim"
  withDir "android":
    if defined(windows):
      exec &"gradlew.bat assembleDebug"
    else:
      exec "./gradlew assembleDebug"
