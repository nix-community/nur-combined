/* confine-copy ROOT SRC DST
 *
 * Copy SRC to DST, resolving SRC with ROOT treated as "/" and the kernel's
 * RESOLVE_IN_ROOT flag, so no symlink under ROOT -- whether absolute or via
 * ".." -- can escape it. The copy is driven off the confined fd, so a swap
 * after resolution cannot redirect it (TOCTOU-safe). Fails closed.
 */
#define _GNU_SOURCE
#include <errno.h>
#include <fcntl.h>
#include <linux/openat2.h>
#include <stdio.h>
#include <string.h>
#include <time.h>
#include <unistd.h>
#include <sys/syscall.h>

int main(int argc, char **argv) {
    if (argc != 4) { fprintf(stderr, "usage: %s ROOT SRC DST\n", argv[0]); return 2; }
    const char *root = argv[1], *src = argv[2], *dst = argv[3];

    int rootfd = open(root, O_PATH | O_DIRECTORY | O_CLOEXEC);
    if (rootfd < 0) { fprintf(stderr, "confine-copy: open root %s: %s\n", root, strerror(errno)); return 1; }

    while (*src == '/') src++;
    if (!*src) src = ".";

    struct open_how how = {
        .flags = O_RDONLY | O_CLOEXEC,
        .resolve = RESOLVE_IN_ROOT,
    };

    /* RESOLVE_IN_ROOT may return EAGAIN when it has to re-walk a path (its
     * documented contract is to retry); bounded retry with a short backoff. */
    long in;
    for (int tries = 0; ; tries++) {
        in = syscall(SYS_openat2, rootfd, src, &how, sizeof how);
        if (in >= 0) break;
        if (errno == EAGAIN && tries < 100) { nanosleep(&(struct timespec){ 0, 1000000 }, NULL); continue; }
        fprintf(stderr, "confine-copy: openat2 %s within %s: %s\n", src, root, strerror(errno));
        return 1;
    }

    int out = open(dst, O_WRONLY | O_CREAT | O_TRUNC | O_CLOEXEC, 0400);
    if (out < 0) { fprintf(stderr, "confine-copy: open dst %s: %s\n", dst, strerror(errno)); return 1; }

    char buf[1 << 16];
    ssize_t n;
    while ((n = read((int)in, buf, sizeof buf)) > 0) {
        for (ssize_t off = 0; off < n; ) {
            ssize_t w = write(out, buf + off, (size_t)(n - off));
            if (w < 0) { fprintf(stderr, "confine-copy: write %s: %s\n", dst, strerror(errno)); return 1; }
            off += w;
        }
    }
    if (n < 0) { fprintf(stderr, "confine-copy: read %s: %s\n", src, strerror(errno)); return 1; }
    if (close(out) < 0) { fprintf(stderr, "confine-copy: close %s: %s\n", dst, strerror(errno)); return 1; }
    return 0;
}
