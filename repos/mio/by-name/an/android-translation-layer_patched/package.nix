{
  lib,
  stdenv,
  android-translation-layer,
  art-standalone_patched,
  bionic-translation_patched,
  cacert,
  webp-pixbuf-loader,
  gdk-pixbuf,
  librsvg,
  fetchpatch,
  wrapGAppsHook4,
  vulkan-loader,
  vulkan-headers,
}:

(android-translation-layer.override (
  {
    art-standalone = art-standalone_patched;
    bionic-translation = bionic-translation_patched;
  }
  // lib.optionalAttrs (!stdenv.hostPlatform.isLinux) {
    alsa-lib = null;
    libdrm = null;
    libgudev = null;
    wayland = null;
    wayland-protocols = null;
    wayland-scanner = null;
    libportal-gtk4 = null;
    webkitgtk_6_0 = null;
  }
)).overrideAttrs
  (old: {
    pname = "android-translation-layer-patched";
    nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [
      wrapGAppsHook4
    ];
    buildInputs = (old.buildInputs or [ ]) ++ [
      webp-pixbuf-loader
      vulkan-loader
      vulkan-headers
    ];
    patches = (old.patches or [ ]) ++ [
      ./android-translation-layer-bitmap-unlock.patch
      ./android-translation-layer-bitmapfactory-logs.patch
      ./android-translation-layer-kotatsu-stub.patch
      (fetchpatch {
        url = "https://gitlab.com/android_translation_layer/android_translation_layer/-/merge_requests/290.patch";
        hash = "sha256-Aan2AnrLSFLURWVggpxMM2Sztkhy0g7atSeQDGJasz8=";
      })
      (fetchpatch {
        url = "https://gitlab.com/android_translation_layer/android_translation_layer/-/merge_requests/251.patch";
        hash = "sha256-Y39nuhVGcGP/H61ZbyclMyAO2HjsC2VVl4R86N8c0K0=";
      })
      ./android-translation-layer-fdroid-stub.patch
      ./android-translation-layer-context-stub.patch
      ./android-translation-layer-newpipe-esc-stub.patch
      ./android-translation-layer-newpipe-red-layer.patch
      ./android-translation-layer-wifiinfo-ssid-stub.patch
      ./android-translation-layer-apk-sourcedir.patch
      ./android-translation-layer-wifi-ap-stub.patch
      ./android-translation-layer-system-app-certs.patch
      ./android-translation-layer-gtk-measure.patch
      ./android-translation-layer-wrapper-measure-fix.patch
      ./android-translation-layer-imagebutton-scale.patch
      ./android-translation-layer-view-fullscreen-fix.patch
      ./android-translation-layer-gtk-native-check.patch
      ./android-translation-layer-media-data-source.patch
      ./android-translation-layer-drawlines-bounds.patch
      ./android-translation-layer-concat-2d.patch
      ./android-translation-layer-audiomanager-getdevices.patch
      ./android-translation-layer-networkcapabilities.patch
      ./android-translation-layer-path-op.patch
      ./android-translation-layer-bitmap-pixels-fix.patch
      ./android-translation-layer-bitmap-factory-null-pixbuf.patch
      ./android-translation-layer-bitmap-factory-fd.patch
      ./android-translation-layer-color-state-list-magenta.patch
      ./android-translation-layer-paint-color-filter-matrix.patch
      ./android-translation-layer-cairo-fallback.patch
      ./android-translation-layer-mr248-ads-stubs.patch
      ./android-translation-layer-microg-poc.patch
      ./android-translation-layer-gms-startservice-poc.patch
      ./android-translation-layer-gms-availability-stub.patch
      ./android-translation-layer-firebase-stubs.patch
      ./android-translation-layer-gms-client-stubs.patch
      ./android-translation-layer-gms-tasks-stubs.patch
      ./android-translation-layer-gms-location-stubs.patch
    ];
    postPatch = (old.postPatch or "") + lib.optionalString stdenv.isDarwin ''
      substituteInPlace meson.build \
        --replace-warn "dependency('wayland-protocols', version: '>=1.12')" "dependency('dummy', required: false)" \
        --replace-warn "dependency('wayland-client')" "dependency('dummy', required: false)" \
        --replace-warn "dependency('libportal')" "dependency('dummy', required: false)" \
        --replace-warn "dependency('libdrm')" "dependency('dummy', required: false)" \
        --replace-warn "dependency('gudev-1.0')" "dependency('dummy', required: false)" \
        --replace-warn "dependency('webkitgtk-6.0')" "dependency('dummy', required: false)" \
        --replace-warn "'-lasound'" "" \
        --replace-warn "'-Wl,-z,lazy'," "" \
        --replace-warn "subdir('protocol')" "wl_proto_headers = []" \
        --replace-warn "wl_proto_sources," ""
      rm -rf protocol

      substituteInPlace src/libandroid/native_window.c \
        --replace-warn "typedef XrResult (*xr_func)(...);" "typedef XrResult (*xr_func)();" \
        --replace-warn "return func(__builtin_va_arg_pack());" "return -1;"

      echo -e "#ifdef __APPLE__\n#include <jni.h>\nJNIEXPORT jint JNICALL Java_android_os_Vibrator_native_1constructor(JNIEnv *env, jobject this) { return -1; }\nJNIEXPORT void JNICALL Java_android_os_Vibrator_native_1vibrate(JNIEnv *env, jobject this, jint fd, jlong duration) {}\n#else\n$(cat src/api-impl-jni/android_os_Vibrator.c)\n#endif" > src/api-impl-jni/android_os_Vibrator.c
      
      echo -e "#ifndef __APPLE__\n$(cat src/main-executable/bionic_compat.c)\n#else\nvoid init__r_debug() {}\n#endif" > src/main-executable/bionic_compat.c

      echo -e "#ifdef __APPLE__\n#include <jni.h>\nJNIEXPORT jlong JNICALL Java_android_app_NotificationManager_nativeInitBuilder(JNIEnv *env, jobject this) { return 0; }\nJNIEXPORT void JNICALL Java_android_app_NotificationManager_nativeAddAction(JNIEnv *env, jobject this, jlong builder_ptr, jstring name_jstr, jint type, jobject intent) {}\nJNIEXPORT void JNICALL Java_android_app_NotificationManager_nativeShowNotification(JNIEnv *env, jobject this, jlong builder_ptr, jint id, jstring title_jstr, jstring text_jstr, jstring icon_jstr, jboolean ongoing, jint type, jobject intent) {}\nJNIEXPORT void JNICALL Java_android_app_NotificationManager_nativeCancel(JNIEnv *env, jobject this, jint id) {}\nJNIEXPORT void JNICALL Java_android_app_NotificationManager_nativeShowMPRIS(JNIEnv *env, jobject this, jstring package_name_jstr, jstring identity_jstr) {}\nJNIEXPORT void JNICALL Java_android_app_NotificationManager_nativeCancelMPRIS(JNIEnv *env, jobject this) {}\n#else\n$(cat src/api-impl-jni/app/android_app_NotificationManager.c)\n#endif" > src/api-impl-jni/app/android_app_NotificationManager.c

      echo -e "#ifdef __APPLE__\n#include <jni.h>\nJNIEXPORT jlong JNICALL Java_android_inputmethodservice_InputMethodService_00024ATLInputConnection_nativeInit(JNIEnv *env, jobject this) { return 0; }\nJNIEXPORT jboolean JNICALL Java_android_inputmethodservice_InputMethodService_00024ATLInputConnection_nativeSetCompositingText(JNIEnv *env, jobject this, jlong ptr, jstring text, jint newCursorPosition) { return 0; }\nJNIEXPORT jboolean JNICALL Java_android_inputmethodservice_InputMethodService_00024ATLInputConnection_nativeSetCompositingRegion(JNIEnv *env, jobject this, jlong ptr, jint start, jint end) { return 0; }\nJNIEXPORT jboolean JNICALL Java_android_inputmethodservice_InputMethodService_00024ATLInputConnection_nativeFinishComposingText(JNIEnv *env, jobject this, jlong ptr) { return 0; }\nJNIEXPORT jboolean JNICALL Java_android_inputmethodservice_InputMethodService_00024ATLInputConnection_nativeCommitText(JNIEnv *env, jobject this, jlong ptr, jstring text, jint newCursorPosition) { return 0; }\nJNIEXPORT jboolean JNICALL Java_android_inputmethodservice_InputMethodService_00024ATLInputConnection_nativeDeleteSurroundingText(JNIEnv *env, jobject this, jlong ptr, jint beforeLength, jint afterLength) { return 0; }\nJNIEXPORT jboolean JNICALL Java_android_inputmethodservice_InputMethodService_00024ATLInputConnection_nativeSetSelection(JNIEnv *env, jobject this, jlong ptr, jint start, jint end) { return 0; }\nJNIEXPORT jboolean JNICALL Java_android_inputmethodservice_InputMethodService_00024ATLInputConnection_nativeSendKeyEvent(JNIEnv *env, jobject this, jlong ptr, jlong time, jlong key, jlong state) { return 0; }\n#else\n$(cat src/api-impl-jni/android_inputmethodservice_InputMethodService.c)\n#endif" > src/api-impl-jni/android_inputmethodservice_InputMethodService.c

      echo -e "#ifdef __APPLE__\n#include <jni.h>\nJNIEXPORT void JNICALL Java_android_app_WallpaperManager_set_1bitmap(JNIEnv *env, jclass clazz, jlong texture_ptr) {}\n#else\n$(cat src/api-impl-jni/app/android_app_WallpaperManager.c)\n#endif" > src/api-impl-jni/app/android_app_WallpaperManager.c

      echo -e "#ifdef __APPLE__\n#include <jni.h>\nJNIEXPORT void JNICALL Java_android_location_LocationManager_nativeGetLocation(JNIEnv *env, jobject j) {}\n#else\n$(cat src/api-impl-jni/location/android_location_LocationManager.c)\n#endif" > src/api-impl-jni/location/android_location_LocationManager.c

      echo -e "#ifdef __APPLE__\n#include <jni.h>\nJNIEXPORT jlong JNICALL Java_android_media_MediaCodec_native_1constructor(JNIEnv *env, jobject this, jstring codec_name) { return 0; }\nJNIEXPORT void JNICALL Java_android_media_MediaCodec_native_1configure_1audio(JNIEnv *env, jobject this, jlong codec, jobject extradata, jint sample_rate, jint nb_channels) {}\nJNIEXPORT void JNICALL Java_android_media_MediaCodec_native_1configure_1video(JNIEnv *env, jobject this, jlong codec, jobject csd0, jobject csd1, jobject surface_obj) {}\nJNIEXPORT void JNICALL Java_android_media_MediaCodec_native_1start(JNIEnv *env, jobject this, jlong codec) {}\nJNIEXPORT jint JNICALL Java_android_media_MediaCodec_native_1queueInputBuffer(JNIEnv *env, jobject this, jlong codec, jobject buffer, jlong presentationTimeUs) { return 0; }\nJNIEXPORT jint JNICALL Java_android_media_MediaCodec_native_1dequeueOutputBuffer(JNIEnv *env, jobject this, jlong codec, jobject buffer, jobject buffer_info) { return 0; }\nJNIEXPORT void JNICALL Java_android_media_MediaCodec_native_1releaseOutputBuffer(JNIEnv *env, jobject this, jlong codec, jobject buffer, jboolean render, jlong presentationTimeNs) {}\nJNIEXPORT void JNICALL Java_android_media_MediaCodec_native_1flush(JNIEnv *env, jobject this, jlong codec) {}\nJNIEXPORT void JNICALL Java_android_media_MediaCodec_native_1release(JNIEnv *env, jobject this, jlong codec) {}\n#else\n$(cat src/api-impl-jni/media/android_media_MediaCodec.c)\n#endif" > src/api-impl-jni/media/android_media_MediaCodec.c

      echo -e "#ifdef __APPLE__\n#include <jni.h>\nJNIEXPORT jlong JNICALL Java_android_webkit_WebView_native_1constructor(JNIEnv *env, jobject this, jobject context, jobject attrs) { return 0; }\nJNIEXPORT void JNICALL Java_android_webkit_WebView_native_1loadUrl(JNIEnv *env, jobject this, jlong widget_ptr, jstring url) {}\nJNIEXPORT void JNICALL Java_android_webkit_WebView_native_1loadDataWithBaseURL(JNIEnv *env, jobject this, jlong widget_ptr, jstring base_url, jstring data_jstr, jstring mime_type, jstring encoding) {}\n#else\n$(cat src/api-impl-jni/widgets/android_webkit_WebView.c)\n#endif" > src/api-impl-jni/widgets/android_webkit_WebView.c

      for f in src/api-impl-jni/audio/*.c; do
        substituteInPlace "$f" --replace '#include <alsa/asoundlib.h>' '#include <alsa/asoundlib.h>
#include <stdlib.h>
#include <errno.h>
#include <stdio.h>'
      done
    '';
    preConfigure = (old.preConfigure or "") + lib.optionalString stdenv.isDarwin ''
      mkdir -p $NIX_BUILD_TOP/darwin_headers
      cat << 'EOF' > $NIX_BUILD_TOP/darwin_headers/uchar.h
#ifndef UCHAR_H
#define UCHAR_H
#include <stdint.h>
typedef uint_least16_t char16_t;
typedef uint_least32_t char32_t;
#endif
EOF
      mkdir -p $NIX_BUILD_TOP/darwin_headers/gdk/wayland
      cat << 'EOF' > $NIX_BUILD_TOP/darwin_headers/gdk/wayland/gdkwayland.h
#ifndef GDK_WAYLAND_H
#define GDK_WAYLAND_H
#define GDK_IS_WAYLAND_DISPLAY(display) (0)
#define GDK_IS_WAYLAND_TOPLEVEL(...) (0)
#define GDK_WAYLAND_TOPLEVEL(...) NULL
#define gdk_wayland_toplevel_set_application_id(...)
#define gdk_wayland_display_get_wl_display(display) NULL
#define gdk_wayland_display_get_wl_compositor(display) NULL
#define gdk_wayland_surface_get_wl_surface(surface) NULL
#endif
EOF
      mkdir -p $NIX_BUILD_TOP/darwin_headers/gdk/x11
      cat << 'EOF' > $NIX_BUILD_TOP/darwin_headers/gdk/x11/gdkx.h
#ifndef GDK_X11_H
#define GDK_X11_H
#define GDK_IS_X11_DISPLAY(display) (0)
#define gdk_x11_display_get_egl_version(...) 0
#define gdk_x11_display_get_xdisplay(...) NULL
#define gdk_x11_surface_get_xid(...) 0
#endif
EOF
      cat << 'EOF' > $NIX_BUILD_TOP/darwin_headers/wayland-client.h
#ifndef WAYLAND_CLIENT_H
#define WAYLAND_CLIENT_H
#include <stdint.h>
struct wl_display {};
struct wl_compositor {};
struct wl_surface {};
struct wl_subsurface {};
struct wl_region {};
struct wl_registry {};
struct wl_registry_listener {
    void (*global)(void *, struct wl_registry *, uint32_t, const char *, uint32_t);
    void (*global_remove)(void *, struct wl_registry *, uint32_t);
};
struct wl_interface {};
#define wl_display_get_registry(...) NULL
#define wl_registry_add_listener(...)
#define wl_display_roundtrip(...)
#define wl_compositor_create_surface(...) NULL
#define wl_subcompositor_get_subsurface(...) NULL
#define wl_subsurface_set_desync(...)
#define wl_subsurface_set_position(...)
#define wl_subsurface_place_below(...)
#define wl_compositor_create_region(...) NULL
#define wl_surface_set_input_region(...)
#define wl_region_destroy(...)
#define wl_surface_destroy(...)
#define wl_registry_bind(...) NULL
extern struct wl_interface wl_subcompositor_interface;
extern struct wl_interface wl_compositor_interface;
#endif
EOF
      cat << 'EOF' > $NIX_BUILD_TOP/darwin_headers/wayland-egl.h
#ifndef WAYLAND_EGL_H
#define WAYLAND_EGL_H
#include <wayland-client.h>
struct wl_egl_window {};
#define wl_egl_window_create(...) NULL
#define wl_egl_window_destroy(...)
#define wl_egl_window_resize(...)
#endif
EOF
      mkdir -p $NIX_BUILD_TOP/darwin_headers/X11/extensions
      cat << 'EOF' > $NIX_BUILD_TOP/darwin_headers/X11/Xlib.h
#ifndef XLIB_H
#define XLIB_H
typedef void* Display;
typedef unsigned long Window;
#define XDestroyWindow(...)
#define XResizeWindow(...)
#define XCreateSimpleWindow(...) 0
#define DefaultRootWindow(...) 0
#define XReparentWindow(...)
#define XMapWindow(...)
#endif
EOF
      cat << 'EOF' > $NIX_BUILD_TOP/darwin_headers/X11/Xutil.h
#ifndef XUTIL_H
#define XUTIL_H
typedef void* Region;
typedef struct { short x, y; unsigned short width, height; } XRectangle;
#define XCreateRegion(...) NULL
#define XUnionRectWithRegion(...)
#define XDestroyRegion(...)
#endif
EOF
      cat << 'EOF' > $NIX_BUILD_TOP/darwin_headers/X11/extensions/shape.h
#ifndef SHAPE_H
#define SHAPE_H
#define ShapeBounding 0
#define ShapeSet 0
#define XShapeCombineRegion(...)
#endif
EOF
      mkdir -p $NIX_BUILD_TOP/darwin_headers/vulkan
      cat << 'EOF' > $NIX_BUILD_TOP/darwin_headers/vulkan/vulkan_wayland.h
#ifndef VULKAN_WAYLAND_H
#define VULKAN_WAYLAND_H
#include <vulkan/vulkan.h>
typedef struct VkWaylandSurfaceCreateInfoKHR {
    int sType;
    void* display;
    void* surface;
} VkWaylandSurfaceCreateInfoKHR;
#define VK_STRUCTURE_TYPE_WAYLAND_SURFACE_CREATE_INFO_KHR 0
#define vkCreateWaylandSurfaceKHR(...) VK_ERROR_EXTENSION_NOT_PRESENT
#endif
EOF
      cat << 'EOF' > $NIX_BUILD_TOP/darwin_headers/vulkan/vulkan_xlib.h
#ifndef VULKAN_XLIB_H
#define VULKAN_XLIB_H
#include <vulkan/vulkan.h>
typedef void* Display;
typedef unsigned long Window;
typedef struct VkXlibSurfaceCreateInfoKHR {
    int sType;
    const void* pNext;
    int flags;
    Display* dpy;
    Window window;
} VkXlibSurfaceCreateInfoKHR;
#define VK_STRUCTURE_TYPE_XLIB_SURFACE_CREATE_INFO_KHR 0
#define vkCreateXlibSurfaceKHR(...) VK_ERROR_EXTENSION_NOT_PRESENT
#endif
EOF
      mkdir -p $NIX_BUILD_TOP/darwin_headers/sys
      cat << 'EOF' > $NIX_BUILD_TOP/darwin_headers/sys/mman.h
#include_next <sys/mman.h>
#include <stdlib.h>
#include <unistd.h>
#ifndef MFD_CLOEXEC
#define MFD_CLOEXEC 0
#endif
static inline int memfd_create(const char *name, unsigned int flags) {
    char path[] = "/tmp/memfd-XXXXXX";
    int fd = mkstemp(path);
    if (fd >= 0) unlink(path);
    return fd;
}
EOF
      mkdir -p $NIX_BUILD_TOP/darwin_headers/gudev
      touch $NIX_BUILD_TOP/darwin_headers/gudev/gudev.h
      mkdir -p $NIX_BUILD_TOP/darwin_headers/libportal
      cat << 'EOF' > $NIX_BUILD_TOP/darwin_headers/libportal/portal.h
#ifndef PORTAL_H
#define PORTAL_H
typedef struct XdpPortal XdpPortal;
#define XDP_OPEN_URI_FLAG_NONE 0
#define XDP_LAUNCHER_APPLICATION 0
#define XDP_PORTAL(x) ((XdpPortal*)(x))
#define XDP_WALLPAPER_FLAG_NONE 0
static inline XdpPortal* xdp_portal_new(void) { return 0; }
static inline void xdp_portal_open_uri(XdpPortal* portal, void* parent, const char* uri, int flags, void* cancellable, void* callback, void* user_data) {}
static inline void* xdp_portal_dynamic_launcher_prepare_install_finish(XdpPortal* p1, void* p2, void* p3) { return 0; }
static inline void xdp_portal_dynamic_launcher_install(XdpPortal* p1, void* p2, void* p3, void* p4, void* p5) {}
static inline void xdp_portal_dynamic_launcher_prepare_install(XdpPortal* p1, void* p2, void* p3, void* p4, void* p5, void* p6, int p7, int p8, void* p9, void* p10, void* p11) {}
static inline void xdp_portal_set_wallpaper_finish(XdpPortal* p1, void* p2, void* p3) {}
static inline void xdp_portal_set_wallpaper(XdpPortal* p1, void* p2, void* p3, int p4, void* p5, void* p6, void* p7) {}
#endif
EOF
      mkdir -p $NIX_BUILD_TOP/darwin_headers/alsa
      cat << 'EOF' > $NIX_BUILD_TOP/darwin_headers/alsa/asoundlib.h
#ifndef ASOUNDLIB_H
#define ASOUNDLIB_H
#include <stdlib.h>
#include <errno.h>
#include <stdio.h>
typedef void* snd_pcm_t;
typedef void* snd_pcm_hw_params_t;
typedef void* snd_pcm_sw_params_t;
typedef void* snd_async_handler_t;
typedef unsigned long snd_pcm_uframes_t;
typedef long snd_pcm_sframes_t;
typedef int snd_pcm_format_t;
#define SND_PCM_STREAM_CAPTURE 0
#define SND_PCM_STREAM_PLAYBACK 1
#define SND_PCM_ACCESS_RW_INTERLEAVED 0
#define SND_PCM_FORMAT_S16_LE 0
#define SND_PCM_FORMAT_U8 1
#define SND_PCM_FORMAT_FLOAT_LE 2
#define SND_PCM_FORMAT_S32_LE 3
#define SND_PCM_FORMAT_S24_LE 4
static inline const char* snd_strerror(int err) { return ""; }
static inline int snd_pcm_open(snd_pcm_t **pcm, const char *name, int stream, int mode) { return -1; }
static inline int snd_pcm_hw_params_alloca(snd_pcm_hw_params_t **p) { return 0; }
static inline int snd_pcm_hw_params_set_buffer_size_near(snd_pcm_t *pcm, snd_pcm_hw_params_t *params, snd_pcm_uframes_t *val) { return 0; }
static inline int snd_pcm_hw_params(snd_pcm_t *pcm, snd_pcm_hw_params_t *params) { return -1; }
static inline int snd_pcm_hw_params_get_period_size(const snd_pcm_hw_params_t *params, snd_pcm_uframes_t *val, int *dir) { return -1; }
static inline int snd_pcm_sw_params_malloc(snd_pcm_sw_params_t **ptr) { return 0; }
static inline int snd_pcm_sw_params_current(snd_pcm_t *pcm, snd_pcm_sw_params_t *params) { return 0; }
static inline int snd_pcm_sw_params_set_start_threshold(snd_pcm_t *pcm, snd_pcm_sw_params_t *params, snd_pcm_uframes_t val) { return 0; }
static inline int snd_pcm_sw_params_set_avail_min(snd_pcm_t *pcm, snd_pcm_sw_params_t *params, snd_pcm_uframes_t val) { return 0; }
static inline int snd_pcm_sw_params(snd_pcm_t *pcm, snd_pcm_sw_params_t *params) { return 0; }
static inline int snd_pcm_hw_params_get_channels(const snd_pcm_hw_params_t *params, unsigned int *val) { return 0; }
static inline int snd_pcm_close(snd_pcm_t *pcm) { return 0; }
static inline int snd_pcm_start(snd_pcm_t *pcm) { return 0; }
static inline int snd_pcm_drain(snd_pcm_t *pcm) { return 0; }
static inline snd_pcm_sframes_t snd_pcm_readi(snd_pcm_t *pcm, void *buffer, snd_pcm_uframes_t size) { return 0; }
static inline int snd_pcm_recover(snd_pcm_t *pcm, int err, int silent) { return 0; }
static inline int snd_pcm_hw_params_get_buffer_time(const snd_pcm_hw_params_t *params, unsigned int *val, int *dir) { return 0; }
static inline int snd_pcm_hw_params_set_period_time_near(snd_pcm_t *pcm, snd_pcm_hw_params_t *params, unsigned int *val, int *dir) { return 0; }
static inline const char* snd_pcm_name(snd_pcm_t *pcm) { return ""; }
static inline const char* snd_pcm_state_name(int state) { return ""; }
static inline int snd_pcm_state(snd_pcm_t *pcm) { return 0; }
static inline int snd_pcm_hw_params_get_rate(const snd_pcm_hw_params_t *params, unsigned int *val, int *dir) { return 0; }
static inline int snd_pcm_hw_params_get_period_time(const snd_pcm_hw_params_t *params, unsigned int *val, int *dir) { return 0; }
static inline void* snd_async_handler_get_callback_private(snd_async_handler_t *handler) { return 0; }
static inline int snd_async_add_pcm_handler(snd_async_handler_t **handler, snd_pcm_t *pcm, void *callback, void *private_data) { return 0; }
static inline int snd_pcm_pause(snd_pcm_t *pcm, int enable) { return 0; }
static inline snd_pcm_sframes_t snd_pcm_writei(snd_pcm_t *pcm, const void *buffer, snd_pcm_uframes_t size) { return 0; }
static inline int snd_pcm_delay(snd_pcm_t *pcm, snd_pcm_sframes_t *delayp) { return 0; }
static inline int snd_pcm_hw_params_any(snd_pcm_t *pcm, snd_pcm_hw_params_t *params) { return 0; }
static inline int snd_pcm_hw_params_set_access(snd_pcm_t *pcm, snd_pcm_hw_params_t *params, int access) { return 0; }
static inline int snd_pcm_hw_params_set_format(snd_pcm_t *pcm, snd_pcm_hw_params_t *params, int format) { return 0; }
static inline int snd_pcm_hw_params_set_channels(snd_pcm_t *pcm, snd_pcm_hw_params_t *params, unsigned int val) { return 0; }
static inline int snd_pcm_hw_params_set_rate_near(snd_pcm_t *pcm, snd_pcm_hw_params_t *params, unsigned int *val, int *dir) { return 0; }

typedef void* snd_mixer_t;
typedef void* snd_mixer_selem_id_t;
typedef void* snd_mixer_elem_t;
static inline int snd_mixer_open(snd_mixer_t **mixer, int mode) { return 0; }
static inline int snd_mixer_attach(snd_mixer_t *mixer, const char *name) { return 0; }
static inline int snd_mixer_selem_register(snd_mixer_t *mixer, void *options, void *classp) { return 0; }
static inline int snd_mixer_load(snd_mixer_t *mixer) { return 0; }
static inline int snd_mixer_selem_id_malloc(snd_mixer_selem_id_t **ptr) { return 0; }
static inline void snd_mixer_selem_id_set_index(snd_mixer_selem_id_t *obj, unsigned int val) {}
static inline void snd_mixer_selem_id_set_name(snd_mixer_selem_id_t *obj, const char *val) {}
static inline snd_mixer_elem_t* snd_mixer_find_selem(snd_mixer_t *mixer, const snd_mixer_selem_id_t *id) { return 0; }
static inline int snd_mixer_selem_get_playback_volume_range(snd_mixer_elem_t *elem, long *min, long *max) { return 0; }
static inline int snd_mixer_selem_set_playback_volume_all(snd_mixer_elem_t *elem, long value) { return 0; }
static inline int snd_mixer_close(snd_mixer_t *mixer) { return 0; }
static inline void snd_mixer_selem_id_free(snd_mixer_selem_id_t *obj) {}
#endif
EOF
      cat << 'EOF' > $NIX_BUILD_TOP/darwin_headers/elf.h
#ifndef ELF_H
#define ELF_H
#endif
EOF
      cat << 'EOF' > $NIX_BUILD_TOP/darwin_headers/link.h
#ifndef LINK_H
#define LINK_H
struct r_debug {};
typedef struct { int d_tag; union { void* d_ptr; } d_un; } ElfW_Dyn;
#define ElfW(type) ElfW_##type
#define DT_DEBUG 21
#endif
EOF
      export CFLAGS="-I$NIX_BUILD_TOP/darwin_headers -Wno-int-conversion -Wno-c23-extensions -Doff64_t=off_t -Dlseek64=lseek -Dftruncate64=ftruncate -Dpread64=pread -Dpwrite64=pwrite -DCLOCK_BOOTTIME=CLOCK_MONOTONIC $CFLAGS"
      substituteInPlace src/main-executable/main.c \
        --replace-warn "__attribute__((section(\".interp\")))" ""
    '';
    postInstall = (old.postInstall or "") + ''
      mkdir -p $out/etc/security
      ln -s ${cacert.unbundled}/etc/ssl/certs $out/etc/security/cacerts
    '';
    preFixup = (old.preFixup or "") + ''
      mkdir -p $out/lib/gdk-pixbuf-2.0/2.10.0
      GDK_PIXBUF_MODULEDIR=${gdk-pixbuf}/lib/gdk-pixbuf-2.0/2.10.0/loaders ${gdk-pixbuf.dev}/bin/gdk-pixbuf-query-loaders > $out/lib/gdk-pixbuf-2.0/2.10.0/loaders.cache
      cat ${librsvg}/lib/gdk-pixbuf-2.0/2.10.0/loaders.cache >> $out/lib/gdk-pixbuf-2.0/2.10.0/loaders.cache
      GDK_PIXBUF_MODULEDIR=${webp-pixbuf-loader}/lib/gdk-pixbuf-2.0/2.10.0/loaders ${gdk-pixbuf.dev}/bin/gdk-pixbuf-query-loaders >> $out/lib/gdk-pixbuf-2.0/2.10.0/loaders.cache

      gappsWrapperArgs+=(
        --set ANDROID_ROOT $out
        --set GDK_PIXBUF_MODULE_FILE $out/lib/gdk-pixbuf-2.0/2.10.0/loaders.cache
      )
    '';
    postFixup = (old.postFixup or "") + lib.optionalString stdenv.isDarwin ''
      install_name_tool -add_rpath ${art-standalone_patched}/lib $out/bin/.android-translation-layer-wrapped || true
      install_name_tool -add_rpath ${art-standalone_patched}/lib $out/lib/java/dex/android_translation_layer/natives/libtranslation_layer_main.dylib || true
    '';
  })
