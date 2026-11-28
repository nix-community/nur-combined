/*
 * HKDF-SHA512 vectors generated with Python's hashlib/hmac, not by this
 * implementation.  Case 1 is the shape ZFS uses: empty HKDF salt, the block
 * pointer's 8-byte salt as info, and a 32-byte output key.  Case 2 exercises
 * a non-empty salt and multiple output blocks.
 */
#ifndef ZFS_EFI_HKDF_KAT_VECTORS_H
#define ZFS_EFI_HKDF_KAT_VECTORS_H

#define HKDF_KAT_IKM_1 "000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f"
#define HKDF_KAT_INFO_1 "0001020304050607"
#define HKDF_KAT_OUT_1 "a86b00dfaf898f8fd5ef9a8a39466dd92d01b85d92f5be3532f28b8f150db5ca"

#define HKDF_KAT_IKM_2 "686b64662d74657374"
#define HKDF_KAT_SALT_2 "73616c74"
#define HKDF_KAT_INFO_2 "696e666f"
#define HKDF_KAT_OUT_2 "29aefe708e3a0596be6e76d0c37487e16a48eb8272fb10ac374749a70f1deefad8738b400ad907ea1dde"

#endif
