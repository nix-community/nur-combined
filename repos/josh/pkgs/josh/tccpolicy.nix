{
  lib,
  swiftPackages,
  fetchFromGitHub,
  sqlite,
  swift,
  swiftpm,
  runCommand,
  testers,
  writeText,
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
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "josh";
    repo = "tccpolicy";
    tag = "v${finalAttrs.version}";
    hash = "sha256-HPTQ+ebGNvfaMKtn8gqXrxG+PDAqmpdWWhmRIyaSXhU=";
  };

  nativeBuildInputs = [
    swift
    swiftpm
  ];

  buildInputs = [
    sqlite
  ];

  postPatch = ''
    grep -rlF "import SQLite3" Sources | while IFS= read -r f; do
      substituteInPlace "$f" --replace-fail "import SQLite3" "import CSQLite"
    done
    grep -rqF "import CSQLite" Sources
    status=0
    grep -rqF "import SQLite3" Sources || status=$?
    test "$status" -eq 1
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

  passthru.tests = {
    version = testers.testVersion {
      package = finalAttrs.finalPackage;
      inherit (finalAttrs) version;
    };

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
