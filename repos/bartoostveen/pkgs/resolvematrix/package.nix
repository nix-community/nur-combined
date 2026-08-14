{
  lib,
  rustPlatform,
  fetchFromForgejo,
  pkg-config,
  cacert,
}:

rustPlatform.buildRustPackage (_finalAttrs: {
  pname = "resolvematrix";
  version = "1.3.0-unstable-2026-08-01";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromForgejo {
    domain = "forgejo.ellis.link";
    owner = "continuwuation";
    repo = "resolvematrix";
    rev = "8e4c4da55766f9cf86f6657041d71a8ffe688fea";
    hash = "sha256-EFAhML11o7dKEPnPgcLVfeOM9FLCIBFixtzoE7a+16o=";
  };

  cargoHash = "sha256-xjn/bHjsLEZ+3vbgCCWyxJiNzR1NerDFCGr8WgwzvFc=";

  nativeBuildInputs = [
    pkg-config
  ];

  nativeCheckInputs = [
    cacert
  ];

  cargoBuildFlags = [
    "-p"
    "resolvematrix-cli"
  ];

  checkFlags = [
    # These all require a working DNS resolver
    "--skip=resolution::tests::test_resolution"
    "--skip=server::tests::test_builder"
    "--skip=server::tests::test_cache_hits"
    "--skip=server::tests::test_client_reuse"
    "--skip=server::tests::test_explicit_port_resolution::case_1_standard_port"
    "--skip=server::tests::test_explicit_port_resolution::case_2_high_port"
    "--skip=server::tests::test_invalid_well_known"
    "--skip=server::tests::test_ip_literal_resolution::case_1_ipv4_default"
    "--skip=server::tests::test_ip_literal_resolution::case_2_ipv4_custom_port"
    "--skip=server::tests::test_ip_literal_resolution::case_3_ipv6_default"
    "--skip=server::tests::test_ip_literal_resolution::case_4_ipv6_custom_port"
    "--skip=server::tests::test_resolvematrix_suite::case_1_resolvematrix_2"
    "--skip=server::tests::test_resolvematrix_suite::case_2_resolvematrix_3b"
    "--skip=server::tests::test_resolvematrix_suite::case_3_resolvematrix_3c"
    "--skip=server::tests::test_resolvematrix_suite::case_4_resolvematrix_3d"
    "--skip=server::tests::test_resolvematrix_suite::case_5_resolvematrix_4"
    "--skip=server::tests::test_resolvematrix_suite::case_6_resolvematrix_5"
    "--skip=server::tests::test_resolvematrix_suite::case_7_resolvematrix_3c_msc4040"
    "--skip=server::tests::test_resolvematrix_suite::case_8_resolvematrix_4_msc4040"
    "--skip=server::tests::test_server_resolver::case_01_maunium_net"
    "--skip=server::tests::test_well_known_resolution::case_1_maunium"
  ];

  # passthru.updateScript = nix-update-script { };

  meta = {
    description = "A handy Matrix server resolution library and CLI";
    homepage = "https://forgejo.ellis.link/continuwuation/resolvematrix";
    license = lib.licenses.mpl20;
    maintainers = with lib.maintainers; [ bartoostveen ];
    mainProgram = "resolvematrix";
  };
})
