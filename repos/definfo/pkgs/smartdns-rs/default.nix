{
  lib,
  rustPlatform,
  fetchFromGitHub,
  stdenv,
  darwin,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "smartdns-rs";
  version = "0.11.0";

  src = fetchFromGitHub {
    owner = "mokeyish";
    repo = "smartdns-rs";
    tag = "v${finalAttrs.version}";
    hash = "sha256-A/h2vPBbC4EzqLjWjQM0eiYXQZHEkJZW20/NbHkXNi0=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-Tgm+c0JPhF93TI9k7jrRjxPUjxpJgED3RtBbK9yDtwQ=";

  nativeBuildInputs = [
    rustPlatform.bindgenHook
  ];

  buildInputs = lib.optionals stdenv.isDarwin (
    with darwin.apple_sdk.frameworks;
    [
      IOKit
      Security
    ]
  );

  checkFlags = [
    # need network
    "--skip=dns_client::tests::test_nameserver_alidns_resolve"
    "--skip=dns_client::tests::test_nameserver_cloudflare_resolve"
    "--skip=dns_client::tests::test_nameserver_h3_resolve"
    "--skip=dns_client::tests::test_nameserver_https_resolve"
    "--skip=dns_client::tests::test_nameserver_quic_over_proxy_resolve"
    "--skip=dns_client::tests::test_nameserver_quic_resolve"
    "--skip=dns_client::tests::test_nameserver_tls_resolve"
    "--skip=dns_client::tests::test_with_default"
    "--skip=dns_mw_cache::tests::test_lookup_serde"
    "--skip=dns_mw_ns::tests::test_edns_client_subnet"
    "--skip=infra::os_release::tests::is_target_os"
    "--skip=infra::ping::tests::test_ping_fatest"
    "--skip=infra::ping::tests::test_ping_https"
    "--skip=infra::ping::tests::test_ping_simple"
  ];

  meta = {
    description = "Cross platform local DNS server (Dnsmasq like) written in rust";
    homepage = "https://github.com/mokeyish/smartdns-rs";
    mainProgram = "smartdns";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.all;
  };
})
