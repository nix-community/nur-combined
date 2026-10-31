"""Select Darwin implementations without changing the Linux source list."""
from pathlib import Path
p = Path('meson.build')
s = p.read_text()
replacements = {
    "['c', 'java']": "['c', 'java', 'objc']",
    "language: 'c')": "language: ['c', 'objc'])",
    "'src/api-impl-jni/android_inputmethodservice_InputMethodService.c',": "'src/api-impl-jni/darwin/input.m',",
    "'src/api-impl-jni/app/android_app_NotificationManager.c',": "'src/api-impl-jni/darwin/platform.m',",
    "'src/api-impl-jni/audio/android_media_AudioTrack.c',": "'src/api-impl-jni/darwin/audio-jni.c',",
    "'src/api-impl-jni/audio/android_media_AudioRecord.c',": "'src/api-impl-jni/darwin/audio.c',",
    "'src/api-impl-jni/widgets/android_webkit_WebView.c',": "'src/api-impl-jni/darwin/webview.m',",
    "dependency('libavcodec', version: '>=59')": "dependency('sdl2'), dependency('libavcodec', version: '>=59')",
}
for old,new in replacements.items():
    assert old in s, f'missing Meson source/dependency: {old}'
    s = s.replace(old,new)
for name in ['android_os_Vibrator', 'app/android_app_WallpaperManager', 'audio/android_media_AudioManager', 'audio/audio', 'location/android_location_LocationManager', 'media/android_media_session_MediaSession']:
    old = f"'src/api-impl-jni/{name}.c',"
    assert old in s, f'missing Darwin source exclusion: {old}'
    s = s.replace(old,'')
s += "\nsubdir('src/api-impl-jni/darwin')\n"
p.write_text(s)
