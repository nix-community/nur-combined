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
