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
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "josh";
    repo = "launchd-activate";
    tag = "v${finalAttrs.version}";
    hash = "sha256-UgWS+DEw3s4bJm8wcetwQhHLTM1ossPHUbuNXSDOEZU=";
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

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=stable" ]; };

  passthru.tests = {
    version = testers.testVersion {
      package = finalAttrs.finalPackage;
      inherit (finalAttrs) version;
    };

    help =
      runCommand "test-launchd-activate-help" { nativeBuildInputs = [ finalAttrs.finalPackage ]; }
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
