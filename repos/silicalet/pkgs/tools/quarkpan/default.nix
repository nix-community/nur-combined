{
  lib,
  cmake,
  fetchFromGitHub,
  nix-update-script,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "quarkpan";
  version = "0-unstable-2026-03-18";

  src = fetchFromGitHub {
    owner = "niuhuan";
    repo = "quarkpan-rs";
    rev = "41b26b0cd8a03696c4c22bf2c006ad981b6f5d44";
    hash = "sha256-5klxON+3CZMYjOBPrG9/Uo82LRB4Mxyo58RAhXq4/Z8=";
  };

  cargoLock.lockFile = "${finalAttrs.src}/Cargo.lock";

  # The default rustls backend uses aws-lc-sys.
  nativeBuildInputs = [ cmake ];

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck
    "$out/bin/quarkpan" --help > /dev/null
    runHook postInstallCheck
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--version=branch" ];
  };

  meta = {
    description = "Command-line client for Quark Drive";
    homepage = "https://github.com/niuhuan/quarkpan-rs";
    license = lib.licenses.gpl3Only;
    mainProgram = "quarkpan";
    platforms = lib.platforms.unix;
  };
})
