{
  lib,
  rustPlatform,
  fetchFromForgejo,
  pkg-config,
  cacert,
  nix-update-script,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "resolvematrix";
  version = "1.4.0";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromForgejo {
    domain = "forgejo.ellis.link";
    owner = "continuwuation";
    repo = "resolvematrix";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Q/qDz50RdwvMBb0tn5sXpeYLNTjGFiQtV1WoDj7n5GI=";
  };

  cargoHash = "sha256-+yvcoVBynJmDcgQCQiCkj9Y1Us0OWvfoMFEdi60tLLs=";

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

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "A handy Matrix server resolution library and CLI";
    homepage = "https://forgejo.ellis.link/continuwuation/resolvematrix";
    license = lib.licenses.mpl20;
    maintainers = with lib.maintainers; [ bartoostveen ];
    mainProgram = "resolvematrix";
  };
})
