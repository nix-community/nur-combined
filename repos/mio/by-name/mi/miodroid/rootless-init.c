/* SPDX-License-Identifier: GPL-3.0-or-later
 * Bootstrap Binder in LXC's own user/mount namespace before Android init.
 * Static linking keeps this independent of the Android image's libc/linker.
 */
#include <errno.h>
#include <fcntl.h>
#include <linux/android/binderfs.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/ioctl.h>
#include <sys/mount.h>
#include <sys/stat.h>
#include <string.h>
#include <unistd.h>

static void log_message(const char *message) {
    int fd = open("/data/miodroid-rootless-init.log", O_WRONLY | O_CREAT | O_APPEND | O_CLOEXEC, 0600);
    if (fd >= 0) {
        write(fd, message, strlen(message));
        write(fd, "\n", 1);
        close(fd);
    }
}

static void fail(const char *operation) {
    char message[256];
    snprintf(message, sizeof(message), "%s: errno=%d", operation, errno);
    log_message(message);
    perror(operation);
    exit(EXIT_FAILURE);
}

int main(void) {
    log_message("bootstrap started");
    const char *names[] = {"binder", "vndbinder", "hwbinder"};
    if (mkdir("/dev/binderfs", 0755) && errno != EEXIST)
        fail("mkdir binderfs");
    if (mount("binder", "/dev/binderfs", "binder", MS_NOSUID, NULL))
        fail("mount binderfs");
    log_message("binderfs mounted");
    int control = open("/dev/binderfs/binder-control", O_RDONLY | O_CLOEXEC);
    if (control < 0)
        fail("open binder-control");
    for (size_t i = 0; i < sizeof(names) / sizeof(names[0]); ++i) {
        char path[128], link[64];
        struct stat st;
        snprintf(path, sizeof(path), "/dev/binderfs/%s", names[i]);
        if (stat(path, &st)) {
            if (errno != ENOENT)
                fail("stat binder device");
            struct binderfs_device device = {0};
            snprintf(device.name, sizeof(device.name), "%s", names[i]);
            if (ioctl(control, BINDER_CTL_ADD, &device))
                fail("allocate binder device");
        }
        if (stat(path, &st) || !S_ISCHR(st.st_mode))
            fail("validate binder device");
        if (chmod(path, 0666))
            fail("chmod binder device");
        snprintf(link, sizeof(link), "/dev/%s", names[i]);
        if (symlink(path, link))
            fail("symlink binder device");
    }
    close(control);
    log_message("binder devices ready; starting Android init");
    execl("/init", "/init", "second_stage", (char *)NULL);
    fail("exec Android init");
}
