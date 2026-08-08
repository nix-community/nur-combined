{
  # keep-sorted start
  cacert,
  fetchFromGitHub,
  lib,
  rustPlatform,
  rustc,
  # keep-sorted end
}:
rustPlatform.buildRustPackage {
  pname = "smelt-git";
  version = "0.5.0-alpha.9-unstable-2026-08-07";

  src = fetchFromGitHub {
    owner = "leonardcser";
    repo = "smelt";
    rev = "929164abc70494e22894a83465c79c978b54e0c0";
    hash = "sha256-dptpG/eSYoCzUEVUCENsOU6bBmaA01kW7abwAhEFt3Y=";
  };

  cargoHash = "sha256-MTVQoZduiOCjiCJkOnSRvSAVtPVw6gxX0ZFXW9NdKmg=";

  nativeCheckInputs = [cacert];
  SSL_CERT_FILE = "${cacert}/etc/ssl/certs/ca-bundle.crt";

  doInstallCheck = true;
  installCheckPhase = ''
    export HOME="$TMPDIR"
    $out/bin/smelt --version
  '';

  meta = {
    # keep-sorted start
    broken = lib.versionOlder rustc.version "1.92";
    description = "Small, fast, and Lua-scriptable coding agent (development version)";
    homepage = "https://github.com/leonardcser/smelt";
    license = lib.licenses.mit;
    mainProgram = "smelt";
    platforms = lib.platforms.unix;
    # keep-sorted end
  };
}
