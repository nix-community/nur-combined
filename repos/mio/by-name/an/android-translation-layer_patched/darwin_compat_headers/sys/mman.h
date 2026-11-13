#ifndef ATL_DARWIN_MMAN_H
#define ATL_DARWIN_MMAN_H
#include_next <sys/mman.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>
#ifndef MFD_CLOEXEC
#define MFD_CLOEXEC 1U
#endif
static inline int memfd_create(const char *name, unsigned int flags) {
    if (flags & ~MFD_CLOEXEC) { errno = EINVAL; return -1; }
    /* No memfd on Darwin: create an unlinked file in /tmp, with O_CLOEXEC applied
     * at creation so a concurrent fork+exec cannot inherit it. Sealing is unsupported. */
    for (unsigned int attempt = 0; attempt < 16; attempt++) {
        char path[64];
        snprintf(path, sizeof path, "/tmp/atl-memfd-%08x-%u", arc4random(), attempt);
        int fd = open(path, O_RDWR | O_CREAT | O_EXCL | ((flags & MFD_CLOEXEC) ? O_CLOEXEC : 0), 0600);
        if (fd < 0) { if (errno == EEXIST) continue; return -1; }
        unlink(path);
        return fd;
    }
    errno = EEXIST;
    return -1;
}
#endif
