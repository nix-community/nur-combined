#ifndef ATL_DARWIN_HOST_H
#define ATL_DARWIN_HOST_H
#import <AppKit/AppKit.h>
#include <jni.h>
#include <gtk/gtk.h>
#include "../defines.h"
#include "../util.h"
/* JNI strings are UTF-16, not Foundation's UTF-8 / JNI modified UTF-8. */
static inline NSString *atl_string(JNIEnv *env, jstring text) {
    if (!text) return nil;
    const jchar *chars = (*env)->GetStringChars(env, text, NULL);
    if (!chars) return nil;
    NSString *result = [[NSString alloc] initWithCharacters:chars length:(*env)->GetStringLength(env, text)];
    (*env)->ReleaseStringChars(env, text, chars);
    return result;
}
static inline jstring atl_jstring(JNIEnv *env, NSString *text) {
    if (!text) return NULL;
    NSUInteger length = text.length;
    unichar *chars = g_new(unichar, MAX(length, 1));
    [text getCharacters:chars range:NSMakeRange(0, length)];
    jstring result = (*env)->NewString(env, chars, length);
    g_free(chars);
    return result;
}
static inline void atl_main(void (^work)(void)) {
    if ([NSThread isMainThread]) work();
    else dispatch_sync(dispatch_get_main_queue(), work);
}
static inline void atl_throw(JNIEnv *env, const char *type, NSString *message) {
    jclass cls = (*env)->FindClass(env, type);
    if (cls) (*env)->ThrowNew(env, cls, message.UTF8String ?: "macOS operation failed");
}
static inline void atl_callback(void (^work)(JNIEnv *)) {
    if (!jvm) return;
    JNIEnv *env = NULL;
    bool attached = (*jvm)->GetEnv(jvm, (void **)&env, JNI_VERSION_1_6) == JNI_EDETACHED;
    if (attached && (*jvm)->AttachCurrentThread(jvm, (void **)&env, NULL) != JNI_OK) return;
    if (!env) return;
    if ((*env)->PushLocalFrame(env, 32) == JNI_OK) {
        work(env);
        if ((*env)->ExceptionCheck(env)) (*env)->ExceptionDescribe(env);
        (*env)->PopLocalFrame(env, NULL);
    }
    if (attached) (*jvm)->DetachCurrentThread(jvm);
}
#endif
