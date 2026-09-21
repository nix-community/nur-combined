import os

dummy_dir = "/tmp/darwin_headers"
os.makedirs(dummy_dir, exist_ok=True)

def write_header(path, content):
    full_path = os.path.join(dummy_dir, path)
    os.makedirs(os.path.dirname(full_path), exist_ok=True)
    with open(full_path, 'w') as f:
        f.write(content)

write_header("uchar.h", """
#ifndef UCHAR_H
#define UCHAR_H
#include <stdint.h>
typedef uint_least16_t char16_t;
typedef uint_least32_t char32_t;
#endif
""")

write_header("gdk/wayland/gdkwayland.h", """
#ifndef GDK_WAYLAND_H
#define GDK_WAYLAND_H
#define GDK_IS_WAYLAND_DISPLAY(display) (0)
#define gdk_wayland_display_get_wl_display(display) NULL
#define gdk_wayland_display_get_wl_compositor(display) NULL
#define gdk_wayland_surface_get_wl_surface(surface) NULL
#endif
""")

write_header("gdk/x11/gdkx.h", """
#ifndef GDK_X11_H
#define GDK_X11_H
#define GDK_IS_X11_DISPLAY(display) (0)
#endif
""")

write_header("wayland-client.h", """
#ifndef WAYLAND_CLIENT_H
#define WAYLAND_CLIENT_H
struct wl_display {};
struct wl_compositor {};
struct wl_surface {};
struct wl_subsurface {};
struct wl_region {};
struct wl_registry {};
#define wl_display_get_registry(...) NULL
#define wl_registry_add_listener(...)
#define wl_display_roundtrip(...)
#define wl_compositor_create_surface(...) NULL
#define wl_subcompositor_get_subsurface(...) NULL
#define wl_subsurface_set_desync(...)
#define wl_subsurface_set_position(...)
#define wl_compositor_create_region(...) NULL
#define wl_surface_set_input_region(...)
#define wl_region_destroy(...)
#define wl_surface_destroy(...)
#endif
""")

write_header("wayland-egl.h", """
#ifndef WAYLAND_EGL_H
#define WAYLAND_EGL_H
struct wl_egl_window {};
#define wl_egl_window_create(...) NULL
#define wl_egl_window_destroy(...)
#define wl_egl_window_resize(...)
#endif
""")

write_header("X11/Xlib.h", """
#ifndef XLIB_H
#define XLIB_H
typedef void* Display;
typedef unsigned long Window;
#define XDestroyWindow(...)
#define XResizeWindow(...)
#endif
""")

write_header("X11/Xutil.h", "")
write_header("X11/extensions/shape.h", "")

write_header("vulkan/vulkan_wayland.h", """
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
""")

write_header("vulkan/vulkan_xlib.h", """
#ifndef VULKAN_XLIB_H
#define VULKAN_XLIB_H
#include <vulkan/vulkan.h>
typedef struct VkXlibSurfaceCreateInfoKHR {
    int sType;
    void* dpy;
    void* window;
} VkXlibSurfaceCreateInfoKHR;
#define VK_STRUCTURE_TYPE_XLIB_SURFACE_CREATE_INFO_KHR 0
#define vkCreateXlibSurfaceKHR(...) VK_ERROR_EXTENSION_NOT_PRESENT
#endif
""")

