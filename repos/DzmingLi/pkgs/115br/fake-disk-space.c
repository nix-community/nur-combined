#define _GNU_SOURCE
#include <dlfcn.h>
#include <sys/vfs.h>
#include <sys/statvfs.h>
#include <string.h>

// 劫持 statfs
int statfs(const char *path, struct statfs *buf) {
    static int (*real_statfs)(const char *, struct statfs *) = NULL;
    if (!real_statfs) {
        real_statfs = dlsym(RTLD_NEXT, "statfs");
    }

    int ret = real_statfs(path, buf);
    if (ret == 0) {
        // 伪造大量可用空间: 1TB
        buf->f_bavail = 1099511627776ULL / buf->f_bsize;
        buf->f_bfree = buf->f_bavail;
    }
    return ret;
}

// 劫持 statfs64
int statfs64(const char *path, struct statfs64 *buf) {
    static int (*real_statfs64)(const char *, struct statfs64 *) = NULL;
    if (!real_statfs64) {
        real_statfs64 = dlsym(RTLD_NEXT, "statfs64");
    }

    int ret = real_statfs64(path, buf);
    if (ret == 0) {
        buf->f_bavail = 1099511627776ULL / buf->f_bsize;
        buf->f_bfree = buf->f_bavail;
    }
    return ret;
}

// 劫持 statvfs
int statvfs(const char *path, struct statvfs *buf) {
    static int (*real_statvfs)(const char *, struct statvfs *) = NULL;
    if (!real_statvfs) {
        real_statvfs = dlsym(RTLD_NEXT, "statvfs");
    }

    int ret = real_statvfs(path, buf);
    if (ret == 0) {
        buf->f_bavail = 1099511627776ULL / buf->f_bsize;
        buf->f_bfree = buf->f_bavail;
    }
    return ret;
}

// 劫持 statvfs64
int statvfs64(const char *path, struct statvfs64 *buf) {
    static int (*real_statvfs64)(const char *, struct statvfs64 *) = NULL;
    if (!real_statvfs64) {
        real_statvfs64 = dlsym(RTLD_NEXT, "statvfs64");
    }

    int ret = real_statvfs64(path, buf);
    if (ret == 0) {
        buf->f_bavail = 1099511627776ULL / buf->f_bsize;
        buf->f_bfree = buf->f_bavail;
    }
    return ret;
}
