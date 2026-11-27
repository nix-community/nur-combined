/*
 * SHA-1 and PBKDF2-HMAC-SHA1 for the ZFS boot reader.
 *
 * A dataset created with keyformat=passphrase derives its wrapping key with
 * PBKDF2-HMAC-SHA1(passphrase, salt = LE64(pbkdf2salt), pbkdf2iters), 32 bytes
 * (see libzfs_crypto.c:derive_key), so this is what a typed passphrase needs.
 * SHA-1 is only used here, never for authentication.
 */
#ifndef ZFS_EFI_SHA1_H
#define ZFS_EFI_SHA1_H

#include <stddef.h>
#include <stdint.h>

#define SHA1_DIGEST_LEN 20
#define SHA1_BLOCK_LEN 64

void sha1(const uint8_t *data, size_t len, uint8_t out[SHA1_DIGEST_LEN]);

void hmac_sha1(const uint8_t *key, size_t key_len, const uint8_t *data,
    size_t len, uint8_t out[SHA1_DIGEST_LEN]);

/* out_len may exceed the 20-byte digest; blocks are concatenated. */
void pbkdf2_sha1(const uint8_t *pass, size_t pass_len, const uint8_t *salt,
    size_t salt_len, uint32_t iterations, uint8_t *out, size_t out_len);

#endif
