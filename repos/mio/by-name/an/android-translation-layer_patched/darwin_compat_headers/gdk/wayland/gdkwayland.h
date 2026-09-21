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
