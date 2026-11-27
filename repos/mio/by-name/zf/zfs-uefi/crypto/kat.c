/*
 * Known-answer tests for aesgcm.c.
 *
 * The GCM vectors were produced with OpenSSL's EVP interface (python
 * cryptography), not by this implementation, and the plaintext/AAD are simple
 * deterministic patterns so they can be regenerated.  Cases cover: empty
 * plaintext (where the tag is AES-256(J0) itself, so the cipher is checked
 * without GHASH), a single block, a non-block-multiple length with an odd AAD
 * length, and the exact shape ZFS wraps dataset keys in (32-byte key plus
 * 64-byte HMAC key = 96 bytes, with the 24-byte AAD of a version-1 key).
 */

#include <stdio.h>
#include <string.h>

#include "aesgcm.h"
#include "sha1.h"
#include "sha512.h"
#include "sha1_kat_vectors.h"

struct gcm_vec {
	const char *name;
	const char *aad;
	const char *pt;
	const char *ct;
	const char *tag;
};

static const char *key_hex =
    "01080f161d242b323940474e555c636a71787f868d949ba2a9b0b7bec5ccd3da";
static const char *iv_hex = "030a11181f262d343b424950";

static const struct gcm_vec vectors[] = {
	{
		.name = "empty plaintext, empty aad",
		.aad = "",
		.pt = "",
		.ct = "",
		.tag = "7ae91615d6cae310d28fa3d2bf0ad925",
	},
	{
		.name = "one block, no aad",
		.aad = "",
		.pt = "0910171e252c333a41484f565d646b72",
		.ct = "b2080bfcbebd1f8236e30c97663fcb32",
		.tag = "aca2344f98ff0fb024408e036d294a63",
	},
	{
		.name = "60 bytes, 13-byte aad",
		.aad = "050c131a21282f363d444b5259",
		.pt = "0910171e252c333a41484f565d646b727980878e959ca3aab1b8bfc6cdd4db"
		    "e2e9f0f7fe050c131a21282f363d444b525960676e757c838a91989fa6",
		.ct = "b2080bfcbebd1f8236e30c97663fcb32a5099155051d8c696cd9332a4d4186"
		    "3205d76bd78f85c7f4718960be45d43ba0072cf3433759a00f775278ef",
		.tag = "db950e830b8a1d6aee728e5794e81613",
	},
	{
		.name = "96-byte wrapped key, 24-byte aad",
		.aad = "050c131a21282f363d444b525960676e757c838a91989fa6",
		.pt = "0910171e252c333a41484f565d646b727980878e959ca3aab1b8bfc6cdd4db"
		    "e2e9f0f7fe050c131a21282f363d444b525960676e757c838a91989fa6adb4"
		    "bbc2c9d0d7dee5ecf3fa01080f161d242b323940474e555c636a71787f868d"
		    "949ba2",
		.ct = "b2080bfcbebd1f8236e30c97663fcb32a5099155051d8c696cd9332a4d4186"
		    "3205d76bd78f85c7f4718960be45d43ba0072cf3433759a00f775278efead0"
		    "e5e32a1c4d411533a118411c5237e5e82407259b2628cec9e04f6f2a75521b"
		    "962f45",
		.tag = "58a65325fb2fed1a9447960fadff9e43",
	},
};

static int failures;

static int hexval(char c)
{
	if (c >= '0' && c <= '9')
		return (c - '0');
	if (c >= 'a' && c <= 'f')
		return (c - 'a' + 10);
	return (-1);
}

static int unhex(const char *s, uint8_t *out, size_t max, size_t *len)
{
	size_t n = strlen(s);
	size_t i;

	if (n % 2 != 0 || n / 2 > max)
		return (-1);

	for (i = 0; i < n / 2; i++) {
		int hi = hexval(s[2 * i]);
		int lo = hexval(s[2 * i + 1]);

		if (hi < 0 || lo < 0)
			return (-1);
		out[i] = (uint8_t)((hi << 4) | lo);
	}
	*len = n / 2;
	return (0);
}

static void check(int ok, const char *name, const char *what)
{
	if (!ok) {
		printf("FAIL %s: %s\n", name, what);
		failures++;
	}
}

static void run_vec(const struct gcm_vec *v)
{
	uint8_t key[AES256_GCM_KEY_LEN];
	uint8_t iv[AES256_GCM_IV_LEN];
	uint8_t aad[64];
	uint8_t pt[256];
	uint8_t ct[256];
	uint8_t want[256];
	uint8_t tag[AES256_GCM_TAG_LEN];
	uint8_t want_tag[AES256_GCM_TAG_LEN];
	uint8_t out[256];
	size_t aad_len, pt_len, want_len, tag_len, iv_len, key_len;
	int ok = 1;

	ok &= unhex(key_hex, key, sizeof (key), &key_len) == 0 &&
	    key_len == sizeof (key);
	ok &= unhex(iv_hex, iv, sizeof (iv), &iv_len) == 0 &&
	    iv_len == sizeof (iv);
	ok &= unhex(v->aad, aad, sizeof (aad), &aad_len) == 0;
	ok &= unhex(v->pt, pt, sizeof (pt), &pt_len) == 0;
	ok &= unhex(v->ct, want, sizeof (want), &want_len) == 0;
	ok &= unhex(v->tag, want_tag, sizeof (want_tag), &tag_len) == 0 &&
	    tag_len == sizeof (want_tag);

	check(ok, v->name, "vector did not decode");
	if (!ok)
		return;
	check(want_len == pt_len, v->name, "ciphertext length differs");

	/* Encrypt and compare ciphertext and tag. */
	aes256_gcm_encrypt(key, iv, aad, aad_len, pt, pt_len, ct, tag);
	check(memcmp(ct, want, pt_len) == 0, v->name, "ciphertext mismatch");
	check(memcmp(tag, want_tag, sizeof (tag)) == 0, v->name,
	    "tag mismatch");

	/* Decrypt back, and again with in and out aliased. */
	check(aes256_gcm_decrypt(key, iv, aad, aad_len, want, pt_len, out, tag)
	    == 0, v->name, "decrypt rejected a valid tag");
	check(memcmp(out, pt, pt_len) == 0, v->name, "round-trip mismatch");

	memcpy(out, want, pt_len);
	check(aes256_gcm_decrypt(key, iv, aad, aad_len, out, pt_len, out,
	    tag) == 0 && memcmp(out, pt, pt_len) == 0, v->name,
	    "aliased round-trip mismatch");

	/* A tampered tag must be rejected and must not write plaintext. */
	want_tag[0] ^= 0x01;
	memset(out, 0xaa, sizeof (out));
	check(aes256_gcm_decrypt(key, iv, aad, aad_len, want, pt_len, out,
	    want_tag) == -1, v->name, "bad tag accepted");
	check(out[0] == 0xaa, v->name, "plaintext written before verification");
}

static int hex_eq(const uint8_t *got, const char *want_hex, size_t n)
{
	uint8_t want[64];
	size_t len;

	if (n > sizeof (want) || unhex(want_hex, want, sizeof (want), &len) != 0)
		return (0);
	return (len == n && memcmp(got, want, n) == 0);
}

static void run_sha512(void)
{
	uint8_t out[SHA512_DIGEST_LEN];
	uint8_t key[32];
	size_t i;

	for (i = 0; i < sizeof (key); i++)
		key[i] = (uint8_t)i;

	sha512((const uint8_t *)"abc", 3, out);
	check(hex_eq(out,
	    "ddaf35a193617abacc417349ae20413112e6fa4e89a97ea20a9eeee64b55d39a"
	    "2192992a274fc1a836ba3c23a3feebbd454d4423643ce80e2a9ac94fa54ca49f",
	    sizeof (out)), "sha512", "abc vector");

	sha512(NULL, 0, out);
	check(hex_eq(out,
	    "cf83e1357eefb8bdf1542850d66d8007d620e4050b5715dc83f4a921d36ce9ce"
	    "47d0d13c5d85f2b0ff8318d2877eec2f63b931bd47417a81a538327af927da3e",
	    sizeof (out)), "sha512", "empty vector");

	hmac_sha512(key, sizeof (key), (const uint8_t *)"abc", 3, out);
	check(hex_eq(out,
	    "69d4a21e226bf0d348cb9a847c01cf24e93e8ac30d7c951704b936f82f795a62"
	    "4b470e23abd33ac8700e797f0f2a499b932bac7d283bbbb37d8fecf70d5e08a7",
	    sizeof (out)), "hmac-sha512", "abc vector");
}

static void run_sha1(void)
{
	uint8_t out[SHA1_DIGEST_LEN];
	uint8_t dk[32];
	const uint8_t pass[] = "password";
	const uint8_t salt[] = "salt";

	sha1((const uint8_t *)"abc", 3, out);
	check(hex_eq(out, SHA1_KAT_ABC, sizeof (out)), "sha1", "abc vector");

	sha1(NULL, 0, out);
	check(hex_eq(out, SHA1_KAT_EMPTY, sizeof (out)), "sha1",
	    "empty vector");

	pbkdf2_sha1(pass, sizeof (pass) - 1, salt, sizeof (salt) - 1, 1,
	    dk, sizeof (dk));
	check(hex_eq(dk, PBKDF2_SHA1_ITERS1, sizeof (dk)), "pbkdf2-sha1",
	    "1 iteration");

	pbkdf2_sha1(pass, sizeof (pass) - 1, salt, sizeof (salt) - 1, 4096,
	    dk, sizeof (dk));
	check(hex_eq(dk, PBKDF2_SHA1_ITERS4096, sizeof (dk)), "pbkdf2-sha1",
	    "4096 iterations");
}

int main(void)
{
	size_t i;

	for (i = 0; i < sizeof (vectors) / sizeof (vectors[0]); i++) {
		run_vec(&vectors[i]);
		if (failures == 0)
			printf("PASS %s\n", vectors[i].name);
	}

	{
		int before = failures;

		run_sha512();
		if (failures == before)
			printf("PASS SHA-512 and HMAC-SHA512 vectors\n");

		before = failures;
		run_sha1();
		if (failures == before)
			printf("PASS SHA-1 and PBKDF2-HMAC-SHA1 vectors\n");
	}

	if (failures != 0) {
		printf("%zu check(s) failed\n", (size_t)failures);
		return (1);
	}
	printf("all %zu AES-256-GCM vectors passed\n",
	    sizeof (vectors) / sizeof (vectors[0]));
	return (0);
}
