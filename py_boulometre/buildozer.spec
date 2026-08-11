[app]

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

# (list) Source files to exclude (let empty to not exclude anything)
source.exclude_exts = spec,pyc,pyo,pyd

# (list) List of directory to exclude (let empty to not exclude anything)
source.exclude_dirs = tests,bin,venv,.venv,env,.env,__pycache__,.buildozer

# (str) Application versioning
version = 0.1.0

# (list) Application requirements
requirements = python3,kivy==2.1.0,kivymd==1.1.1,Pillow==10.2.0,pyjnius==1.6.1

# (str) Supported orientation
orientation = portrait


[android]

# (list) List of android permissions to request
android.permissions = INTERNET, CAMERA, VIBRATE, WRITE_EXTERNAL_STORAGE, READ_EXTERNAL_STORAGE

# (int) Android API to use
android.api = 33

# (int) Android minimum API to use
android.minapi = 21

# (str) Android NDK version to use
android.ndk = 25.2.9519653

# (bool) Use --private data storage (True) or --dir public storage (False)
android.private_storage = True

# (str) The Android entry point
android.entrypoint = org.kivy.android.PythonActivity

# (str) The bootstraps to build for
android.bootstrap = sdl2

# (str) The Android arch to build for
android.arch = arm64-v8a

# (int) Android log level to use
android.log_level = 2

# (bool) Skip automatic download of SDK/NDK/Build-Tools
# These will be set by the GitHub Actions workflow
android.skip_sdk_download = True
android.skip_ndk_download = True
android.skip_build_tools_download = True
