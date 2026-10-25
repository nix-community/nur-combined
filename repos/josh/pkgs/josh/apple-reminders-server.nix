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
  version = "0-unstable-2026-10-25";

  src = fetchFromGitHub {
    owner = "josh";
    repo = "apple-reminders-server";
    rev = "49d056ab2b2b006d201d60583b6898c7bd5b9a43";
    hash = "sha256-j/U6RCpsM4c6iBlsltFZwMc99yY+EyuOJi7wte/uIhE=";
  };

  nativeBuildInputs = [
    swift
    swiftpm
  ];

  swiftpmDeps = swiftPackages.fetchSwiftPMDeps {
    inherit (finalAttrs) pname version src;
    hash = "sha256-nb7aGusmip481lEbgAmapJll+P+BHrDkxPT+atmq44I=";
  };

  installPhase = ''
    runHook preInstall
    install -Dm755 .build/release/apple-reminders-server $out/bin/apple-reminders-server
    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  passthru.tests = {
    help =
      runCommand "test-apple-reminders-server-help" { nativeBuildInputs = [ finalAttrs.finalPackage ]; }
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
