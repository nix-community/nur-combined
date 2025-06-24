{
  lib,
  fetchFromGitHub,
  runCommand,
  swiftPackages,
  swift,
  swiftpm,
  coreutils,
  nix-update-script,
  testers,
}:
swiftPackages.stdenv.mkDerivation (finalAttrs: {
  pname = "launchd-activate";
  version = "0-unstable-2025-05-31";

  src = fetchFromGitHub {
    owner = "josh";
    repo = "launchd-activate";
    rev = "8f495c14ae835d3676a33b9bd152d6849c0f9ddd";
    hash = "sha256-l8iOgeaPC3rqmprDdOsEskiB6waNA2DGUyGBmYSpoZ4=";
  };

  nativeBuildInputs = [
    swift
    swiftpm
  ];

  buildInputs = [
    coreutils
  ];

  configurePhase = ''
    runHook preConfigure

    rm Sources/launchd-activate/Constants.swift

    cat >Sources/launchd-activate/Constants.swift <<EOF
    let VERSION = "$version"
    let CP_PATH = "$(command -v cp || echo "/bin/cp")"
    let LN_PATH = "$(command -v ln || echo "/bin/ln")"
    let RM_PATH = "$(command -v rm || echo "/bin/rm")"
    let SUDO_PATH = "$(command -v sudo || echo "/usr/bin/sudo")"
    let LAUNCHCTL_PATH = "$(command -v launchctl || echo "/bin/launchctl")"
    EOF

    runHook postConfigure
  '';

  installPhase = ''
    runHook preInstall
    install -Dm755 .build/release/launchd-activate $out/bin/launchd-activate
    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  passthru.tests = {
    version = testers.testVersion {
      package = finalAttrs.finalPackage;
      inherit (finalAttrs) version;
    };

    help =
      runCommand "test-launchd-activate-help"
        {
          __structuredAttrs = true;
          nativeBuildInputs = [ finalAttrs.finalPackage ];
        }
        ''
          launchd-activate --help
          touch $out
        '';
  };

  meta = {
    description = "Declaratively load and unload launchd agents";
    homepage = "https://github.com/josh/launchd-activate";
    license = lib.licenses.mit;
    platforms = lib.platforms.darwin;
    mainProgram = "launchd-activate";
  };
})
