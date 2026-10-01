{
  # keep-sorted start
  cacert,
  fetchFromGitHub,
  git,
  lib,
  openssl,
  pkg-config,
  rustPlatform,
  # keep-sorted end
}:
rustPlatform.buildRustPackage rec {
  pname = "cargo-bp";
  version = "0.6.1";

  src = fetchFromGitHub {
    owner = "battery-pack-rs";
    repo = "battery-pack";
    rev = "cargo-bp-v${version}";
    hash = "sha256-9hfr0wF5m3rME0gHlZ50OHZzUPseS1rJsbGAwIRNcE8=";
  };

  cargoHash = "sha256-SxUKCYMqQLY3qWKoRLKfOV4qzfjUb9nD2y03Zmnn3nA=";
  cargoBuildFlags = ["-p" pname];
  # One test fetches crates.io, and the other has a stale upstream snapshot.
  cargoTestFlags = ["-p" pname "--" "--skip" "add_template_registry_download_keeps_tempdir_alive" "--skip" "with_template_two_level_generation"];

  nativeBuildInputs = [git pkg-config];
  buildInputs = [openssl];
  SSL_CERT_FILE = "${cacert}/etc/ssl/certs/ca-bundle.crt";

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck
    $out/bin/cargo-bp bp --help > /dev/null
    runHook postInstallCheck
  '';

  meta = with lib; {
    # keep-sorted start
    description = "CLI for creating and managing battery packs";
    homepage = "https://github.com/battery-pack-rs/battery-pack";
    license = licenses.mit;
    mainProgram = "cargo-bp";
    # keep-sorted end
  };
}
