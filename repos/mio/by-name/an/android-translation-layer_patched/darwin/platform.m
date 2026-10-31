#import "host.h"
#import <CoreLocation/CoreLocation.h>
#import <UserNotifications/UserNotifications.h>
#import <MediaPlayer/MediaPlayer.h>
#include "../generated_headers/android_os_SystemClock.h"

/* Notification actions retain serialized Android intents, not JNI local refs. */
static NSDictionary *notification_action(JNIEnv *env, NSString *label, jint type, jobject intent) {
    const char *action = intent_actionname_from_type(type);
    if (!action || !intent) return nil;
    GVariant *value = intent_serialize(env, intent);
    if (!value) return nil;
    char *printed = g_variant_print(value, TRUE);
    NSDictionary *result = @{ @"label": label ?: @"Open", @"action": @(action), @"target": @(printed) };
    g_free(printed); g_variant_unref(g_variant_ref_sink(value));
    return result;
}
@interface ATLNotifications : NSObject <UNUserNotificationCenterDelegate>
@property NSMutableSet<NSString *> *ongoing;
@property NSMutableDictionary<NSString *, UNNotificationCategory *> *categories;
@property NSMutableDictionary<NSString *, NSNumber *> *generations;
@end
@implementation ATLNotifications
- (instancetype)init {
    if ((self = [super init])) {
        _ongoing = [NSMutableSet new]; _categories = [NSMutableDictionary new]; _generations = [NSMutableDictionary new];
    }
    return self;
}
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification
        withCompletionHandler:(void (^)(UNNotificationPresentationOptions))done {
    done(UNNotificationPresentationOptionBanner | UNNotificationPresentationOptionSound);
}
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response
        withCompletionHandler:(void (^)(void))done {
    NSDictionary *data = response.notification.request.content.userInfo;
    NSDictionary *action = data[@"default"];
    if (![response.actionIdentifier isEqualToString:UNNotificationDefaultActionIdentifier]) {
        action = ((NSDictionary *)data[@"actions"])[response.actionIdentifier];
    }
    if (action) {
        NSString *name = action[@"action"], *target = action[@"target"];
        atl_main(^{
            GVariant *value = g_variant_parse(G_VARIANT_TYPE(INTENT_G_VARIANT_TYPE_STRING), target.UTF8String, NULL, NULL, NULL);
            GApplication *app = g_application_get_default();
            if (value && app) {
                const char *key = name.UTF8String;
                g_action_group_activate_action(G_ACTION_GROUP(app), g_str_has_prefix(key, "app.") ? key+4 : key, value);
            }
            if (value) g_variant_unref(value);
        });
    }
    done();
}
@end
static ATLNotifications *notifications;
static UNUserNotificationCenter *notification_center(void) {
    if (!notifications) notifications = [ATLNotifications new];
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    center.delegate = notifications;
    return center;
}
JNIEXPORT jlong JNICALL Java_android_app_NotificationManager_nativeInitBuilder(JNIEnv *env, jobject this) {
    return (jlong)(intptr_t)CFBridgingRetain([NSMutableArray new]);
}
JNIEXPORT void JNICALL Java_android_app_NotificationManager_nativeAddAction(JNIEnv *env, jobject this, jlong builder, jstring label, jint type, jobject intent) {
    if (!builder) return;
    NSDictionary *action = notification_action(env, atl_string(env, label), type, intent);
    if (action) [(__bridge NSMutableArray *)(void *)(intptr_t)builder addObject:action];
}
JNIEXPORT void JNICALL Java_android_app_NotificationManager_nativeShowNotification(JNIEnv *env, jobject this, jlong builder, jint identifier, jstring title, jstring text, jstring icon, jboolean ongoing, jint type, jobject intent) {
    NSArray *actions = builder ? CFBridgingRelease((void *)(intptr_t)builder) : @[];
    NSString *heading = atl_string(env, title) ?: @"", *body = atl_string(env, text) ?: @"";
    NSDictionary *defaultAction = notification_action(env, nil, type, intent);
    atl_main(^{
        UNUserNotificationCenter *center = notification_center();
        NSString *key = [NSString stringWithFormat:@"atl.%d", identifier];
        NSNumber *generation = @([notifications.generations[key] unsignedLongLongValue] + 1);
        notifications.generations[key] = generation;
        UNMutableNotificationContent *content = [UNMutableNotificationContent new];
        content.title = heading; content.body = body;
        NSMutableDictionary *targets = [NSMutableDictionary new];
        NSMutableArray *buttons = [NSMutableArray new];
        for (NSUInteger i = 0; i < actions.count; i++) {
            NSString *actionID = [NSString stringWithFormat:@"action.%lu", (unsigned long)i];
            targets[actionID] = actions[i];
            [buttons addObject:[UNNotificationAction actionWithIdentifier:actionID title:((NSDictionary *)actions[i])[@"label"] options:UNNotificationActionOptionForeground]];
        }
        content.userInfo = defaultAction ? @{ @"actions": targets, @"default": defaultAction } : @{ @"actions": targets };
        content.categoryIdentifier = key;
        notifications.categories[key] = [UNNotificationCategory categoryWithIdentifier:key actions:buttons intentIdentifiers:@[] options:UNNotificationCategoryOptionNone];
        [center setNotificationCategories:[NSSet setWithArray:notifications.categories.allValues]];
        if (ongoing) [notifications.ongoing addObject:key]; else [notifications.ongoing removeObject:key];
        [center requestAuthorizationWithOptions:UNAuthorizationOptionAlert | UNAuthorizationOptionSound completionHandler:^(BOOL granted, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error) g_warning("macOS notifications: %s", error.localizedDescription.UTF8String);
                if (!granted || ![notifications.generations[key] isEqual:generation]) return;
                [center addNotificationRequest:[UNNotificationRequest requestWithIdentifier:key content:content trigger:nil] withCompletionHandler:^(NSError *failure) {
                    if (failure) g_warning("macOS notification: %s", failure.localizedDescription.UTF8String);
                }];
            });
        }];
    });
}
JNIEXPORT void JNICALL Java_android_app_NotificationManager_nativeCancel(JNIEnv *env, jobject this, jint identifier) {
    atl_main(^{
        UNUserNotificationCenter *center = notification_center();
        NSString *key = [NSString stringWithFormat:@"atl.%d", identifier];
        notifications.generations[key] = @([notifications.generations[key] unsignedLongLongValue] + 1);
        [center removePendingNotificationRequestsWithIdentifiers:@[key]];
        [center removeDeliveredNotificationsWithIdentifiers:@[key]];
        [notifications.ongoing removeObject:key];
        [notifications.categories removeObjectForKey:key];
        [center setNotificationCategories:[NSSet setWithArray:notifications.categories.allValues]];
    });
}
void remove_ongoing_notifications(void) {
    if (!notifications) return;
    atl_main(^{
        UNUserNotificationCenter *center = notification_center();
        NSArray *keys = notifications.ongoing.allObjects;
        for (NSString *key in keys) notifications.generations[key] = @([notifications.generations[key] unsignedLongLongValue]+1);
        [center removePendingNotificationRequestsWithIdentifiers:keys];
        [center removeDeliveredNotificationsWithIdentifiers:keys];
        [notifications.ongoing removeAllObjects];
    });
}

/* Now Playing replaces the Linux MPRIS transport, retaining Android callbacks. */
static jobject media_callback;
static NSMutableDictionary *media_info;
static BOOL media_playing;
@interface ATLMediaCommands : NSObject
- (MPRemoteCommandHandlerStatus)play:(MPRemoteCommandEvent *)event;
- (MPRemoteCommandHandlerStatus)pause:(MPRemoteCommandEvent *)event;
- (MPRemoteCommandHandlerStatus)toggle:(MPRemoteCommandEvent *)event;
- (MPRemoteCommandHandlerStatus)next:(MPRemoteCommandEvent *)event;
- (MPRemoteCommandHandlerStatus)previous:(MPRemoteCommandEvent *)event;
- (MPRemoteCommandHandlerStatus)seek:(MPChangePlaybackPositionCommandEvent *)event;
@end
static void media_call(const char *method, jlong position, bool seek) {
    atl_main(^{ atl_callback(^(JNIEnv *env) {
        if (!media_callback) return;
        jmethodID id = (*env)->GetMethodID(env, (*env)->GetObjectClass(env, media_callback), method, seek ? "(J)V" : "()V");
        if (id) {
            if (seek) (*env)->CallVoidMethod(env, media_callback, id, position);
            else (*env)->CallVoidMethod(env, media_callback, id);
        }
    }); });
}
@implementation ATLMediaCommands
- (MPRemoteCommandHandlerStatus)play:(MPRemoteCommandEvent *)event { media_call("onPlay", 0, false); return MPRemoteCommandHandlerStatusSuccess; }
- (MPRemoteCommandHandlerStatus)pause:(MPRemoteCommandEvent *)event { media_call("onPause", 0, false); return MPRemoteCommandHandlerStatusSuccess; }
- (MPRemoteCommandHandlerStatus)toggle:(MPRemoteCommandEvent *)event { media_call(media_playing ? "onPause" : "onPlay", 0, false); return MPRemoteCommandHandlerStatusSuccess; }
- (MPRemoteCommandHandlerStatus)next:(MPRemoteCommandEvent *)event { media_call("onSkipToNext", 0, false); return MPRemoteCommandHandlerStatusSuccess; }
- (MPRemoteCommandHandlerStatus)previous:(MPRemoteCommandEvent *)event { media_call("onSkipToPrevious", 0, false); return MPRemoteCommandHandlerStatusSuccess; }
- (MPRemoteCommandHandlerStatus)seek:(MPChangePlaybackPositionCommandEvent *)event { media_call("onSeekTo", (jlong)(event.positionTime*1000), true); return MPRemoteCommandHandlerStatusSuccess; }
@end
static ATLMediaCommands *media_commands;
static void media_install(void) {
    if (media_commands) return;
    media_commands = [ATLMediaCommands new];
    MPRemoteCommandCenter *center = [MPRemoteCommandCenter sharedCommandCenter];
    [center.playCommand addTarget:media_commands action:@selector(play:)];
    [center.pauseCommand addTarget:media_commands action:@selector(pause:)];
    [center.togglePlayPauseCommand addTarget:media_commands action:@selector(toggle:)];
    [center.nextTrackCommand addTarget:media_commands action:@selector(next:)];
    [center.previousTrackCommand addTarget:media_commands action:@selector(previous:)];
    [center.changePlaybackPositionCommand addTarget:media_commands action:@selector(seek:)];
}
JNIEXPORT void JNICALL Java_android_media_session_MediaSession_nativeSetCallback(JNIEnv *env, jobject this, jobject callback) {
    jobject ref = callback ? (*env)->NewGlobalRef(env, callback) : NULL;
    atl_main(^{ atl_callback(^(JNIEnv *mainEnv) {
        if (media_callback) (*mainEnv)->DeleteGlobalRef(mainEnv, media_callback);
        media_callback = ref;
    }); });
}
JNIEXPORT void JNICALL Java_android_media_session_MediaSession_nativeSetState(JNIEnv *env, jobject this, jint state, jlong actions, jlong position, jlong update, jstring title, jstring artist, jstring artwork) {
    NSString *heading = atl_string(env, title), *subtitle = atl_string(env, artist);
    jlong now = Java_android_os_SystemClock_elapsedRealtime(env, NULL);
    double elapsed = MAX(0, position) / 1000.0;
    if (state == 3 && update > 0) elapsed += MAX((jlong)0, now-update)/1000.0;
    atl_main(^{
        media_install();
        media_playing = state == 3;
        if (!media_info) media_info = [NSMutableDictionary new];
        if (heading) media_info[MPMediaItemPropertyTitle] = heading;
        if (subtitle) media_info[MPMediaItemPropertyArtist] = subtitle;
        media_info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = @(elapsed);
        media_info[MPNowPlayingInfoPropertyPlaybackRate] = @(media_playing ? 1 : 0);
        MPNowPlayingInfoCenter *info = [MPNowPlayingInfoCenter defaultCenter];
        info.nowPlayingInfo = media_info;
        info.playbackState = media_playing ? MPNowPlayingPlaybackStatePlaying : state == 2 ? MPNowPlayingPlaybackStatePaused : MPNowPlayingPlaybackStateStopped;
        MPRemoteCommandCenter *center = [MPRemoteCommandCenter sharedCommandCenter];
        center.playCommand.enabled = !!(actions & (1<<2));
        center.pauseCommand.enabled = !!(actions & (1<<1));
        center.togglePlayPauseCommand.enabled = !!(actions & ((1<<1)|(1<<2)|(1<<9)));
        center.nextTrackCommand.enabled = !!(actions & (1<<5));
        center.previousTrackCommand.enabled = !!(actions & (1<<4));
        center.changePlaybackPositionCommand.enabled = !!(actions & (1<<8));
    });
}
JNIEXPORT void JNICALL Java_android_app_NotificationManager_nativeShowMPRIS(JNIEnv *env, jobject this, jstring package, jstring identity) {
    NSString *name = atl_string(env, identity);
    atl_main(^{ media_install(); if (!media_info) media_info = [NSMutableDictionary new];
        if (name && !media_info[MPMediaItemPropertyTitle]) media_info[MPMediaItemPropertyTitle] = name;
        [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo = media_info;
    });
}
JNIEXPORT void JNICALL Java_android_app_NotificationManager_nativeCancelMPRIS(JNIEnv *env, jobject this) {
    atl_main(^{
        [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo = nil;
        [MPNowPlayingInfoCenter defaultCenter].playbackState = MPNowPlayingPlaybackStateStopped;
        MPRemoteCommandCenter *center = [MPRemoteCommandCenter sharedCommandCenter];
        if (media_commands) {
            for (MPRemoteCommand *command in @[center.playCommand, center.pauseCommand, center.togglePlayPauseCommand, center.nextTrackCommand, center.previousTrackCommand, center.changePlaybackPositionCommand]) {
                [command removeTarget:media_commands]; command.enabled = NO;
            }
        }
        media_commands = nil; media_info = nil; media_playing = NO;
    });
}

@interface ATLLocation : NSObject <CLLocationManagerDelegate>
@property CLLocationManager *manager;
@end
@implementation ATLLocation
- (instancetype)init {
    if ((self = [super init])) { _manager = [CLLocationManager new]; _manager.delegate = self; _manager.desiredAccuracy = kCLLocationAccuracyBest; }
    return self;
}
- (void)locationManagerDidChangeAuthorization:(CLLocationManager *)manager {
    if (manager.authorizationStatus == kCLAuthorizationStatusAuthorizedAlways)
        [manager startUpdatingLocation];
}
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    CLLocation *location = locations.lastObject;
    if (!location || location.horizontalAccuracy < 0) return;
    atl_callback(^(JNIEnv *env) {
        J__LocationManager__locationUpdated(env, location.coordinate.latitude, location.coordinate.longitude,
            location.altitude, location.horizontalAccuracy, MAX(0, location.speed), MAX(0, location.course), (jlong)(location.timestamp.timeIntervalSince1970*1000));
    });
}
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error { g_warning("Core Location: %s", error.localizedDescription.UTF8String); }
@end
static ATLLocation *location_service;
JNIEXPORT void JNICALL Java_android_location_LocationManager_nativeGetLocation(JNIEnv *env, jobject this) {
    if (!getenv("ATL_UGLY_ENABLE_LOCATION")) {
        atl_throw(env, "java/lang/SecurityException", @"Enable ATL_UGLY_ENABLE_LOCATION to allow location access"); return;
    }
    atl_main(^{
        if (!location_service) location_service = [ATLLocation new];
        CLAuthorizationStatus status = location_service.manager.authorizationStatus;
        if (status == kCLAuthorizationStatusNotDetermined) [location_service.manager requestWhenInUseAuthorization];
        else if (status == kCLAuthorizationStatusAuthorizedAlways) [location_service.manager startUpdatingLocation];
        else g_warning("macOS location permission is denied or restricted");
    });
}

JNIEXPORT void JNICALL Java_android_app_WallpaperManager_set_1bitmap(JNIEnv *env, jclass cls, jlong pointer) {
    GdkTexture *texture = _PTR(pointer);
    if (!texture || !GDK_IS_TEXTURE(texture)) { atl_throw(env, "java/lang/IllegalArgumentException", @"Invalid wallpaper bitmap"); return; }
    GBytes *png = gdk_texture_save_to_png_bytes(texture);
    if (!png) { atl_throw(env, "java/io/IOException", @"Cannot encode wallpaper"); return; }
    gsize size; const void *bytes = g_bytes_get_data(png, &size);
    NSData *data = [NSData dataWithBytes:bytes length:size]; g_bytes_unref(png);
    __block NSError *failure;
    atl_main(^{
        NSURL *directory = [[NSFileManager defaultManager] URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask].firstObject;
        directory = [directory URLByAppendingPathComponent:@"android_translation_layer/wallpaper" isDirectory:YES];
        if (![[NSFileManager defaultManager] createDirectoryAtURL:directory withIntermediateDirectories:YES attributes:nil error:&failure]) return;
        NSURL *file = [directory URLByAppendingPathComponent:[NSUUID.UUID.UUIDString stringByAppendingString:@".png"]];
        if (![data writeToURL:file options:NSDataWritingAtomic error:&failure]) return;
        BOOL applied = NO;
        for (NSScreen *screen in NSScreen.screens) {
            NSError *error;
            if ([[NSWorkspace sharedWorkspace] setDesktopImageURL:file forScreen:screen options:@{} error:&error]) applied = YES;
            else if (!failure) failure = error;
        }
        /* macOS needs the backing image to persist after this method returns. */
        if (!applied) [[NSFileManager defaultManager] removeItemAtURL:file error:nil];
    });
    if (failure) atl_throw(env, "java/io/IOException", failure.localizedDescription);
}
static NSTimer *haptic_timer;
JNIEXPORT jint JNICALL Java_android_os_Vibrator_native_1constructor(JNIEnv *env, jobject this) {
    return NSHapticFeedbackManager.defaultPerformer ? 0 : -1;
}
JNIEXPORT void JNICALL Java_android_os_Vibrator_native_1vibrate(JNIEnv *env, jobject this, jint fd, jlong milliseconds) {
    if (fd < 0 || milliseconds <= 0) return;
    atl_main(^{
        [haptic_timer invalidate];
        NSDate *end = [NSDate dateWithTimeIntervalSinceNow:MIN(milliseconds, (jlong)60000)/1000.0];
        [NSHapticFeedbackManager.defaultPerformer performFeedbackPattern:NSHapticFeedbackPatternGeneric performanceTime:NSHapticFeedbackPerformanceTimeNow];
        haptic_timer = [NSTimer scheduledTimerWithTimeInterval:0.08 repeats:YES block:^(NSTimer *timer) {
            if ([end timeIntervalSinceNow] <= 0) { [timer invalidate]; haptic_timer = nil; return; }
            [NSHapticFeedbackManager.defaultPerformer performFeedbackPattern:NSHapticFeedbackPatternGeneric performanceTime:NSHapticFeedbackPerformanceTimeNow];
        }];
    });
}
JNIEXPORT void JNICALL Java_android_os_Vibrator_native_1cancel(JNIEnv *env, jobject this) { atl_main(^{ [haptic_timer invalidate]; haptic_timer = nil; }); }
JNIEXPORT void JNICALL Java_android_media_session_MediaSession_nativeRelease(JNIEnv *env, jobject this) {
    Java_android_app_NotificationManager_nativeCancelMPRIS(env, this);
    Java_android_media_session_MediaSession_nativeSetCallback(env, this, NULL);
}
