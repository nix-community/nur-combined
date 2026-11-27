/*
 * AES-256-GCM, sized for the ZFS boot reader.
 *
 * Only the bits zfs-efi needs: 96-bit IVs, 128-bit tags, and no libc, no
 * allocation, no OpenSSL.  GCM only ever encrypts with the block cipher, so
 * there is no inverse cipher to implement.
 */
#ifndef ZFS_EFI_AESGCM_H
#define ZFS_EFI_AESGCM_H

#include <stddef.h>
#include <stdint.h>

#define AES256_GCM_KEY_LEN 32
#define AES256_GCM_IV_LEN 12
#define AES256_GCM_TAG_LEN 16

void aes256_gcm_encrypt(const uint8_t key[AES256_GCM_KEY_LEN],
    const uint8_t iv[AES256_GCM_IV_LEN], const uint8_t *aad, size_t aad_len,
    const uint8_t *in, size_t len, uint8_t *out,
    uint8_t tag[AES256_GCM_TAG_LEN]);

/*
 * Returns 0 and writes the plaintext only when the tag verifies, -1 otherwise.
 * in and out may be the same buffer.  ZFS cannot distinguish a wrong key from
 * a corrupt block, so callers should treat -1 as "unreadable", never as data.
 */
int aes256_gcm_decrypt(const uint8_t key[AES256_GCM_KEY_LEN],
    const uint8_t iv[AES256_GCM_IV_LEN], const uint8_t *aad, size_t aad_len,
    const uint8_t *in, size_t len, uint8_t *out,
    const uint8_t tag[AES256_GCM_TAG_LEN]);

#endif
