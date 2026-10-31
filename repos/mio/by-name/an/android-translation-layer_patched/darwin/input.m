#import "host.h"
extern GtkWindow *window;
static id<NSTextInputClient> text_client(void) {
    id responder = NSApp.keyWindow.firstResponder;
    return [responder conformsToProtocol:@protocol(NSTextInputClient)] ? responder : nil;
}
static int utf16_to_gtk(const char *text, int position) {
    int offset = 0, units = 0;
    while (*text && units < position) {
        units += g_utf8_get_char(text) > 0xffff ? 2 : 1;
        text = g_utf8_next_char(text); offset++;
    }
    return offset;
}
static gboolean select_range(int start, int end) {
    if (!window || start < 0 || end < 0) return FALSE;
    GtkWidget *focus = gtk_window_get_focus(window);
    if (!focus || !GTK_IS_EDITABLE(focus)) return FALSE;
    const char *text = gtk_editable_get_text(GTK_EDITABLE(focus));
    gtk_editable_select_region(GTK_EDITABLE(focus), utf16_to_gtk(text, start), utf16_to_gtk(text, end));
    return TRUE;
}
/* Exposed for a native GTK integration test without constructing an ART VM. */
gboolean atl_input_replace(NSString *text, gboolean composing, int cursor) {
    id<NSTextInputClient> client = text_client();
    if (!client || !text) return FALSE;
    NSRange range = client.hasMarkedText ? client.markedRange : client.selectedRange;
    if (range.location == NSNotFound) return FALSE;
    NSInteger newPosition = cursor > 0 ? (NSInteger)text.length + cursor-1 : cursor;
    if (composing) {
        NSUInteger selected = MIN(text.length, (NSUInteger)MAX(0, newPosition));
        [client setMarkedText:text selectedRange:NSMakeRange(selected, 0) replacementRange:range];
    } else {
        [client insertText:text replacementRange:range];
        NSInteger position = MAX(0, (NSInteger)range.location+newPosition);
        select_range(position, position);
    }
    return TRUE;
}
JNIEXPORT jlong JNICALL Java_android_inputmethodservice_InputMethodService_00024ATLInputConnection_nativeInit(JNIEnv *env, jobject this) { return 1; }
JNIEXPORT jboolean JNICALL Java_android_inputmethodservice_InputMethodService_00024ATLInputConnection_nativeSetCompositingText(JNIEnv *env, jobject this, jlong ptr, jstring value, jint cursor) {
    NSString *text = atl_string(env, value); __block gboolean result = FALSE;
    atl_main(^{ result = atl_input_replace(text, TRUE, cursor); }); return result;
}
JNIEXPORT jboolean JNICALL Java_android_inputmethodservice_InputMethodService_00024ATLInputConnection_nativeCommitText(JNIEnv *env, jobject this, jlong ptr, jstring value, jint cursor) {
    NSString *text = atl_string(env, value); __block gboolean result = FALSE;
    atl_main(^{ result = atl_input_replace(text, FALSE, cursor); }); return result;
}
JNIEXPORT jboolean JNICALL Java_android_inputmethodservice_InputMethodService_00024ATLInputConnection_nativeFinishComposingText(JNIEnv *env, jobject this, jlong ptr) {
    __block BOOL result = NO;
    atl_main(^{ id<NSTextInputClient> client = text_client(); if (client) { [client unmarkText]; result = YES; } }); return result;
}
JNIEXPORT jboolean JNICALL Java_android_inputmethodservice_InputMethodService_00024ATLInputConnection_nativeSetCompositingRegion(JNIEnv *env, jobject this, jlong ptr, jint start, jint end) {
    if (start < 0 || end < 0) return FALSE;
    __block BOOL result = NO;
    atl_main(^{
        id<NSTextInputClient> client = text_client(); if (!client) return;
        NSRange range = NSMakeRange(MIN(start,end), ABS(end-start)), actual;
        NSAttributedString *text = [client attributedSubstringForProposedRange:range actualRange:&actual];
        if (!text || actual.location != range.location || actual.length != range.length) return;
        [client setMarkedText:text selectedRange:NSMakeRange(text.length,0) replacementRange:range]; result = YES;
    }); return result;
}
JNIEXPORT jboolean JNICALL Java_android_inputmethodservice_InputMethodService_00024ATLInputConnection_nativeSetSelection(JNIEnv *env, jobject this, jlong ptr, jint start, jint end) {
    __block gboolean result = FALSE; atl_main(^{ result = select_range(start, end); }); return result;
}
JNIEXPORT jboolean JNICALL Java_android_inputmethodservice_InputMethodService_00024ATLInputConnection_nativeDeleteSurroundingText(JNIEnv *env, jobject this, jlong ptr, jint before, jint after) {
    if (before < 0 || after < 0) return FALSE;
    __block BOOL result = NO;
    atl_main(^{
        id<NSTextInputClient> client = text_client(); if (!client) return;
        NSRange selected = client.selectedRange;
        if (selected.location == NSNotFound) return;
        /* Delete after then before, preserving any selected text in the middle. */
        if (after) [client insertText:@"" replacementRange:NSMakeRange(NSMaxRange(selected), after)];
        NSUInteger count = MIN((NSUInteger)before, selected.location);
        if (count) [client insertText:@"" replacementRange:NSMakeRange(selected.location-count, count)];
        select_range(selected.location-count, NSMaxRange(selected)-count);
        result = YES;
    }); return result;
}
JNIEXPORT jboolean JNICALL Java_android_inputmethodservice_InputMethodService_00024ATLInputConnection_nativeSendKeyEvent(JNIEnv *env, jobject this, jlong ptr, jlong time, jlong key, jlong state) {
    if (state == 1) return TRUE;
    if (state != 0) return FALSE;
    __block BOOL result = NO;
    atl_main(^{
        id<NSTextInputClient> client = text_client(); if (!client) return;
        SEL command = NULL;
        switch (key) {
            case 67: command = @selector(deleteBackward:); break;
            case 112: command = @selector(deleteForward:); break;
            case 66: command = @selector(insertNewline:); break;
            case 21: command = @selector(moveLeft:); break;
            case 22: command = @selector(moveRight:); break;
            case 19: command = @selector(moveUp:); break;
            case 20: command = @selector(moveDown:); break;
            case 122: command = @selector(moveToBeginningOfLine:); break;
            case 123: command = @selector(moveToEndOfLine:); break;
            default: break;
        }
        if (command) { [client doCommandBySelector:command]; result = YES; }
        else if (key == 62 || (key >= 7 && key <=16) || (key >=29 && key <=54)) {
            unichar character = key == 62 ? ' ' : key <=16 ? '0'+key-7 : 'a'+key-29;
            result = atl_input_replace([NSString stringWithCharacters:&character length:1], FALSE, 1);
        }
    }); return result;
}
