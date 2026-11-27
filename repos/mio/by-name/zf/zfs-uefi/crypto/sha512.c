/*
 * SHA-512 and HMAC-SHA512.  See sha512.h.
 *
 * The round constants are the standard FIPS 180-4 values; sha512_consts.h is
 * generated from OpenZFS's own sha2_generic.c so they cannot drift from what
 * the pool was written with.
 */

#include "sha512.h"
#include "sha512_consts.h"

struct sha512_ctx {
	uint64_t s[8];
	uint8_t buf[SHA512_BLOCK_LEN];
	size_t have;
	uint64_t bytes;
};

static uint64_t rotr(uint64_t x, unsigned n)
{
	return ((x >> n) | (x << (64 - n)));
}

static uint64_t be64(const uint8_t *p)
{
	return (((uint64_t)p[0] << 56) | ((uint64_t)p[1] << 48) |
	    ((uint64_t)p[2] << 40) | ((uint64_t)p[3] << 32) |
	    ((uint64_t)p[4] << 24) | ((uint64_t)p[5] << 16) |
	    ((uint64_t)p[6] << 8) | (uint64_t)p[7]);
}

static void compress(uint64_t s[8], const uint8_t block[SHA512_BLOCK_LEN])
{
	uint64_t w[80];
	uint64_t a, b, c, d, e, f, g, h;
	int i;

	for (i = 0; i < 16; i++)
		w[i] = be64(block + 8 * i);
	for (i = 16; i < 80; i++) {
		uint64_t s0 = rotr(w[i - 15], 1) ^ rotr(w[i - 15], 8) ^
		    (w[i - 15] >> 7);
		uint64_t s1 = rotr(w[i - 2], 19) ^ rotr(w[i - 2], 61) ^
		    (w[i - 2] >> 6);

		w[i] = w[i - 16] + s0 + w[i - 7] + s1;
	}

	a = s[0];
	b = s[1];
	c = s[2];
	d = s[3];
	e = s[4];
	f = s[5];
	g = s[6];
	h = s[7];

	for (i = 0; i < 80; i++) {
		uint64_t s1 = rotr(e, 14) ^ rotr(e, 18) ^ rotr(e, 41);
		uint64_t ch = (e & f) ^ ((~e) & g);
		uint64_t t1 = h + s1 + ch + sha512_k[i] + w[i];
		uint64_t s0 = rotr(a, 28) ^ rotr(a, 34) ^ rotr(a, 39);
		uint64_t maj = (a & b) ^ (a & c) ^ (b & c);
		uint64_t t2 = s0 + maj;

		h = g;
		g = f;
		f = e;
		e = d + t1;
		d = c;
		c = b;
		b = a;
		a = t1 + t2;
	}

	s[0] += a;
	s[1] += b;
	s[2] += c;
	s[3] += d;
	s[4] += e;
	s[5] += f;
	s[6] += g;
	s[7] += h;
}

static void sha512_init(struct sha512_ctx *c)
{
	int i;

	for (i = 0; i < 8; i++)
		c->s[i] = sha512_iv[i];
	c->have = 0;
	c->bytes = 0;
}

static void sha512_update(struct sha512_ctx *c, const uint8_t *data,
    size_t len)
{
	size_t i;

	c->bytes += len;

	while (len != 0) {
		if (c->have == 0 && len >= SHA512_BLOCK_LEN) {
			compress(c->s, data);
			data += SHA512_BLOCK_LEN;
			len -= SHA512_BLOCK_LEN;
			continue;
		}

		i = SHA512_BLOCK_LEN - c->have;
		if (i > len)
			i = len;
		for (size_t j = 0; j < i; j++)
			c->buf[c->have + j] = data[j];
		c->have += i;
		data += i;
		len -= i;

		if (c->have == SHA512_BLOCK_LEN) {
			compress(c->s, c->buf);
			c->have = 0;
		}
	}
}

static void sha512_final(struct sha512_ctx *c, uint8_t out[SHA512_DIGEST_LEN])
{
	uint64_t bits = c->bytes * 8;
	size_t i;

	c->buf[c->have++] = 0x80;
	if (c->have > SHA512_BLOCK_LEN - 16) {
		while (c->have < SHA512_BLOCK_LEN)
			c->buf[c->have++] = 0;
		compress(c->s, c->buf);
		c->have = 0;
	}
	/* The length field is 128 bits (offset 112..127); zero all of it,
	 * then write the low 64 bits.  Filling only to 112 leaves 112..119
	 * uninitialised. */
	while (c->have < SHA512_BLOCK_LEN - 8)
		c->buf[c->have++] = 0;

	for (i = 0; i < 8; i++)
		c->buf[SHA512_BLOCK_LEN - 8 + i] = (uint8_t)(bits >> (56 - 8 * i));
	compress(c->s, c->buf);

	for (i = 0; i < 8; i++) {
		out[8 * i + 0] = (uint8_t)(c->s[i] >> 56);
		out[8 * i + 1] = (uint8_t)(c->s[i] >> 48);
		out[8 * i + 2] = (uint8_t)(c->s[i] >> 40);
		out[8 * i + 3] = (uint8_t)(c->s[i] >> 32);
		out[8 * i + 4] = (uint8_t)(c->s[i] >> 24);
		out[8 * i + 5] = (uint8_t)(c->s[i] >> 16);
		out[8 * i + 6] = (uint8_t)(c->s[i] >> 8);
		out[8 * i + 7] = (uint8_t)c->s[i];
	}
}

void sha512(const uint8_t *data, size_t len, uint8_t out[SHA512_DIGEST_LEN])
{
	struct sha512_ctx c;

	sha512_init(&c);
	sha512_update(&c, data, len);
	sha512_final(&c, out);
}

void hmac_sha512(const uint8_t *key, size_t key_len, const uint8_t *data,
    size_t len, uint8_t out[SHA512_DIGEST_LEN])
{
	struct sha512_ctx c;
	uint8_t k[SHA512_BLOCK_LEN];
	uint8_t inner[SHA512_DIGEST_LEN];
	size_t i;

	for (i = 0; i < SHA512_BLOCK_LEN; i++)
		k[i] = 0;
	if (key_len > SHA512_BLOCK_LEN) {
		sha512(key, key_len, k);
	} else {
		for (i = 0; i < key_len; i++)
			k[i] = key[i];
	}

	for (i = 0; i < SHA512_BLOCK_LEN; i++)
		k[i] ^= 0x36;
	sha512_init(&c);
	sha512_update(&c, k, SHA512_BLOCK_LEN);
	sha512_update(&c, data, len);
	sha512_final(&c, inner);

	for (i = 0; i < SHA512_BLOCK_LEN; i++)
		k[i] ^= (uint8_t)(0x36 ^ 0x5c);
	sha512_init(&c);
	sha512_update(&c, k, SHA512_BLOCK_LEN);
	sha512_update(&c, inner, SHA512_DIGEST_LEN);
	sha512_final(&c, out);
}
