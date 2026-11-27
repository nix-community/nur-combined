/*
 * Host test for the encrypted-dataset key path: same setup as upstream's
 * test/native_read_test.c, but before mounting it either
 *
 *   ZFS_KEY_FILE=<file>       hands the reader 32 raw keyfile bytes, or
 *   ZFS_PASSPHRASE=<phrase>   registers a key provider, like the EFI console
 *                             prompt does, and lets the reader derive the
 *                             wrapping key with PBKDF2-HMAC-SHA1.
 *
 * ZFS_PASSPHRASE_FIRST_WRONG=1 makes the first "typed" entry wrong, which must
 * be rejected, re-prompted and then succeed.
 *
 * Expected messages: "dataset key loaded" on success, "unwrap failed" when the
 * key is wrong, "try again" when a re-prompt happened.
 *
 * Usage: enc_read_test image offset size
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int open(const char *, int, ...);
extern long pread(int, void *, unsigned long, long);
extern long read(int, void *, unsigned long);

#include "../src/zfsengine.c"

int
pager_output(const char *s)
{
    fputs(s, stdout);
    return 0;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
{
    size_t len = strlen(src);

    if (size) {
        size_t n = len >= size ? size - 1 : len;
        memcpy(dst, src, n);
        dst[n] = 0;
    }

    return len;
}

static int fd;
static uint64_t base;

static int
rd(void *priv, uint64_t off, void *buf, size_t n)
{
    (void)priv;
    return pread(fd, buf, n, base + off) == (ssize_t)n ? 0 : 5;
}

/* What the EFI console does, minus the keyboard. */
static int
typed_key(char *buf, size_t buflen, void *priv)
{
    static int calls;
    const char *want = priv;
    const char *s = want;

    calls++;
    if (calls == 1 && getenv("ZFS_PASSPHRASE_FIRST_WRONG") != NULL)
        s = "not the passphrase";

    if (strlen(s) + 1 > buflen)
        return -1;
    strcpy(buf, s);
    return 0;
}

int
main(int argc, char **argv)
{
    struct zfse_pool *pool;
    struct zfse_mount *m;
    uint8_t key[32];
    const char *keyfile, *passphrase;
    int kfd, rc, got;

    if (argc < 4) {
        fprintf(stderr, "usage: %s image offset size\n", argv[0]);
        return 2;
    }

    zfse_init();

    keyfile = getenv("ZFS_KEY_FILE");
    passphrase = getenv("ZFS_PASSPHRASE");

    if (keyfile != NULL) {
        kfd = open(keyfile, 0);
        got = kfd < 0 ? -1 : (int)read(kfd, key, sizeof(key));
        if (got != (int)sizeof(key)) {
            fprintf(stderr, "could not read 32 bytes from %s\n", keyfile);
            return 2;
        }
        if (zfse_set_wrapping_key(key, sizeof(key)) != 0) {
            fprintf(stderr, "zfse_set_wrapping_key failed\n");
            return 2;
        }
    } else if (passphrase != NULL) {
        if (zfse_set_key_provider(typed_key, (void *)passphrase) != 0) {
            fprintf(stderr, "zfse_set_key_provider failed\n");
            return 2;
        }
    }

    fd = open(argv[1], 0);
    base = strtoull(argv[2], 0, 0);

    rc = zfse_probe(rd, strtoull(argv[3], 0, 0), NULL, &pool);
    printf("probe rc %d\n", rc);
    if (rc != 0)
        return 2;

    rc = zfse_mount(pool, &m);
    printf("mount rc %d\n", rc);

    /* Reading the dataset is still refused until block decryption lands; this
     * test is about the key path and its messages. */
    return 0;
}
