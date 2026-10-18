{
  lib,
  swiftPackages,
  fetchFromGitHub,
  swift,
  swiftpm,
  nix-update-script,
  runCommand,
}:
swiftPackages.stdenv.mkDerivation (finalAttrs: {
  pname = "macos-reminders-server";
  version = "0-unstable-2026-10-18";

  src = fetchFromGitHub {
    owner = "josh";
    repo = "macos-reminders-server";
    rev = "de17445c9d96b71b4daa7fd2d3e2fd4bc099cfa7";
    hash = "sha256-NAENGurEtSmQ3BdIgj5HF8EWFexjP5ioBca9u6EQ3as=";
  };

  nativeBuildInputs = [
    swift
    swiftpm
  ];

  swiftpmDeps = swiftPackages.fetchSwiftPMDeps {
    inherit (finalAttrs) pname version src;
    hash = "sha256-PdkfCMkWNGqMj2zqhbvydWO97FjKTsPlhtBfyRBTg18=";
  };

  installPhase = ''
    runHook preInstall
    install -Dm755 .build/release/reminders-swift $out/bin/reminders-swift
    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  passthru.tests = {
    help =
      runCommand "test-macos-reminders-server-help"
        {
          __structuredAttrs = true;
          nativeBuildInputs = [ finalAttrs.finalPackage ];
        }
        ''
          reminders-swift --help
          touch $out
        '';
  };

  meta = {
    description = "macOS Reminders server with GraphQL, MCP, and metrics";
    homepage = "https://github.com/josh/macos-reminders-server";
    license = lib.licenses.mit;
    mainProgram = "reminders-swift";
    platforms = lib.platforms.darwin;
    broken = lib.strings.versionOlder swift.version "6.2";
  };
})
