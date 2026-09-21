#include_next <sys/mman.h>
#include <stdlib.h>
#include <unistd.h>
#ifndef MFD_CLOEXEC
#define MFD_CLOEXEC 0
#endif
static inline int memfd_create(const char *name, unsigned int flags) {
    char path[] = "/tmp/memfd-XXXXXX";
    int fd = mkstemp(path);
    if (fd >= 0) unlink(path);
    return fd;
}
