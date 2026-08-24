/**
 * @file tests/unit/test_updater.cpp
 * @brief Tests for signed update metadata helpers.
 */
#include "../tests_common.h"
#include "src/crypto.h"
#include "src/updater.h"

#include <openssl/evp.h>
#include <openssl/pem.h>

TEST(UpdaterVersionTest, ParsesStableAndDevelopmentVersions) {
  const auto stable = updater::parse_version("v1.2.3");
  ASSERT_TRUE(stable);
  EXPECT_EQ(stable->major, 1);
  EXPECT_EQ(stable->minor, 2);
  EXPECT_EQ(stable->patch, 3);
  EXPECT_FALSE(stable->prerelease);

  const auto prerelease = updater::parse_version("1.2.3-rc.1");
  ASSERT_TRUE(prerelease);
  EXPECT_TRUE(prerelease->prerelease);

  const auto development = updater::parse_version("0.1.0.4d394e7d2.dirty");
  ASSERT_TRUE(development);
  EXPECT_TRUE(development->prerelease);
}

TEST(UpdaterVersionTest, RejectsMalformedVersions) {
  EXPECT_FALSE(updater::parse_version("1.2"));
  EXPECT_FALSE(updater::parse_version("1.two.3"));
  EXPECT_FALSE(updater::parse_version("1.2.3/evil"));
  EXPECT_FALSE(updater::parse_version("1.2.3-../../evil"));
  EXPECT_FALSE(updater::parse_version(""));
}

TEST(UpdaterVersionTest, ComparesStableAndPrereleaseVersions) {
  const auto older = updater::parse_version("1.2.3").value();
  const auto newer = updater::parse_version("1.3.0").value();
  const auto prerelease = updater::parse_version("1.3.0-rc.1").value();
  const auto prerelease_two = updater::parse_version("1.3.0-rc.2").value();
  const auto prerelease_ten = updater::parse_version("1.3.0-rc.10").value();
  EXPECT_LT(updater::compare_versions(older, newer), 0);
  EXPECT_LT(updater::compare_versions(prerelease, newer), 0);
  EXPECT_LT(updater::compare_versions(prerelease_two, prerelease_ten), 0);
  EXPECT_EQ(updater::compare_versions(newer, newer), 0);
}

TEST(UpdaterSignatureTest, VerifiesOnlyTheExactSignedBytes) {
  crypto::pkey_ctx_t key_context {EVP_PKEY_CTX_new_id(EVP_PKEY_ED25519, nullptr)};
  ASSERT_TRUE(key_context);
  ASSERT_EQ(EVP_PKEY_keygen_init(key_context.get()), 1);
  crypto::pkey_t key;
  ASSERT_EQ(EVP_PKEY_keygen(key_context.get(), &key), 1);

  crypto::bio_t public_key_bio {BIO_new(BIO_s_mem())};
  ASSERT_TRUE(public_key_bio);
  ASSERT_EQ(PEM_write_bio_PUBKEY(public_key_bio.get(), key.get()), 1);
  BUF_MEM *public_key_buffer = nullptr;
  BIO_get_mem_ptr(public_key_bio.get(), &public_key_buffer);
  const std::string public_key(public_key_buffer->data, public_key_buffer->length);

  constexpr std::string_view manifest = R"({"schema":1,"version":"1.2.3"})";
  crypto::md_ctx_t sign_context {EVP_MD_CTX_new()};
  ASSERT_TRUE(sign_context);
  ASSERT_EQ(EVP_DigestSignInit(sign_context.get(), nullptr, nullptr, nullptr, key.get()), 1);
  std::size_t signature_size = 0;
  ASSERT_EQ(EVP_DigestSign(sign_context.get(), nullptr, &signature_size, reinterpret_cast<const unsigned char *>(manifest.data()), manifest.size()), 1);
  std::string signature(signature_size, '\0');
  ASSERT_EQ(EVP_DigestSign(sign_context.get(), reinterpret_cast<unsigned char *>(signature.data()), &signature_size, reinterpret_cast<const unsigned char *>(manifest.data()), manifest.size()), 1);
  signature.resize(signature_size);

  EXPECT_TRUE(updater::verify_ed25519(public_key, manifest, signature));
  EXPECT_FALSE(updater::verify_ed25519(public_key, std::string(manifest) + " ", signature));
  signature[0] ^= 1;
  EXPECT_FALSE(updater::verify_ed25519(public_key, manifest, signature));
}
