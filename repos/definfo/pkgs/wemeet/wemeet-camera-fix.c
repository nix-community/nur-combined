/*
 * wemeet-camera-fix — LD_PRELOAD shim
 *
 * Problem: wemeet's libxcast.so does its own EGL setup for video rendering.
 * It only links libEGL + libX11 (no libwayland-*), so it assumes
 *   eglGetDisplay(NULL) returns an X11 EGL display
 * and that the native window it later passes to eglCreateWindowSurface is an
 * X11 XID.
 *
 * When wemeet runs in a wayland session with WAYLAND_DISPLAY set, Mesa's
 * libEGL picks the wayland platform for default-display calls. xcast then
 * passes an X11 XID to eglCreateWindowSurface, Mesa dereferences it as
 * wl_egl_window* inside dri2_wl_create_window_surface → SIGSEGV.
 *
 * Fix: intercept eglGetDisplay / eglGetPlatformDisplay[EXT]. If the caller is
 * libxcast.so, return an EGLDisplay we obtained via
 * eglGetPlatformDisplay(EGL_PLATFORM_X11_KHR, XOpenDisplay(NULL), NULL).
 * Other callers (Qt wayland platform, QtWebEngine GPU process, …) pass
 * through unchanged.
 *
 * Minimal goal: do not SIGSEGV on camera open.
 * Stretch goal (uncertain): actually render preview. xcast also needs a real
 * X11 native window to draw into; in Qt-wayland mode there might not be one.
 *
 * Env: set WEMEET_CAM_FIX_DEBUG=1 to log on stderr.
 */

#define _GNU_SOURCE
#include <dlfcn.h>
#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <EGL/egl.h>
#include <EGL/eglext.h>
#include <X11/Xlib.h>

#ifndef EGL_PLATFORM_X11_KHR
#define EGL_PLATFORM_X11_KHR 0x31D5
#endif

typedef EGLDisplay (*pfn_eglGetDisplay_t)(EGLNativeDisplayType);
typedef EGLDisplay (*pfn_eglGetPlatformDisplay_t)(EGLenum, void*, const EGLAttrib*);
typedef EGLDisplay (*pfn_eglGetPlatformDisplayEXT_t)(EGLenum, void*, const EGLint*);

static pfn_eglGetDisplay_t            real_eglGetDisplay;
static pfn_eglGetPlatformDisplay_t    real_eglGetPlatformDisplay;
static pfn_eglGetPlatformDisplayEXT_t real_eglGetPlatformDisplayEXT;

static EGLDisplay xcast_x11_egl = EGL_NO_DISPLAY;
static Display*   xcast_x_display;
static pthread_once_t once_resolve = PTHREAD_ONCE_INIT;
static pthread_once_t once_x11     = PTHREAD_ONCE_INIT;

static int dbg_enabled(void) {
    static int v = -1;
    if (v < 0) v = (getenv("WEMEET_CAM_FIX_DEBUG") != NULL);
    return v;
}

#define LOG(...) do { if (dbg_enabled()) fprintf(stderr, "[wcam-fix] " __VA_ARGS__); } while (0)

static void resolve_reals(void) {
    real_eglGetDisplay            = (pfn_eglGetDisplay_t)            dlsym(RTLD_NEXT, "eglGetDisplay");
    real_eglGetPlatformDisplay    = (pfn_eglGetPlatformDisplay_t)    dlsym(RTLD_NEXT, "eglGetPlatformDisplay");
    real_eglGetPlatformDisplayEXT = (pfn_eglGetPlatformDisplayEXT_t) dlsym(RTLD_NEXT, "eglGetPlatformDisplayEXT");
    LOG("resolved: eglGetDisplay=%p eglGetPlatformDisplay=%p EXT=%p\n",
        (void*)real_eglGetDisplay, (void*)real_eglGetPlatformDisplay,
        (void*)real_eglGetPlatformDisplayEXT);
}

static void init_x11_egl(void) {
    pthread_once(&once_resolve, resolve_reals);
    xcast_x_display = XOpenDisplay(NULL);
    if (!xcast_x_display) {
        fprintf(stderr, "[wcam-fix] XOpenDisplay(NULL) failed; DISPLAY=%s\n",
                getenv("DISPLAY") ? getenv("DISPLAY") : "(unset)");
        return;
    }
    if (real_eglGetPlatformDisplay) {
        xcast_x11_egl = real_eglGetPlatformDisplay(EGL_PLATFORM_X11_KHR,
                                                   xcast_x_display, NULL);
    } else if (real_eglGetPlatformDisplayEXT) {
        xcast_x11_egl = real_eglGetPlatformDisplayEXT(EGL_PLATFORM_X11_KHR,
                                                      xcast_x_display, NULL);
    } else if (real_eglGetDisplay) {
        xcast_x11_egl = real_eglGetDisplay((EGLNativeDisplayType)xcast_x_display);
    }
    LOG("X11 EGLDisplay=%p (X Display*=%p)\n",
        (void*)xcast_x11_egl, (void*)xcast_x_display);
}

static int caller_is_xcast(void* caller) {
    if (!caller) return 0;
    Dl_info info;
    memset(&info, 0, sizeof(info));
    if (!dladdr(caller, &info) || !info.dli_fname) return 0;
    return strstr(info.dli_fname, "libxcast.so") != NULL;
}

EGLDisplay eglGetDisplay(EGLNativeDisplayType display_id) {
    pthread_once(&once_resolve, resolve_reals);
    void* caller = __builtin_return_address(0);
    if (caller_is_xcast(caller)) {
        pthread_once(&once_x11, init_x11_egl);
        LOG("eglGetDisplay from xcast → X11 EGLDisplay=%p\n", (void*)xcast_x11_egl);
        return xcast_x11_egl;
    }
    return real_eglGetDisplay ? real_eglGetDisplay(display_id) : EGL_NO_DISPLAY;
}

EGLDisplay eglGetPlatformDisplay(EGLenum platform, void* native_display,
                                  const EGLAttrib* attrib_list) {
    pthread_once(&once_resolve, resolve_reals);
    void* caller = __builtin_return_address(0);
    if (caller_is_xcast(caller)) {
        pthread_once(&once_x11, init_x11_egl);
        LOG("eglGetPlatformDisplay(0x%x) from xcast → X11 EGLDisplay=%p\n",
            platform, (void*)xcast_x11_egl);
        return xcast_x11_egl;
    }
    return real_eglGetPlatformDisplay
        ? real_eglGetPlatformDisplay(platform, native_display, attrib_list)
        : EGL_NO_DISPLAY;
}

EGLDisplay eglGetPlatformDisplayEXT(EGLenum platform, void* native_display,
                                     const EGLint* attrib_list) {
    pthread_once(&once_resolve, resolve_reals);
    void* caller = __builtin_return_address(0);
    if (caller_is_xcast(caller)) {
        pthread_once(&once_x11, init_x11_egl);
        LOG("eglGetPlatformDisplayEXT(0x%x) from xcast → X11 EGLDisplay=%p\n",
            platform, (void*)xcast_x11_egl);
        return xcast_x11_egl;
    }
    return real_eglGetPlatformDisplayEXT
        ? real_eglGetPlatformDisplayEXT(platform, native_display, attrib_list)
        : EGL_NO_DISPLAY;
}
