#import <AppKit/AppKit.h>
#import <WebKit/WebKit.h>
#include <gtk/gtk.h>
#include <assert.h>
#include <stdio.h>
GtkWindow *window;
char *apk_path;
GThread *main_thread_id;
/* Main-executable glue, unused by the widget/input tests. */
char *get_app_data_dir(void) { return (char *)g_get_tmp_dir(); }
void back_button_set_sensitive(bool sensitive) {}
extern GtkWidget *atl_webview_new(void);
extern WKWebView *atl_webview_native(GtkWidget *widget);
extern gboolean atl_input_replace(NSString *text, gboolean composing, int cursor);
static void pump(double seconds) {
    NSDate *end = [NSDate dateWithTimeIntervalSinceNow:seconds];
    do {
        while (g_main_context_iteration(NULL, FALSE)) {}
        [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.005]];
    } while (end.timeIntervalSinceNow > 0);
}
int main(void) { @autoreleasepool {
    /* GTK's macOS backend needs a launched NSApplication before the first window. */
    [NSApplication sharedApplication];
    [NSApp setActivationPolicy:NSApplicationActivationPolicyAccessory];
    [NSApp finishLaunching];
    gtk_init();
    window = GTK_WINDOW(gtk_window_new());
    gtk_window_set_default_size(window, 640,480);
    GtkWidget *box = gtk_box_new(GTK_ORIENTATION_VERTICAL,0);
    GtkWidget *entry = gtk_entry_new();
    GtkWidget *web = atl_webview_new();
    gtk_box_append(GTK_BOX(box),entry); gtk_box_append(GTK_BOX(box),web);
    gtk_window_set_child(window,box); gtk_window_present(window);
    [NSApp activateIgnoringOtherApps:YES];
    gtk_widget_grab_focus(entry); pump(.2);
    if (atl_input_replace(@"ATL \U0001f600", FALSE,1)) {
        assert(!strcmp(gtk_editable_get_text(GTK_EDITABLE(entry)),"ATL \xf0\x9f\x98\x80"));
        puts("AppKit text-input commit and Unicode passed");
    } else { fprintf(stderr,"No NSTextInputClient on GTK window\n"); return 1; }
    WKWebView *view = atl_webview_native(web);
    assert(view.superview && view.frame.size.width > 0 && view.frame.size.height > 0);
    [view loadHTMLString:@"<html><body>ATL-WebKit<script>document.title='ATL-JavaScript';</script></body></html>" baseURL:nil];
    NSDate *deadline = [NSDate dateWithTimeIntervalSinceNow:15];
    while (![view.title isEqualToString:@"ATL-JavaScript"] && deadline.timeIntervalSinceNow > 0) pump(.05);
    assert([view.title isEqualToString:@"ATL-JavaScript"]);
    __block BOOL complete = NO, valid = NO;
    [view evaluateJavaScript:@"document.body.textContent.includes('ATL-WebKit')" completionHandler:^(id value,NSError *error) { complete=YES; valid=!error && [value boolValue]; }];
    while (!complete && deadline.timeIntervalSinceNow > 0) pump(.05);
    assert(complete && valid);
    gtk_widget_set_visible(web,FALSE); pump(.05); assert(!view.superview.superview);
    gtk_widget_set_visible(web,TRUE); pump(.05); assert(view.superview.superview);
    gtk_window_destroy(window); window = NULL; pump(.05);
    puts("WKWebView HTML, JavaScript, GTK allocation and map/unmap passed");
    return 0;
} }
