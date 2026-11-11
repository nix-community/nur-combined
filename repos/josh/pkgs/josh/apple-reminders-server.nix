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
  version = "0-unstable-2026-11-11";

  src = fetchFromGitHub {
    owner = "josh";
    repo = "apple-reminders-server";
    rev = "b4e8396bbf0c8a27fe95e3f951d74f5c112f3db2";
    hash = "sha256-UFThEZQFAuBrNIWsxJ1ha6UtiN3NL/V9/E9xCTDaGOE=";
  };

  nativeBuildInputs = [
    swift
    swiftpm
  ];

  swiftpmDeps = swiftPackages.fetchSwiftPMDeps {
    inherit (finalAttrs) pname version src;
    hash = "sha256-7ArtmVgB4TKqjOKimicILK7tFBwn+9ob1+SZIJ7oQX4=";
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
