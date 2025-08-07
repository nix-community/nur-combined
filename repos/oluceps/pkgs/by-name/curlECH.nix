{
  curl,
  openssl,
  lib,
  brotli,
  c-aresMinimal,
  gsasl,
  libkrb5,
  nghttp2,
  ngtcp2,
  zlib,
  zstd,
  libpsl,
  fetchFromGitHub,
  ...
}:

let
  openssl' = openssl.overrideAttrs (old: {
    version = "0.ech-unstable";
    src = fetchFromGitHub {
      owner = "defo-project";
      repo = "openssl";
      rev = "51778be4f767ce29fba8af90b63dde8554450757";
      fetchSubmodules = false;
      hash = "sha256-2uZXXiIYmi236caneLsWJb8+mY6wptZIkFsyaEWyHCg=";
    };
  });
in

curl.overrideAttrs (old: {
  propagatedBuildInputs = [
    openssl'
  ]
  ++ [
    brotli
    c-aresMinimal
    gsasl
    libkrb5
    nghttp2
    ngtcp2
    zlib
    zstd
    libpsl
  ];
  configureFlags = [
    "--enable-versioned-symbols"
    # Build without manual
    "--disable-manual"
    (lib.enableFeature true "ares")
    (lib.enableFeature true "websockets")
    (lib.enableFeature true "ech")
    # --with-ca-fallback is only supported for openssl and gnutls https://github.com/curl/curl/blame/curl-8_0_1/acinclude.m4#L1640
    (lib.withFeature true "ca-fallback")
    (lib.withFeature true "libpsl")
    (lib.withFeature true "ngtcp2")
    (lib.withFeature true "zstd")
    (lib.withFeatureAs true "brotli" (lib.getDev brotli))
    (lib.withFeatureAs true "openssl" (lib.getDev openssl'))
  ]
  ++ [ "--with-gssapi=${lib.getDev libkrb5}" ];
})
