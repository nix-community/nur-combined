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
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "josh";
    repo = "apple-reminders-server";
    tag = "v${finalAttrs.version}";
    hash = "sha256-RY6xmqhfWLh9nAlfVx4TH0VmJJ0mEtHnTN2QAnqTxO8=";
  };

  nativeBuildInputs = [
    swift
    swiftpm
  ];

  swiftpmDeps = swiftPackages.fetchSwiftPMDeps {
    inherit (finalAttrs) pname version src;
    hash = "sha256-Z4JWyDk6VwRW/sCVOc15SRdNQSymBfB1TbPlDKqMaVE=";
  };

  installPhase = ''
    runHook preInstall
    install -Dm755 .build/release/apple-reminders-server $out/bin/apple-reminders-server
    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=stable" ]; };

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
