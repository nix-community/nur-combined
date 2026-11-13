/* Vulkan SurfaceView support.
 *
 * MoltenVK and KosmicKrisp only accept a view whose -layer is a CAMetalLayer, and
 * GTK's window content view is a rendering layer of its own (GdkMacosLayer for the
 * cairo/gl renderers), so the surface needs a dedicated view: a CAMetalLayer-backed
 * NSView positioned over the SurfaceView widget, exactly like webview.m clips its
 * WKWebView to the widget bounds. */
#include <gtk/gtk.h>
#include <gdk/macos/gdkmacos.h>
#import <AppKit/AppKit.h>
#import <QuartzCore/QuartzCore.h>
#include <vulkan/vulkan.h>
#include <vulkan/vulkan_metal.h>
#include <vulkan/vulkan_macos.h>

typedef struct {
    GtkWidget *widget;
    CFTypeRef view;
    guint tick;
} ATLSurfaceOverlay;

static GHashTable *surface_overlays;

static NSView *overlay_view(ATLSurfaceOverlay *overlay) { return (__bridge NSView *)overlay->view; }

static void on_main_thread(void (^work)(void)) {
    if ([NSThread isMainThread]) work();
    else dispatch_sync(dispatch_get_main_queue(), work);
}

/* The SurfaceView widget is only visible through its ancestors: clip to them. */
static void overlay_update(ATLSurfaceOverlay *overlay) {
    GtkWidget *widget = overlay->widget;
    NSView *view = overlay_view(overlay);
    GtkNative *native = gtk_widget_get_native(widget);
    if (!gtk_widget_get_mapped(widget) || !native) { [view removeFromSuperview]; return; }
    GdkSurface *surface = gtk_native_get_surface(native);
    if (!GDK_IS_MACOS_SURFACE(surface)) return;
    NSWindow *window = (__bridge NSWindow *)gdk_macos_surface_get_native_window(GDK_MACOS_SURFACE(surface));
    NSView *container = window.contentView;
    graphene_rect_t full;
    if (!container || !gtk_widget_compute_bounds(widget, GTK_WIDGET(native), &full)) return;
    graphene_rect_t visible = full;
    for (GtkWidget *parent = gtk_widget_get_parent(widget); parent; parent = gtk_widget_get_parent(parent)) {
        graphene_rect_t rect;
        if (gtk_widget_compute_bounds(parent, GTK_WIDGET(native), &rect)) {
            if (!graphene_rect_intersection(&visible, &rect, &visible)) { view.hidden = YES; return; }
        }
        if (parent == GTK_WIDGET(native)) break;
    }
    NSRect frame = NSMakeRect(visible.origin.x, visible.origin.y, visible.size.width, visible.size.height);
    if (!container.isFlipped) frame.origin.y = container.bounds.size.height-NSMaxY(frame);
    if (view.superview != container) { [view removeFromSuperview]; [container addSubview:view]; }
    view.hidden = NO; view.frame = frame;
    /* CAMetalLayer derives drawableSize from bounds * contentsScale. */
    CAMetalLayer *layer = (CAMetalLayer *)view.layer;
    CGFloat scale = window.backingScaleFactor;
    if (layer.contentsScale != scale) layer.contentsScale = scale;
}

static gboolean overlay_tick(GtkWidget *widget, GdkFrameClock *clock, gpointer data) {
    overlay_update(data);
    return G_SOURCE_CONTINUE;
}

static void overlay_free(gpointer data) {
    ATLSurfaceOverlay *overlay = data;
    [overlay_view(overlay) removeFromSuperview];
    CFRelease(overlay->view);
    g_free(overlay);
}

/* The tick callback goes away with the widget, which takes the overlay with it. */
static void overlay_detach(gpointer data) {
    ATLSurfaceOverlay *overlay = data;
    if (surface_overlays) g_hash_table_remove(surface_overlays, overlay->widget);
}

static ATLSurfaceOverlay *overlay_for(GtkWidget *widget) {
    if (!surface_overlays)
        surface_overlays = g_hash_table_new_full(g_direct_hash, g_direct_equal, NULL, overlay_free);
    ATLSurfaceOverlay *overlay = g_hash_table_lookup(surface_overlays, widget);
    if (overlay) return overlay;
    overlay = g_new0(ATLSurfaceOverlay, 1);
    overlay->widget = widget;
    NSView *view = [[NSView alloc] initWithFrame:NSZeroRect];
    view.wantsLayer = YES;
    CAMetalLayer *layer = [CAMetalLayer layer];
    layer.opaque = YES;
    view.layer = layer;
    overlay->view = CFBridgingRetain(view);
    overlay->tick = gtk_widget_add_tick_callback(widget, overlay_tick, overlay, overlay_detach);
    g_hash_table_insert(surface_overlays, widget, overlay);
    overlay_update(overlay);
    return overlay;
}

/* Called by bionic_vkCreateAndroidSurfaceKHR for the macOS GDK backend. */
VkResult atl_darwin_create_android_surface(VkInstance instance, GtkWidget *surface_view_widget,
                                           const VkAllocationCallbacks *allocator, VkSurfaceKHR *surface)
{
    if (!instance || !surface_view_widget || !surface) return VK_ERROR_INITIALIZATION_FAILED;
    __block ATLSurfaceOverlay *overlay = NULL;
    on_main_thread(^{ overlay = overlay_for(surface_view_widget); });
    if (!overlay) return VK_ERROR_INITIALIZATION_FAILED;
    NSView *view = overlay_view(overlay);
    CAMetalLayer *layer = (CAMetalLayer *)view.layer;
    if (![layer isKindOfClass:[CAMetalLayer class]]) return VK_ERROR_INITIALIZATION_FAILED;

    /* VK_EXT_metal_surface supersedes VK_MVK_macos_surface; use what the ICD exposes. */
    PFN_vkCreateMetalSurfaceEXT create_metal_surface = (PFN_vkCreateMetalSurfaceEXT)vkGetInstanceProcAddr(instance, "vkCreateMetalSurfaceEXT");
    if (create_metal_surface) {
        VkMetalSurfaceCreateInfoEXT info = {
            .sType = VK_STRUCTURE_TYPE_METAL_SURFACE_CREATE_INFO_EXT,
            .pLayer = layer,
        };
        VkResult result = create_metal_surface(instance, &info, allocator, surface);
        if (result != VK_ERROR_EXTENSION_NOT_PRESENT) return result;
    }
    PFN_vkCreateMacOSSurfaceMVK create_macos_surface = (PFN_vkCreateMacOSSurfaceMVK)vkGetInstanceProcAddr(instance, "vkCreateMacOSSurfaceMVK");
    if (create_macos_surface) {
        VkMacOSSurfaceCreateInfoMVK info = {
            .sType = VK_STRUCTURE_TYPE_MACOS_SURFACE_CREATE_INFO_MVK,
            .pView = (const void *)(__bridge void *)view,
        };
        return create_macos_surface(instance, &info, allocator, surface);
    }
    return VK_ERROR_EXTENSION_NOT_PRESENT;
}
