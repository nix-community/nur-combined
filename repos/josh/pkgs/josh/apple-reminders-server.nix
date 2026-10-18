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
  pname = "apple-reminders-server";
  version = "0-unstable-2026-10-18";

  src = fetchFromGitHub {
    owner = "josh";
    repo = "apple-reminders-server";
    rev = "6954a8eccfb6346803b2cc5bce6b3b30d53ed8fb";
    hash = "sha256-KtGsGhShwtB0/mxaNiPQ4Do7vLeApX9DtXL80HwNsEk=";
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
    install -Dm755 .build/release/apple-reminders-server $out/bin/apple-reminders-server
    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  passthru.tests = {
    help =
      runCommand "test-apple-reminders-server-help"
        {
          __structuredAttrs = true;
          nativeBuildInputs = [ finalAttrs.finalPackage ];
        }
        ''
          apple-reminders-server --help
          touch $out
        '';
  };

  meta = {
    description = "Apple Reminders server with GraphQL, MCP, and metrics";
    homepage = "https://github.com/josh/apple-reminders-server";
    license = lib.licenses.mit;
    mainProgram = "apple-reminders-server";
    platforms = lib.platforms.darwin;
    broken = lib.strings.versionOlder swift.version "6.2";
  };
})
