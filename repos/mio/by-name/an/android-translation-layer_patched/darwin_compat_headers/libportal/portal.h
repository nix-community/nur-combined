#ifndef PORTAL_H
#define PORTAL_H
typedef struct XdpPortal XdpPortal;
#define XDP_OPEN_URI_FLAG_NONE 0
#define XDP_LAUNCHER_APPLICATION 0
#define XDP_PORTAL(x) ((XdpPortal*)(x))
#define XDP_WALLPAPER_FLAG_NONE 0
static inline XdpPortal* xdp_portal_new(void) { return 0; }
static inline void xdp_portal_open_uri(XdpPortal* p1, void* p2, const char* p3, int p4, void* p5, void* p6, void* p7) {}
static inline void xdp_portal_location_monitor_start(XdpPortal* p1, void* p2, int p3, int p4, int p5, int p6, void* p7, void* p8, void* p9) {}
static inline void xdp_portal_set_wallpaper_finish(XdpPortal* p1, void* p2, void* p3) {}
static inline void xdp_portal_set_wallpaper(XdpPortal* p1, void* p2, void* p3, int p4, void* p5, void* p6, void* p7) {}
static inline void* xdp_portal_dynamic_launcher_prepare_install_finish(XdpPortal* p1, void* p2, void* p3) { return 0; }
static inline void xdp_portal_dynamic_launcher_install(XdpPortal* p1, void* p2, void* p3, void* p4, void* p5) {}
static inline void xdp_portal_dynamic_launcher_prepare_install(XdpPortal* p1, void* p2, void* p3, void* p4, void* p5, void* p6, int p7, int p8, void* p9, void* p10, void* p11) {}
#endif
