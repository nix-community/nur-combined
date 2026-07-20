#include <spawn.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>

#define DYLD_INTERPOSE(_replacement,_replacee) \
   __attribute__((used)) static struct{ const void* replacement; const void* replacee; } _interpose_##_replacee \
            __attribute__ ((section ("__DATA,__interpose"))) = { (const void*)(unsigned long)&_replacement, (const void*)(unsigned long)&_replacee };

int my_posix_spawn(pid_t *restrict pid, const char *restrict path,
                   const posix_spawn_file_actions_t *file_actions,
                   const posix_spawnattr_t *restrict attrp,
                   char *const argv[restrict], char *const envp[restrict]) {
    if (path && strcmp(path, "/usr/bin/sandbox-exec") == 0) {
        char *fake_path = getenv("FAKE_SANDBOX_EXEC");
        if (fake_path) {
            path = fake_path;
        }
    }
    return posix_spawn(pid, path, file_actions, attrp, argv, envp);
}
DYLD_INTERPOSE(my_posix_spawn, posix_spawn)

int my_posix_spawnp(pid_t *restrict pid, const char *restrict file,
                    const posix_spawn_file_actions_t *file_actions,
                    const posix_spawnattr_t *restrict attrp,
                    char *const argv[restrict], char *const envp[restrict]) {
    if (file && strcmp(file, "/usr/bin/sandbox-exec") == 0) {
        char *fake_path = getenv("FAKE_SANDBOX_EXEC");
        if (fake_path) {
            file = fake_path;
        }
    }
    return posix_spawnp(pid, file, file_actions, attrp, argv, envp);
}
DYLD_INTERPOSE(my_posix_spawnp, posix_spawnp)
