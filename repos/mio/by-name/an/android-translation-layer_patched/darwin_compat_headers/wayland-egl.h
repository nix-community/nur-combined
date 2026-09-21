#ifndef WAYLAND_EGL_H
#define WAYLAND_EGL_H
#include <wayland-client.h>
struct wl_egl_window {};
#define wl_egl_window_create(...) NULL
#define wl_egl_window_destroy(...)
#define wl_egl_window_resize(...)
#endif
