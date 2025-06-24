{
  lib,
  writeText,
  fetchFromGitHub,
  runCommand,
  swiftPackages,
  swift,
  swiftpm,
  sqlite,
  nix-update-script,
}:
let
  sqliteModuleMap = writeText "CSQLite.modulemap" ''
    module CSQLite [system] {
      header "${sqlite.dev}/include/sqlite3.h"
      link "sqlite3"
      export *
    }
  '';
in
swiftPackages.stdenv.mkDerivation (finalAttrs: {
  pname = "tccpolicy";
  version = "0.1.0-unstable-2025-05-14";

  src = fetchFromGitHub {
    owner = "josh";
    repo = "tccpolicy";
    rev = "0e5b63be1501391d8db755d5ce28240fc322ded3";
    hash = "sha256-N6qeHgw+QHV7rVvdiafGVP3uhKJHZE9FbeUhMfdrsHE=";
  };

  nativeBuildInputs = [
    swift
    swiftpm
  ];

  buildInputs = [
    sqlite
  ];

  postPatch = ''
    substituteInPlace Sources/**/*.swift \
      --replace-quiet "import SQLite3" "import CSQLite"
  '';

  swiftpmFlags = [
    "-Xcc"
    "-fmodule-map-file=${sqliteModuleMap}"
  ];

  installPhase = ''
    runHook preInstall
    install -Dm755 .build/release/tccpolicy $out/bin/tccpolicy
    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  passthru.tests = {
    help =
      runCommand "test-tccpolicy-help"
        {
          __structuredAttrs = true;
          nativeBuildInputs = [ finalAttrs.finalPackage ];
        }
        ''
          tccpolicy --help
          touch $out
        '';
  };

  meta = {
    description = "Manage macOS TCC database declaratively";
    homepage = "https://github.com/josh/tccpolicy";
    license = lib.licenses.mit;
    platforms = lib.platforms.darwin;
    mainProgram = "tccpolicy";
  };
})
