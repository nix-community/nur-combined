#import "host.h"
#import <WebKit/WebKit.h>
#import <QuartzCore/QuartzCore.h>
#include <gdk/macos/gdkmacos.h>
#include <androidfw/androidfw_c_api.h>
#include "../widgets/WrapperWidget.h"
#include "../generated_headers/android_view_View.h"

typedef struct { GtkWidget parent; CFTypeRef webview, delegate, clip; } ATLWebView;
typedef struct { GtkWidgetClass parent; } ATLWebViewClass;
G_DEFINE_TYPE(ATLWebView, atl_webview, GTK_TYPE_WIDGET)
static WKWebView *webview(ATLWebView *self) { return (__bridge WKWebView *)self->webview; }
static WrapperWidget *wrapper_for(GtkWidget *widget) {
    GtkWidget *parent = widget ? gtk_widget_get_parent(widget) : NULL;
    return parent && WRAPPER_IS_WIDGET(parent) ? WRAPPER_WIDGET(parent) : NULL;
}
@interface ATLWebDelegate : NSObject <WKNavigationDelegate, WKUIDelegate, WKURLSchemeHandler>
@property (assign) GtkWidget *widget;
@end
@implementation ATLWebDelegate
- (void)loadChanged:(int)state webView:(WKWebView *)view {
    WrapperWidget *wrapper = wrapper_for(self.widget);
    if (!wrapper) return;
    atl_callback(^(JNIEnv *env) { J__WebView__internalLoadChanged(env, wrapper->jobj, state, atl_jstring(env, view.URL.absoluteString ?: @"about:blank")); });
}
- (void)webView:(WKWebView *)view didStartProvisionalNavigation:(WKNavigation *)navigation { [self loadChanged:0 webView:view]; }
- (void)webView:(WKWebView *)view didFinishNavigation:(WKNavigation *)navigation { [self loadChanged:3 webView:view]; }
- (void)webView:(WKWebView *)view didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    g_warning("WebView navigation: %s", error.localizedDescription.UTF8String); [self loadChanged:3 webView:view];
}
- (void)webView:(WKWebView *)view didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    if (error.code != NSURLErrorCancelled) { g_warning("WebView load: %s", error.localizedDescription.UTF8String); [self loadChanged:3 webView:view]; }
}
- (void)webView:(WKWebView *)view decidePolicyForNavigationAction:(WKNavigationAction *)action decisionHandler:(void (^)(WKNavigationActionPolicy))done {
    WrapperWidget *wrapper = wrapper_for(self.widget);
    __block BOOL overridden = NO;
    if (wrapper) atl_callback(^(JNIEnv *env) {
        overridden = J__WebView__internalShouldOverrideUrlLoading(env, wrapper->jobj, atl_jstring(env, action.request.URL.absoluteString));
    });
    done(overridden ? WKNavigationActionPolicyCancel : WKNavigationActionPolicyAllow);
}
- (WKWebView *)webView:(WKWebView *)view createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)action windowFeatures:(WKWindowFeatures *)features {
    if (!action.targetFrame) [view loadRequest:action.request];
    return nil;
}
- (void)webView:(WKWebView *)view startURLSchemeTask:(id<WKURLSchemeTask>)task {
    WrapperWidget *wrapper = wrapper_for(self.widget);
    __block NSData *data;
    NSString *path = task.request.URL.path;
    if ([path hasPrefix:@"/"]) path = [path substringFromIndex:1];
    if (wrapper) atl_callback(^(JNIEnv *env) {
        jobject manager = J__WebView__internalGetAssetManager(env, wrapper->jobj);
        if (!manager) return;
        struct AssetManager *assets = _PTR(_GET_LONG_FIELD(manager, "mObject"));
        struct Asset *asset = AssetManager_openNonAsset(assets, path.UTF8String, ACCESS_BUFFER);
        if (!asset) return;
        off64_t length = Asset_getLength(asset);
        if (length >= 0) {
            void *buffer = g_try_malloc(MAX((gsize)length, 1));
            if (buffer && Asset_read(asset, buffer, length) == length) data = [NSData dataWithBytes:buffer length:length];
            g_free(buffer);
        }
        Asset_delete(asset);
    });
    if (!data) { [task didFailWithError:[NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorFileDoesNotExist userInfo:nil]]; return; }
    NSString *mime = @"application/octet-stream";
    NSDictionary *types = @{ @"html": @"text/html", @"htm": @"text/html", @"js": @"text/javascript", @"css": @"text/css", @"png": @"image/png", @"jpg": @"image/jpeg", @"jpeg": @"image/jpeg", @"svg": @"image/svg+xml", @"json": @"application/json", @"woff": @"font/woff", @"woff2": @"font/woff2" };
    mime = types[path.pathExtension.lowercaseString] ?: mime;
    [task didReceiveResponse:[[NSURLResponse alloc] initWithURL:task.request.URL MIMEType:mime expectedContentLength:data.length textEncodingName:nil]];
    [task didReceiveData:data]; [task didFinish];
}
- (void)webView:(WKWebView *)view stopURLSchemeTask:(id<WKURLSchemeTask>)task { /* Asset reads complete synchronously. */ }
@end
static void update_geometry(ATLWebView *self) {
    GtkWidget *widget = GTK_WIDGET(self);
    GtkNative *native = gtk_widget_get_native(widget);
    NSView *clip = (__bridge NSView *)self->clip;
    if (!gtk_widget_get_mapped(widget) || !native) { [clip removeFromSuperview]; return; }
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
            if (!graphene_rect_intersection(&visible, &rect, &visible)) { clip.hidden = YES; return; }
        }
        if (parent == GTK_WIDGET(native)) break;
    }
    NSRect frame = NSMakeRect(visible.origin.x, visible.origin.y, visible.size.width, visible.size.height);
    if (!container.isFlipped) frame.origin.y = container.bounds.size.height-NSMaxY(frame);
    if (clip.superview != container) { [clip removeFromSuperview]; [container addSubview:clip]; }
    clip.hidden = NO; clip.frame = frame;
    CGFloat x = full.origin.x-visible.origin.x;
    CGFloat y = container.isFlipped ? full.origin.y-visible.origin.y : visible.origin.y+visible.size.height-full.origin.y-full.size.height;
    webview(self).frame = NSMakeRect(x, y, full.size.width, full.size.height);
}
static gboolean tick(GtkWidget *widget, GdkFrameClock *clock, gpointer unused) { update_geometry((ATLWebView *)widget); return G_SOURCE_CONTINUE; }
static void mapped(GtkWidget *widget) { GTK_WIDGET_CLASS(atl_webview_parent_class)->map(widget); update_geometry((ATLWebView *)widget); }
static void unmapped(GtkWidget *widget) { [(__bridge NSView *)((ATLWebView *)widget)->clip removeFromSuperview]; GTK_WIDGET_CLASS(atl_webview_parent_class)->unmap(widget); }
static void allocated(GtkWidget *widget, int width, int height, int baseline) { update_geometry((ATLWebView *)widget); }
static void measure(GtkWidget *widget, GtkOrientation orientation, int for_size, int *minimum, int *natural, int *min_baseline, int *nat_baseline) {
    *minimum = 0; *natural = orientation == GTK_ORIENTATION_HORIZONTAL ? 320 : 240;
    *min_baseline = *nat_baseline = -1;
}
static void disposed(GObject *object) {
    ATLWebView *self = (ATLWebView *)object;
    if (self->webview) {
        ATLWebDelegate *delegate = (__bridge ATLWebDelegate *)self->delegate;
        delegate.widget = NULL;
        [webview(self) stopLoading]; webview(self).navigationDelegate = nil; webview(self).UIDelegate = nil;
        [(__bridge NSView *)self->clip removeFromSuperview];
        CFRelease(self->webview); CFRelease(self->delegate); CFRelease(self->clip);
        self->webview = self->delegate = self->clip = NULL;
    }
    G_OBJECT_CLASS(atl_webview_parent_class)->dispose(object);
}
static void atl_webview_class_init(ATLWebViewClass *cls) {
    GtkWidgetClass *widget = GTK_WIDGET_CLASS(cls);
    widget->map = mapped; widget->unmap = unmapped; widget->size_allocate = allocated; widget->measure = measure;
    G_OBJECT_CLASS(cls)->dispose = disposed;
    gtk_widget_class_set_css_name(widget, "atl-webview");
}
static void atl_webview_init(ATLWebView *self) {
    ATLWebDelegate *delegate = [ATLWebDelegate new]; delegate.widget = GTK_WIDGET(self);
    WKWebViewConfiguration *config = [WKWebViewConfiguration new];
    [config setURLSchemeHandler:delegate forURLScheme:@"android-asset"];
    WKWebView *view = [[WKWebView alloc] initWithFrame:NSZeroRect configuration:config];
    view.navigationDelegate = delegate; view.UIDelegate = delegate;
    NSView *clip = [[NSView alloc] initWithFrame:NSZeroRect]; clip.wantsLayer = YES; clip.layer.masksToBounds = YES;
    [clip addSubview:view];
    self->webview = CFBridgingRetain(view); self->delegate = CFBridgingRetain(delegate); self->clip = CFBridgingRetain(clip);
    gtk_widget_set_hexpand(GTK_WIDGET(self), TRUE); gtk_widget_set_vexpand(GTK_WIDGET(self), TRUE);
    gtk_widget_add_tick_callback(GTK_WIDGET(self), tick, NULL, NULL);
}
GtkWidget *atl_webview_new(void) { return g_object_new(atl_webview_get_type(), NULL); }
WKWebView *atl_webview_native(GtkWidget *widget) { return webview((ATLWebView *)widget); }
JNIEXPORT jlong JNICALL Java_android_webkit_WebView_native_1constructor(JNIEnv *env, jobject this, jobject context, jobject attrs) {
    if (!getenv("ATL_UGLY_ENABLE_WEBVIEW")) return Java_android_view_View_native_1constructor(env, this, context, attrs);
    GtkWidget *wrapper = g_object_ref(wrapper_widget_new());
    GtkWidget *view = atl_webview_new();
    wrapper_widget_set_child(WRAPPER_WIDGET(wrapper), view);
    wrapper_widget_set_jobject(WRAPPER_WIDGET(wrapper), env, this);
    wrapper_widget_register_invalidation_listener(WRAPPER_WIDGET(wrapper));
    return _INTPTR(view);
}
JNIEXPORT void JNICALL Java_android_webkit_WebView_native_1loadUrl(JNIEnv *env, jobject this, jlong pointer, jstring url) {
    if (!getenv("ATL_UGLY_ENABLE_WEBVIEW")) return;
    NSString *text = atl_string(env, url);
    WKWebView *view = webview(_PTR(pointer));
    if ([text hasPrefix:@"javascript:"]) [view evaluateJavaScript:[text substringFromIndex:11] completionHandler:nil];
    else { NSURL *target = [NSURL URLWithString:text]; if (target) [view loadRequest:[NSURLRequest requestWithURL:target]]; }
}
JNIEXPORT void JNICALL Java_android_webkit_WebView_native_1loadDataWithBaseURL(JNIEnv *env, jobject this, jlong pointer, jstring base, jstring text, jstring mime, jstring encoding) {
    if (!getenv("ATL_UGLY_ENABLE_WEBVIEW")) return;
    NSString *content = atl_string(env, text) ?: @"", *type = atl_string(env, mime) ?: @"text/html";
    NSURL *url = [NSURL URLWithString:atl_string(env, base) ?: @"about:blank"];
    [webview(_PTR(pointer)) loadData:[content dataUsingEncoding:NSUTF8StringEncoding] MIMEType:type characterEncodingName:@"UTF-8" baseURL:url];
}
JNIEXPORT void JNICALL Java_android_webkit_WebView_native_1stopLoading(JNIEnv *env, jobject this, jlong pointer) {
    if (getenv("ATL_UGLY_ENABLE_WEBVIEW")) [webview(_PTR(pointer)) stopLoading];
}
JNIEXPORT void JNICALL Java_android_webkit_WebView_native_1evaluateJavascript(JNIEnv *env, jobject this, jlong pointer, jstring script, jobject callback) {
    if (!getenv("ATL_UGLY_ENABLE_WEBVIEW")) return;
    NSString *code = atl_string(env, script);
    jobject retained = callback ? (*env)->NewGlobalRef(env, callback) : NULL;
    [webview(_PTR(pointer)) evaluateJavaScript:code completionHandler:^(id result, NSError *error) {
        atl_callback(^(JNIEnv *env) {
            if (retained) {
                NSString *json = @"null";
                if (result && !error) {
                    NSData *data = [NSJSONSerialization dataWithJSONObject:result options:NSJSONWritingFragmentsAllowed error:nil];
                    if (data) json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                }
                jmethodID method = (*env)->GetMethodID(env, (*env)->GetObjectClass(env, retained), "onReceiveValue", "(Ljava/lang/Object;)V");
                if (method) (*env)->CallVoidMethod(env, retained, method, atl_jstring(env, json));
                (*env)->DeleteGlobalRef(env, retained);
            }
        });
    }];
}
