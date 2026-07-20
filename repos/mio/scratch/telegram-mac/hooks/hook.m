#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#include <spawn.h>
#include <string.h>
#include <unistd.h>

#define DYLD_INTERPOSE(_replacement,_replacee) \
   __attribute__((used)) static struct{ const void* replacement; const void* replacee; } _interpose_##_replacee \
            __attribute__ ((section ("__DATA,__interpose"))) = { (const void*)(unsigned long)&_replacement, (const void*)(unsigned long)&_replacee };

int my_posix_spawn(pid_t *pid, const char *path, const posix_spawn_file_actions_t *file_actions, const posix_spawnattr_t *attrp, char *const argv[], char *const envp[]) {
    if (path && strcmp(path, "/usr/bin/sandbox-exec") == 0) {
        return posix_spawn(pid, "/tmp/bin/sandbox-exec", file_actions, attrp, argv, envp);
    }
    return posix_spawn(pid, path, file_actions, attrp, argv, envp);
}
DYLD_INTERPOSE(my_posix_spawn, posix_spawn)

int my_posix_spawnp(pid_t *pid, const char *file, const posix_spawn_file_actions_t *file_actions, const posix_spawnattr_t *attrp, char *const argv[], char *const envp[]) {
    if (file && strcmp(file, "/usr/bin/sandbox-exec") == 0) {
        return posix_spawnp(pid, "/tmp/bin/sandbox-exec", file_actions, attrp, argv, envp);
    }
    return posix_spawnp(pid, file, file_actions, attrp, argv, envp);
}
DYLD_INTERPOSE(my_posix_spawnp, posix_spawnp)

@implementation NSUserDefaults (Hook)
+ (void)load {
    Method original = class_getInstanceMethod(self, @selector(boolForKey:));
    Method swizzled = class_getInstanceMethod(self, @selector(my_boolForKey:));
    method_exchangeImplementations(original, swizzled);
}
- (BOOL)my_boolForKey:(NSString *)defaultName {
    if ([defaultName isEqualToString:@"IDEPackageSupportDisableManifestSandbox"] ||
        [defaultName isEqualToString:@"IDEPackageSupportDisablePluginExecutionSandbox"]) {
        return YES;
    }
    if ([defaultName isEqualToString:@"EnableBuildService"]) {
        return NO;
    }
    return [self my_boolForKey:defaultName];
}
@end
