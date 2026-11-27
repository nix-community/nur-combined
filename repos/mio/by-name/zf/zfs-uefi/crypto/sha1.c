/*
 * SHA-1, HMAC-SHA1 and PBKDF2-HMAC-SHA1.  See sha1.h.
 *
 * Straight FIPS 180-1 SHA-1 and RFC 2898 PBKDF2; no libc, stack only.
 */

#include "sha1.h"

struct sha1_ctx {
	uint32_t h[5];
	uint8_t buf[SHA1_BLOCK_LEN];
	size_t have;
	uint64_t bytes;
};

static uint32_t rol32(uint32_t x, unsigned n)
{
	return ((x << n) | (x >> (32 - n)));
}

static uint32_t be32(const uint8_t *p)
{
	return (((uint32_t)p[0] << 24) | ((uint32_t)p[1] << 16) |
	    ((uint32_t)p[2] << 8) | (uint32_t)p[3]);
}

static void sha1_compress(uint32_t h[5], const uint8_t block[SHA1_BLOCK_LEN])
{
	uint32_t w[80];
	uint32_t a, b, c, d, e;
	int i;

	for (i = 0; i < 16; i++)
		w[i] = be32(block + 4 * i);
	for (i = 16; i < 80; i++)
		w[i] = rol32(w[i - 3] ^ w[i - 8] ^ w[i - 14] ^ w[i - 16], 1);

	a = h[0];
	b = h[1];
	c = h[2];
	d = h[3];
	e = h[4];

	for (i = 0; i < 80; i++) {
		uint32_t f, k, t;

		if (i < 20) {
			f = (b & c) | ((~b) & d);
			k = 0x5a827999;
		} else if (i < 40) {
			f = b ^ c ^ d;
			k = 0x6ed9eba1;
		} else if (i < 60) {
			f = (b & c) | (b & d) | (c & d);
			k = 0x8f1bbcdc;
		} else {
			f = b ^ c ^ d;
			k = 0xca62c1d6;
		}

		t = rol32(a, 5) + f + e + k + w[i];
		e = d;
		d = c;
		c = rol32(b, 30);
		b = a;
		a = t;
	}

	h[0] += a;
	h[1] += b;
	h[2] += c;
	h[3] += d;
	h[4] += e;
}

static void sha1_init(struct sha1_ctx *c)
{
	c->h[0] = 0x67452301;
	c->h[1] = 0xefcdab89;
	c->h[2] = 0x98badcfe;
	c->h[3] = 0x10325476;
	c->h[4] = 0xc3d2e1f0;
	c->have = 0;
	c->bytes = 0;
}

static void sha1_update(struct sha1_ctx *c, const uint8_t *data, size_t len)
{
	size_t i, j;

	c->bytes += len;

	while (len != 0) {
		if (c->have == 0 && len >= SHA1_BLOCK_LEN) {
			sha1_compress(c->h, data);
			data += SHA1_BLOCK_LEN;
			len -= SHA1_BLOCK_LEN;
			continue;
		}

		i = SHA1_BLOCK_LEN - c->have;
		if (i > len)
			i = len;
		for (j = 0; j < i; j++)
			c->buf[c->have + j] = data[j];
		c->have += i;
		data += i;
		len -= i;

		if (c->have == SHA1_BLOCK_LEN) {
			sha1_compress(c->h, c->buf);
			c->have = 0;
		}
	}
}

static void sha1_final(struct sha1_ctx *c, uint8_t out[SHA1_DIGEST_LEN])
{
	uint64_t bits = c->bytes * 8;
	size_t i;

	c->buf[c->have++] = 0x80;
	if (c->have > SHA1_BLOCK_LEN - 8) {
		while (c->have < SHA1_BLOCK_LEN)
			c->buf[c->have++] = 0;
		sha1_compress(c->h, c->buf);
		c->have = 0;
	}
	while (c->have < SHA1_BLOCK_LEN - 8)
		c->buf[c->have++] = 0;
	for (i = 0; i < 8; i++)
		c->buf[SHA1_BLOCK_LEN - 8 + i] = (uint8_t)(bits >> (56 - 8 * i));
	sha1_compress(c->h, c->buf);

	for (i = 0; i < 5; i++) {
		out[4 * i + 0] = (uint8_t)(c->h[i] >> 24);
		out[4 * i + 1] = (uint8_t)(c->h[i] >> 16);
		out[4 * i + 2] = (uint8_t)(c->h[i] >> 8);
		out[4 * i + 3] = (uint8_t)c->h[i];
	}
}

void sha1(const uint8_t *data, size_t len, uint8_t out[SHA1_DIGEST_LEN])
{
	struct sha1_ctx c;

	sha1_init(&c);
	sha1_update(&c, data, len);
	sha1_final(&c, out);
}

void hmac_sha1(const uint8_t *key, size_t key_len, const uint8_t *data,
    size_t len, uint8_t out[SHA1_DIGEST_LEN])
{
	struct sha1_ctx c;
	uint8_t k[SHA1_BLOCK_LEN];
	uint8_t inner[SHA1_DIGEST_LEN];
	size_t i;

	for (i = 0; i < SHA1_BLOCK_LEN; i++)
		k[i] = 0;
	if (key_len > SHA1_BLOCK_LEN)
		sha1(key, key_len, k);
	else
		for (i = 0; i < key_len; i++)
			k[i] = key[i];

	for (i = 0; i < SHA1_BLOCK_LEN; i++)
		k[i] ^= 0x36;
	sha1_init(&c);
	sha1_update(&c, k, SHA1_BLOCK_LEN);
	sha1_update(&c, data, len);
	sha1_final(&c, inner);

	for (i = 0; i < SHA1_BLOCK_LEN; i++)
		k[i] ^= (uint8_t)(0x36 ^ 0x5c);
	sha1_init(&c);
	sha1_update(&c, k, SHA1_BLOCK_LEN);
	sha1_update(&c, inner, SHA1_DIGEST_LEN);
	sha1_final(&c, out);
}

void pbkdf2_sha1(const uint8_t *pass, size_t pass_len, const uint8_t *salt,
    size_t salt_len, uint32_t iterations, uint8_t *out, size_t out_len)
{
	uint8_t u[SHA1_DIGEST_LEN], t[SHA1_DIGEST_LEN];
	uint32_t counter = 1;
	uint32_t i;
	size_t j, k;

	while (out_len != 0) {
		uint8_t ctr[4] = {
			(uint8_t)(counter >> 24), (uint8_t)(counter >> 16),
			(uint8_t)(counter >> 8), (uint8_t)counter
		};

		/* U1 = HMAC(pass, salt || INT(counter)) */
		{
			struct sha1_ctx c;
			uint8_t k[SHA1_BLOCK_LEN];
			size_t n;

			for (n = 0; n < SHA1_BLOCK_LEN; n++)
				k[n] = 0;
			if (pass_len > SHA1_BLOCK_LEN) {
				sha1(pass, pass_len, k);
			} else {
				for (n = 0; n < pass_len; n++)
					k[n] = pass[n];
			}
			for (n = 0; n < SHA1_BLOCK_LEN; n++)
				k[n] ^= 0x36;
			sha1_init(&c);
			sha1_update(&c, k, SHA1_BLOCK_LEN);
			sha1_update(&c, salt, salt_len);
			sha1_update(&c, ctr, sizeof (ctr));
			sha1_final(&c, u);

			for (n = 0; n < SHA1_BLOCK_LEN; n++)
				k[n] ^= (uint8_t)(0x36 ^ 0x5c);
			sha1_init(&c);
			sha1_update(&c, k, SHA1_BLOCK_LEN);
			sha1_update(&c, u, SHA1_DIGEST_LEN);
			sha1_final(&c, u);
		}

		for (j = 0; j < SHA1_DIGEST_LEN; j++)
			t[j] = u[j];

		for (i = 1; i < iterations; i++) {
			hmac_sha1(pass, pass_len, u, SHA1_DIGEST_LEN, u);
			for (j = 0; j < SHA1_DIGEST_LEN; j++)
				t[j] ^= u[j];
		}

		k = out_len < SHA1_DIGEST_LEN ? out_len : SHA1_DIGEST_LEN;
		for (j = 0; j < k; j++)
			out[j] = t[j];
		out += k;
		out_len -= k;
		counter++;
	}
}
