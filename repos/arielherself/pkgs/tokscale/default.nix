{ lib
, rustPlatform
, fetchFromGitHub
, pkg-config
, openssl
, versionCheckHook
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "tokscale";
  version = "4.20.0";

  src = fetchFromGitHub {
    owner = "junhoyeo";
    repo = "tokscale";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Gm1Y2SvsoYVw3PDazuMJxF0Ff5C+r2VgqLVksD0QR5U=";
  };

  cargoHash = "sha256-HgjabmTqUQQ2Nq7ngpa6opdRi5XGZVDpLRIFCNWjI38=";

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ openssl ];

  # Upstream vendors OpenSSL on Linux (native-tls-vendored) for its zigbuild
  # release artifacts; link nixpkgs' instead.
  env.OPENSSL_NO_VENDOR = true;

  # Leave out fake_codex, a stand-in `codex` the tests run.
  cargoBuildFlags = [ "--bin" "tokscale" ];

  # These run the CLI under TZ=America/Los_Angeles and the like. chrono::Local
  # resolves a zone name only under fixed paths such as /usr/share/zoneinfo and
  # /etc/zoneinfo, ignoring TZDIR, and the sandbox has none of them, so every
  # zone reads as UTC.
  checkFlags = [
    "--skip=test_auto_pinning_never_overwrites_a_settings_file_it_could_not_read"
    "--skip=test_auto_pinning_recovers_from_a_bucket_timezone_that_names_no_zone"
    "--skip=test_first_run_pins_the_host_timezone_without_changing_its_own_output"
    "--skip=test_graph_single_day_filter_uses_local_timezone_boundaries"
    "--skip=test_submit_dry_run_preserves_local_date_ahead_of_utc"
    "--skip=test_unpinned_first_scan_still_buckets_by_the_host_timezone"
  ];

  nativeInstallCheckInputs = [ versionCheckHook ];
  doInstallCheck = true;

  meta = {
    description = "Track token usage across AI coding agents from your terminal";
    homepage = "https://tokscale.ai";
    downloadPage = "https://github.com/junhoyeo/tokscale";
    changelog = "https://github.com/junhoyeo/tokscale/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    sourceProvenance = [ lib.sourceTypes.fromSource ];
    maintainers = [
      {
        name = "arielherself";
        github = "arielherself";
        githubId = 107245128;
      }
    ];
    mainProgram = "tokscale";
  };
})
