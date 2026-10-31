#ifndef ATL_DARWIN_MMAN_H
#define ATL_DARWIN_MMAN_H
#include_next <sys/mman.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>
#ifndef MFD_CLOEXEC
#define MFD_CLOEXEC 1U
#endif
static inline int memfd_create(const char *name, unsigned int flags) {
    if (flags & ~MFD_CLOEXEC) { errno = EINVAL; return -1; }
    char path[] = "/tmp/atl-memfd-XXXXXX";
    int fd = mkstemp(path);
    if (fd < 0) return -1;
    unlink(path);
    if ((flags & MFD_CLOEXEC) && fcntl(fd, F_SETFD, FD_CLOEXEC) == -1) {
        int error = errno;
        close(fd);
        errno = error;
        return -1;
    }
    return fd;
}
#endif
