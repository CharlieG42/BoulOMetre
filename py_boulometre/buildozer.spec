# (str) Title of your application
title = PyBoul'O'Mètre

# (str) Package name
package.name = pyboulometre

# (str) Package domain (needed for android/ios packaging)
package.domain = com.charlieg42

# (str) Source code where the main.py live
source.dir = src

# (list) Source files to include (let empty to include all the files)
source.include_exts = py,png,jpg,kv,atlas,ttf,otf,woff,woff2

# (list) List of inclusions using pattern matching
#source.include_patterns = assets/*,images/*.png

# (list) Source files to exclude (let empty to not exclude anything)
source.exclude_exts = spec,pyc,pyo,pyd

# (list) List of directory to exclude (let empty to not exclude anything)
source.exclude_dirs = tests,bin,venv,.venv,env,.env,__pycache__,.buildozer

# (str) Application versioning (method 1)
version = 0.1.0

# (str) Application versioning (method 2)
# version.regex = __version__ = ['"](.*)['"]
# version.filename = %(source.dir)s/main.py

# (list) Application requirements
requirements = python3,kivy==2.2.1,kivymd==1.1.1,opencv-python-headless==4.9.0.80,Pillow==10.2.0,pyjnius==1.6.1,numpy==1.26.4

# (str) Custom source folders for requirements
# Sets custom source for any requirements with recipes
# requirements.source =

# (str) Presplash of the application
# presplash.filename = %(source.dir)s/data/presplash.png

# (str) Icon of the application
# icon.filename = %(source.dir)s/data/icon.png

# (str) Supported orientation (one of landscape, portrait or all)
orientation = portrait

# (list) List of include files to copy into libs/ (filters out .pyc, .pyo, .pyd)
# Defaults to empty list

# (str) Path to a custom p4a branch to use for building
# p4a.branch = develop

# (str) Path to a custom p4a fork to use for building
# p4a.source_dir =

# (list) List of android permissions to request
android.permissions = INTERNET, CAMERA, VIBRATE, WRITE_EXTERNAL_STORAGE, READ_EXTERNAL_STORAGE, ACCESS_NETWORK_STATE

# (list) List of android API to use
android.api = 34

# (int) Android minimum API to use
android.minapi = 21

# (int) Android SDK version to use
android.sdk = 34

# (str) Android NDK version to use
android.ndk = 26.2.11394342

# (bool) Use --private data storage (True) or --dir public storage (False)
android.private_storage = True

# (str) Android NDK directory (if empty, it will be automatically downloaded.)
# android.ndk_path =

# (str) Android SDK directory (if empty, it will be automatically downloaded.)
# android.sdk_path =

# (str) python-for-android branch to use
p4a.branch = develop

# (str) OUYA Console category. Should be one of GAME or APP
# ouya.category = GAME

# (str) Filename of the .apk archive to build
# android.arch = armeabi-v7a

# (int) Android log level to use
android.log_level = 2

# (str) The Android NDK directory (if empty, it will be automatically downloaded.)
# android.ndk_path =

# (str) The Android SDK directory (if empty, it will be automatically downloaded.)
# android.sdk_path =

# (str) python-for-android git clone directory (if empty, it will be automatically cloned from github)
# p4a.source_dir =

# (str) The version of buildozer to use
# buildozer.version = 1.5.0

# (str) The Android entry point, default is ok for Kivy-based app
android.entrypoint = org.kivy.android.PythonActivity

# (list) List of Java .jar files to add to the libs so that pyjnius can access
# their classes. Don't add jars that you do not need, since extra jars can slow
# down the build process. Allows wildcards matching, for example:
# OUYA-ODK/libs/*.jar
# android.add_jars = foo.jar,bar.jar,path/to/more/*.jar

# (list) List of Java files to add to the android project (can be java or a
# directory containing the files)
# android.add_src =

# (list) Android AAR archives to add (currently works only with sdl2_gradle
# bootstrap)
# android.add_aars =

# (list) Gradle dependencies to add (currently works only with sdl2_gradle
# bootstrap)
# android.gradle_dependencies =

# (str) The bootstraps to build for, choices: sdl2, pygame, webview, service_only
# "sdl2" is recommended
android.bootstrap = sdl2

# (str) The Android arch to build for, choices: armeabi-v7a, arm64-v8a, x86, x86_64
android.arch = arm64-v8a

# (int) port number to specify an explicit --port= p4a argument (eg for bootstrap flask)
# p4a.port =

# (str) Name of the activity to start on Android
# android.activity = org.kivy.android.PythonActivity

# (str) Name of the service to start on Android
# android.service = org.kivy.android.PythonService

# (str) Name of the broadcast receiver to start on Android
# android.receiver = org.kivy.android.PythonReceiver

# (str) Name of the intent filter to start on Android
# android.intent = org.kivy.android.PythonIntent

# (str) Name of the intent filter action to start on Android
# android.intent_action = org.kivy.android.PythonIntent

# (str) Name of the intent filter category to start on Android
# android.intent_category = org.kivy.android.PythonIntent

# (str) Name of the intent filter data to start on Android
# android.intent_data = org.kivy.android.PythonIntent
