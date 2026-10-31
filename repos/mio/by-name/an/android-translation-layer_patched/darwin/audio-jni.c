#include "audio.h"
#include "../defines.h"
#include "../util.h"
#include <limits.h>
#include <math.h>

/* Registry membership and references keep concurrent read/stop/release safe. */
typedef struct {
    gatomicrefcount refs;
    AtlAudio *audio;
    int channels;
    jweak owner;
    guint timer;
    unsigned last_notification;
} AudioHandle;
static GMutex handles_lock;
static GHashTable *handles;
static AudioHandle *acquire(jlong id) {
    g_mutex_lock(&handles_lock);
    AudioHandle *h = handles ? g_hash_table_lookup(handles, _PTR(id)) : NULL;
    if (h) g_atomic_ref_count_inc(&h->refs);
    g_mutex_unlock(&handles_lock);
    return h;
}
static void drop(gpointer data) {
    AudioHandle *h = data;
    if (g_atomic_ref_count_dec(&h->refs)) {
        if (h->owner) (*get_jni_env())->DeleteWeakGlobalRef(get_jni_env(), h->owner);
        atl_audio_close(h->audio);
        g_free(h);
    }
}
static jlong open_audio(JNIEnv *env, jobject owner, int rate, int mask, int format, int bytes, int capture) {
    int channels = atl_audio_channels(mask, capture);
    AtlAudio *audio = atl_audio_open(rate, channels, format, bytes, capture);
    if (!audio) {
        jclass cls = (*env)->FindClass(env, "java/lang/IllegalArgumentException");
        if (cls) (*env)->ThrowNew(env, cls, atl_audio_error());
        return 0;
    }
    AudioHandle *h = g_new0(AudioHandle, 1);
    g_atomic_ref_count_init(&h->refs);
    h->audio = audio;
    h->channels = channels;
    h->owner = (*env)->NewWeakGlobalRef(env, owner);
    _SET_INT_FIELD(owner, "channels", channels);
    g_mutex_lock(&handles_lock);
    if (!handles) handles = g_hash_table_new(g_direct_hash, g_direct_equal);
    g_hash_table_insert(handles, h, h);
    g_mutex_unlock(&handles_lock);
    return _INTPTR(h);
}
static void release_audio(JNIEnv *env, jlong id) {
    g_mutex_lock(&handles_lock);
    AudioHandle *h = handles ? g_hash_table_lookup(handles, _PTR(id)) : NULL;
    if (h) g_hash_table_remove(handles, h);
    g_mutex_unlock(&handles_lock);
    if (!h) return;
    atl_audio_pause(h->audio, 1);
    if (h->timer) { g_source_remove(h->timer); h->timer = 0; }
    drop(h);
}
static gboolean notify_position(gpointer data) {
    AudioHandle *h = data;
    JNIEnv *env = get_jni_env();
    if ((*env)->PushLocalFrame(env, 16) < 0) return G_SOURCE_CONTINUE;
    jobject owner = (*env)->NewLocalRef(env, h->owner);
    if (owner) {
        int period = _GET_INT_FIELD(owner, "notificationPeriod");
        unsigned written = (unsigned)_GET_INT_FIELD(owner, "playbackHeadPosition");
        unsigned played = written - MIN(written, (unsigned)atl_audio_pending(h->audio));
        jobject listener = _GET_OBJ_FIELD(owner, "periodic_update_listener", "Landroid/media/AudioTrack$OnPlaybackPositionUpdateListener;");
        if (period > 0 && listener && played - h->last_notification >= (unsigned)period) {
            h->last_notification = played;
            J__AudioTrack__OnPlaybackPositionUpdateListener__onPeriodicNotification(env, listener, owner);
        }
    }
    if ((*env)->ExceptionCheck(env)) (*env)->ExceptionDescribe(env);
    (*env)->PopLocalFrame(env, NULL);
    return G_SOURCE_CONTINUE;
}
JNIEXPORT void JNICALL Java_android_media_AudioTrack_native_1constructor(JNIEnv *env, jobject this, jint stream, jint rate, jint mask, jint format, jint bytes, jint mode) {
    jlong id = open_audio(env, this, rate, mask, format, bytes, 0);
    _SET_LONG_FIELD(this, "pcm_handle", id);
}
JNIEXPORT jint JNICALL Java_android_media_AudioTrack_getMinBufferSize(JNIEnv *env, jclass cls, jint rate, jint mask, jint format) {
    return atl_audio_min_buffer(rate, atl_audio_channels(mask, 0), format);
}
JNIEXPORT void JNICALL Java_android_media_AudioTrack_native_1play(JNIEnv *env, jobject this) {
    AudioHandle *h = acquire(_GET_LONG_FIELD(this, "pcm_handle"));
    if (!h) return;
    atl_audio_pause(h->audio, 0);
    g_mutex_lock(&handles_lock);
    if (!h->timer && g_hash_table_contains(handles, h)) {
        g_atomic_ref_count_inc(&h->refs);
        h->timer = g_timeout_add_full(G_PRIORITY_DEFAULT, 20, notify_position, h, drop);
    }
    g_mutex_unlock(&handles_lock);
    drop(h);
}
JNIEXPORT void JNICALL Java_android_media_AudioTrack_native_1pause(JNIEnv *env, jobject this) {
    AudioHandle *h = acquire(_GET_LONG_FIELD(this, "pcm_handle"));
    if (h) { atl_audio_pause(h->audio, 1); drop(h); }
}
JNIEXPORT void JNICALL Java_android_media_AudioTrack_native_1flush(JNIEnv *env, jobject this) {
    AudioHandle *h = acquire(_GET_LONG_FIELD(this, "pcm_handle"));
    if (h) { atl_audio_clear(h->audio); h->last_notification = 0; drop(h); }
}
JNIEXPORT void JNICALL Java_android_media_AudioTrack_native_1release(JNIEnv *env, jobject this) {
    jlong id = _GET_LONG_FIELD(this, "pcm_handle");
    _SET_LONG_FIELD(this, "pcm_handle", 0);
    release_audio(env, id);
}
JNIEXPORT jint JNICALL Java_android_media_AudioTrack_native_1getPlaybackHeadPosition(JNIEnv *env, jobject this) {
    AudioHandle *h = acquire(_GET_LONG_FIELD(this, "pcm_handle"));
    if (!h) return 0;
    int pending = atl_audio_pending(h->audio);
    drop(h);
    return pending; /* Java subtracts this from frames written. */
}
JNIEXPORT jint JNICALL Java_android_media_AudioTrack_native_1write___3BIIF(JNIEnv *env, jobject this, jbyteArray array, jint offset, jint frames, jfloat volume) {
    AudioHandle *h = acquire(_GET_LONG_FIELD(this, "pcm_handle"));
    if (!h) return -3;
    jsize size = array ? (*env)->GetArrayLength(env, array) : 0;
    if (!array || offset < 0 || offset % 2 || frames < 0 || offset > size || frames > (size-offset)/(h->channels*2)) { drop(h); return -2; }
    /* Copy rather than pin a Java array while the device waits for queue space. */
    int16_t *copy = g_try_malloc(MAX(frames, 1) * h->channels * sizeof(int16_t));
    if (!copy) { drop(h); return -1; }
    (*env)->GetByteArrayRegion(env, array, offset, frames*h->channels*2, (jbyte *)copy);
    int result = (*env)->ExceptionCheck(env) ? -2 : atl_audio_write(h->audio, copy, frames, volume);
    g_free(copy); drop(h); return result;
}
JNIEXPORT jint JNICALL Java_android_media_AudioTrack_native_1write___3SIIF(JNIEnv *env, jobject this, jshortArray array, jint offset, jint frames, jfloat volume) {
    AudioHandle *h = acquire(_GET_LONG_FIELD(this, "pcm_handle"));
    if (!h) return -3;
    jsize size = array ? (*env)->GetArrayLength(env, array) : 0;
    if (!array || offset < 0 || frames < 0 || offset > size || frames > (size-offset)/h->channels) { drop(h); return -2; }
    int16_t *copy = g_try_malloc(MAX(frames, 1)*h->channels*sizeof(int16_t));
    if (!copy) { drop(h); return -1; }
    (*env)->GetShortArrayRegion(env, array, offset, frames*h->channels, copy);
    int result = (*env)->ExceptionCheck(env) ? -2 : atl_audio_write(h->audio, copy, frames, volume);
    g_free(copy); drop(h); return result;
}
JNIEXPORT jlong JNICALL Java_android_media_AudioRecord_native_1constructor(JNIEnv *env, jobject this, jint stream, jint rate, jint mask, jint format, jint bytes) {
    if (!getenv("ATL_UGLY_ENABLE_MICROPHONE")) {
        jclass cls = (*env)->FindClass(env, "java/lang/SecurityException");
        if (cls) (*env)->ThrowNew(env, cls, "Enable ATL_UGLY_ENABLE_MICROPHONE to allow capture");
        return 0;
    }
    return open_audio(env, this, rate, mask, format, bytes, 1);
}
JNIEXPORT jint JNICALL Java_android_media_AudioRecord_getMinBufferSize(JNIEnv *env, jclass cls, jint rate, jint mask, jint format) {
    return atl_audio_min_buffer(rate, atl_audio_channels(mask, 1), format);
}
JNIEXPORT void JNICALL Java_android_media_AudioRecord_native_1record(JNIEnv *env, jobject this, jlong id) {
    AudioHandle *h = acquire(id);
    if (h) { atl_audio_pause(h->audio, 0); drop(h); }
}
JNIEXPORT void JNICALL Java_android_media_AudioRecord_native_1stop(JNIEnv *env, jobject this, jlong id) {
    AudioHandle *h = acquire(id);
    if (h) { atl_audio_pause(h->audio, 1); atl_audio_clear(h->audio); drop(h); }
}
JNIEXPORT void JNICALL Java_android_media_AudioRecord_native_1release(JNIEnv *env, jobject this, jlong id) { release_audio(env, id); }
JNIEXPORT jint JNICALL Java_android_media_AudioRecord_native_1read(JNIEnv *env, jobject this, jlong id, jshortArray array, jint offset, jint frames) {
    AudioHandle *h = acquire(id);
    if (!h) return -3;
    jsize size = array ? (*env)->GetArrayLength(env, array) : 0;
    if (!array || offset < 0 || frames < 0 || offset > size || frames > (size-offset)/h->channels) { drop(h); return -2; }
    int16_t *copy = g_try_malloc(MAX(frames, 1)*h->channels*sizeof(int16_t));
    if (!copy) { drop(h); return -1; }
    int result = atl_audio_read(h->audio, copy, frames);
    if (result > 0) (*env)->SetShortArrayRegion(env, array, offset, result*h->channels, copy);
    g_free(copy); drop(h); return result;
}
JNIEXPORT void JNICALL Java_android_media_AudioManager_nativeSetStreamVolume(JNIEnv *env, jobject this, jint volume) { atl_audio_set_volume(volume/100.f); }
