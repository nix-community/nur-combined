/*
 * HKDF-SHA512 (RFC 5869), on top of the SHA-512/HMAC-SHA512 already in this
 * directory.  Only what ZFS needs: derive one block key from a master key and
 * a salt, in a single HKDF round.
 */
#include "hkdf.h"
#include "sha512.h"

int
zfse_hkdf_sha512(const uint8_t *ikm, size_t ikm_len, const uint8_t *salt,
    size_t salt_len, const uint8_t *info, size_t info_len, uint8_t *out,
    size_t out_len)
{
	uint8_t zero_salt[SHA512_DIGEST_LEN];
	uint8_t prk[SHA512_DIGEST_LEN];
	uint8_t block[SHA512_DIGEST_LEN + HKDF_SHA512_MAX_INFO + 1];
	uint8_t t[SHA512_DIGEST_LEN];
	size_t done, t_len, n, i;
	uint8_t counter;

	if (out_len == 0 || info_len > HKDF_SHA512_MAX_INFO)
		return (-1);
	if ((out_len + SHA512_DIGEST_LEN - 1) / SHA512_DIGEST_LEN > 255)
		return (-1);

	/* RFC 5869: absent salt is HashLen zero bytes. */
	if (salt == NULL || salt_len == 0) {
		for (i = 0; i < sizeof (zero_salt); i++)
			zero_salt[i] = 0;
		salt = zero_salt;
		salt_len = sizeof (zero_salt);
	}

	/* Extract. */
	hmac_sha512(salt, salt_len, ikm, ikm_len, prk);

	/* Expand: T(n) = HMAC(PRK, T(n-1) | info | n). */
	done = 0;
	t_len = 0;
	for (counter = 1; done < out_len; counter++) {
		for (i = 0; i < t_len; i++)
			block[i] = t[i];
		for (i = 0; i < info_len; i++)
			block[t_len + i] = info[i];
		block[t_len + info_len] = counter;

		hmac_sha512(prk, sizeof (prk), block,
		    t_len + info_len + 1, t);
		t_len = sizeof (t);

		n = out_len - done;
		if (n > sizeof (t))
			n = sizeof (t);
		for (i = 0; i < n; i++)
			out[done + i] = t[i];
		done += n;
	}

	return (0);
}
