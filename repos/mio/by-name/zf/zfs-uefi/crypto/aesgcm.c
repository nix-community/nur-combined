/*
 * AES-256-GCM for the ZFS boot reader.  See aesgcm.h.
 *
 * The S-box is derived from the field inverse instead of being pasted as 256
 * constants, which keeps this file reviewable: the only table left is the
 * round-key schedule built at init time.  GHASH multiplies bit by bit, which is
 * slow but short, and ciphertext is authenticated before any plaintext is
 * written.
 */

#include "aesgcm.h"

struct aes256 {
	uint32_t rk[60];
};

static uint8_t sbox[256];
static int sbox_ready;

static uint8_t xtime(uint8_t x)
{
	return ((uint8_t)(x << 1) ^ (uint8_t)((x & 0x80) ? 0x1b : 0x00));
}

/* Carry-less product in GF(2^8); only used to derive the S-box. */
static uint8_t gmul(uint8_t a, uint8_t b)
{
	uint8_t p = 0;

	while (b != 0) {
		if (b & 1)
			p ^= a;
		a = xtime(a);
		b >>= 1;
	}
	return (p);
}

static uint8_t rotl8(uint8_t x, unsigned n)
{
	return ((uint8_t)((x << n) | (x >> (8 - n))));
}

static void init_sbox(void)
{
	unsigned i;

	if (sbox_ready)
		return;

	for (i = 0; i < 256; i++) {
		uint8_t a = (uint8_t)i;
		uint8_t inv = 0;
		uint8_t r = 1;
		unsigned e = 254;

		if (i != 0) {
			/* inv = a^254, i.e. the multiplicative inverse. */
			while (e != 0) {
				if (e & 1)
					r = gmul(r, a);
				a = gmul(a, a);
				e >>= 1;
			}
			inv = r;
		}
		sbox[i] = (uint8_t)(inv ^ rotl8(inv, 1) ^ rotl8(inv, 2) ^
		    rotl8(inv, 3) ^ rotl8(inv, 4) ^ 0x63);
	}
	sbox_ready = 1;
}

static uint32_t be32(const uint8_t *p)
{
	return (((uint32_t)p[0] << 24) | ((uint32_t)p[1] << 16) |
	    ((uint32_t)p[2] << 8) | (uint32_t)p[3]);
}

static uint64_t be64(const uint8_t *p)
{
	return (((uint64_t)be32(p) << 32) | (uint64_t)be32(p + 4));
}

static uint32_t sub_word(uint32_t w)
{
	return (((uint32_t)sbox[(w >> 24) & 0xff] << 24) |
	    ((uint32_t)sbox[(w >> 16) & 0xff] << 16) |
	    ((uint32_t)sbox[(w >> 8) & 0xff] << 8) | sbox[w & 0xff]);
}

static uint32_t rot_word(uint32_t w)
{
	return ((w << 8) | (w >> 24));
}

static void aes256_init(struct aes256 *a, const uint8_t key[32])
{
	uint32_t rcon = 1;
	int i;

	init_sbox();

	for (i = 0; i < 8; i++)
		a->rk[i] = be32(key + 4 * i);

	/* AES-256: 14 rounds, so 4 * (14 + 1) = 60 words. */
	for (i = 8; i < 60; i++) {
		uint32_t t = a->rk[i - 1];

		if (i % 8 == 0) {
			t = sub_word(rot_word(t)) ^ (rcon << 24);
			rcon = xtime((uint8_t)rcon);
		} else if (i % 8 == 4) {
			t = sub_word(t);
		}
		a->rk[i] = a->rk[i - 8] ^ t;
	}
}

static void add_round_key(uint8_t s[16], const uint32_t *rk)
{
	int c;
	int r;

	for (c = 0; c < 4; c++) {
		for (r = 0; r < 4; r++)
			s[c * 4 + r] ^= (uint8_t)(rk[c] >> (24 - 8 * r));
	}
}

static void sub_bytes(uint8_t s[16])
{
	int i;

	for (i = 0; i < 16; i++)
		s[i] = sbox[s[i]];
}

static void shift_rows(uint8_t s[16])
{
	uint8_t t[16];
	int c;
	int r;

	for (c = 0; c < 4; c++) {
		for (r = 0; r < 4; r++)
			t[c * 4 + r] = s[((c + r) & 3) * 4 + r];
	}
	for (r = 0; r < 16; r++)
		s[r] = t[r];
}

static void mix_columns(uint8_t s[16])
{
	int c;

	for (c = 0; c < 4; c++) {
		uint8_t *p = s + c * 4;
		uint8_t a0 = p[0], a1 = p[1], a2 = p[2], a3 = p[3];
		uint8_t t0 = xtime(a0) ^ xtime(a1) ^ a1 ^ a2 ^ a3;
		uint8_t t1 = xtime(a1) ^ xtime(a2) ^ a2 ^ a0 ^ a3;
		uint8_t t2 = xtime(a2) ^ xtime(a3) ^ a3 ^ a0 ^ a1;
		uint8_t t3 = xtime(a3) ^ xtime(a0) ^ a0 ^ a1 ^ a2;

		p[0] = t0;
		p[1] = t1;
		p[2] = t2;
		p[3] = t3;
	}
}

static void aes256_block(const struct aes256 *a, const uint8_t in[16],
    uint8_t out[16])
{
	uint8_t s[16];
	int i;
	int round;

	for (i = 0; i < 16; i++)
		s[i] = in[i];

	add_round_key(s, a->rk);
	for (round = 1; round <= 14; round++) {
		sub_bytes(s);
		shift_rows(s);
		if (round != 14)
			mix_columns(s);
		add_round_key(s, a->rk + 4 * round);
	}
	for (i = 0; i < 16; i++)
		out[i] = s[i];
}

/* ---- GHASH ---- */

static void gf_shift_right(uint64_t v[2])
{
	uint64_t lsb = v[1] & 1;

	v[1] = (v[1] >> 1) | (v[0] << 63);
	v[0] >>= 1;
	if (lsb)
		v[0] ^= 0xe100000000000000ULL;
}

/* z = x * h in GF(2^128), MSB-first as GCM numbers its bits. */
static void gf_mul(uint64_t x[2], const uint64_t h[2])
{
	uint64_t z[2] = { 0, 0 };
	uint64_t v[2] = { h[0], h[1] };
	int i;

	for (i = 0; i < 128; i++) {
		if ((x[i >> 6] >> (63 - (i & 63))) & 1) {
			z[0] ^= v[0];
			z[1] ^= v[1];
		}
		gf_shift_right(v);
	}
	x[0] = z[0];
	x[1] = z[1];
}

static void ghash_update(uint64_t y[2], const uint64_t h[2],
    const uint8_t *data, size_t len)
{
	uint8_t block[16];
	size_t n;
	size_t i;

	while (len != 0) {
		n = len < sizeof (block) ? len : sizeof (block);
		for (i = 0; i < n; i++)
			block[i] = data[i];
		for (; i < sizeof (block); i++)
			block[i] = 0;

		y[0] ^= be64(block);
		y[1] ^= be64(block + 8);
		gf_mul(y, h);

		data += n;
		len -= n;
	}
}

static void ghash_lengths(uint64_t y[2], const uint64_t h[2],
    size_t aad_len, size_t len)
{
	uint8_t block[16];
	uint64_t abits = (uint64_t)aad_len * 8;
	uint64_t cbits = (uint64_t)len * 8;
	int i;

	for (i = 0; i < 8; i++) {
		block[i] = (uint8_t)(abits >> (56 - 8 * i));
		block[8 + i] = (uint8_t)(cbits >> (56 - 8 * i));
	}
	y[0] ^= be64(block);
	y[1] ^= be64(block + 8);
	gf_mul(y, h);
}

static void gcm_ctr(const struct aes256 *a, const uint8_t j0[16],
    const uint8_t *in, uint8_t *out, size_t len)
{
	uint8_t ctr[16];
	uint8_t ks[16];
	uint32_t c;
	size_t n;
	size_t i;

	for (i = 0; i < 16; i++)
		ctr[i] = j0[i];

	while (len != 0) {
		c = be32(ctr + 12);
		c++;
		ctr[12] = (uint8_t)(c >> 24);
		ctr[13] = (uint8_t)(c >> 16);
		ctr[14] = (uint8_t)(c >> 8);
		ctr[15] = (uint8_t)c;

		aes256_block(a, ctr, ks);

		n = len < 16 ? len : 16;
		for (i = 0; i < n; i++)
			out[i] = (uint8_t)(in[i] ^ ks[i]);

		in += n;
		out += n;
		len -= n;
	}
}

static void gcm_start(const struct aes256 *a, const uint8_t iv[12],
    uint8_t j0[16], uint64_t h[2])
{
	uint8_t zero[16] = { 0 };

	aes256_block(a, zero, zero);
	h[0] = be64(zero);
	h[1] = be64(zero + 8);

	for (int i = 0; i < 12; i++)
		j0[i] = iv[i];
	j0[12] = 0;
	j0[13] = 0;
	j0[14] = 0;
	j0[15] = 1;
}

static void gcm_tag(const struct aes256 *a, const uint8_t j0[16],
    const uint64_t h[2], const uint8_t *aad, size_t aad_len,
    const uint8_t *ct, size_t len, uint8_t tag[16])
{
	uint64_t y[2] = { 0, 0 };
	uint8_t ek[16];
	int i;

	if (aad_len != 0)
		ghash_update(y, h, aad, aad_len);
	ghash_update(y, h, ct, len);
	ghash_lengths(y, h, aad_len, len);

	aes256_block(a, j0, ek);
	for (i = 0; i < 16; i++)
		tag[i] = (uint8_t)(ek[i] ^ (uint8_t)(y[i >> 3] >>
		    (56 - 8 * (i & 7))));
}

void aes256_gcm_encrypt(const uint8_t key[AES256_GCM_KEY_LEN],
    const uint8_t iv[AES256_GCM_IV_LEN], const uint8_t *aad, size_t aad_len,
    const uint8_t *in, size_t len, uint8_t *out,
    uint8_t tag[AES256_GCM_TAG_LEN])
{
	struct aes256 a;
	uint8_t j0[16];
	uint64_t h[2];

	aes256_init(&a, key);
	gcm_start(&a, iv, j0, h);
	gcm_ctr(&a, j0, in, out, len);
	gcm_tag(&a, j0, h, aad, aad_len, out, len, tag);
}

int aes256_gcm_decrypt(const uint8_t key[AES256_GCM_KEY_LEN],
    const uint8_t iv[AES256_GCM_IV_LEN], const uint8_t *aad, size_t aad_len,
    const uint8_t *in, size_t len, uint8_t *out,
    const uint8_t tag[AES256_GCM_TAG_LEN])
{
	struct aes256 a;
	uint8_t j0[16];
	uint64_t h[2];
	uint8_t want[16];
	uint8_t diff = 0;
	int i;

	aes256_init(&a, key);
	gcm_start(&a, iv, j0, h);
	gcm_tag(&a, j0, h, aad, aad_len, in, len, want);

	for (i = 0; i < 16; i++)
		diff |= (uint8_t)(want[i] ^ tag[i]);
	if (diff != 0)
		return (-1);

	gcm_ctr(&a, j0, in, out, len);
	return (0);
}
