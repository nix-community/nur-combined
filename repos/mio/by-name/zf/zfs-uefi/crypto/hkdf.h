/*
 * HKDF-SHA512 (RFC 5869) for the ZFS boot reader.
 *
 * ZFS derives a block's encryption key from the dataset master key and the
 * block pointer's 64-bit salt with HKDF-SHA512.  The "salt" argument of HKDF
 * is empty in that call; the block pointer's salt is passed as info, which is
 * why this takes both.  Out-of-line buffers only: there is no libc and no
 * allocation in the EFI image.
 */
#ifndef ZFS_EFI_HKDF_H
#define ZFS_EFI_HKDF_H

#include <stddef.h>
#include <stdint.h>

#define HKDF_SHA512_MAX_INFO 128

/*
 * Returns 0, or -1 if out_len is zero or would need more than 255 HKDF
 * blocks, or info_len exceeds HKDF_SHA512_MAX_INFO.
 */
int zfse_hkdf_sha512(const uint8_t *ikm, size_t ikm_len, const uint8_t *salt,
    size_t salt_len, const uint8_t *info, size_t info_len, uint8_t *out,
    size_t out_len);

#endif
