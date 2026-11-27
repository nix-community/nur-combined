/*
 * SHA-512 and HMAC-SHA512 for the ZFS boot reader.
 *
 * ZFS stores the MAC of an encrypted dataset's metadata blocks as
 * SHA512-HMAC-256, so reading such a dataset needs this even though its leaf
 * data is AES-GCM.  No libc, no allocation; everything is on the stack.
 */
#ifndef ZFS_EFI_SHA512_H
#define ZFS_EFI_SHA512_H

#include <stddef.h>
#include <stdint.h>

#define SHA512_DIGEST_LEN 64
#define SHA512_BLOCK_LEN 128

void sha512(const uint8_t *data, size_t len, uint8_t out[SHA512_DIGEST_LEN]);

void hmac_sha512(const uint8_t *key, size_t key_len, const uint8_t *data,
    size_t len, uint8_t out[SHA512_DIGEST_LEN]);

#endif
