{ lib, buildNpmPackage, fetchFromGitHub, pandoc }:

buildNpmPackage rec {
  pname = "batch-cmd";
  version = "0.2.2";

  src = fetchFromGitHub {
    owner = "DCsunset";
    repo = "batch-cmd";
    rev = "v${version}";
    hash = "sha256-i6p95QMJsvrOXO5GFxnbCCpKNj+jG/hhlys0m+grtB8=";
  };

  # run prefetch-npm-deps package-lock.json to generate the hash
  npmDepsHash = "sha256-P6S1SllmZ0Mv6ZI6VrGmyUB83U1K7QnsG8kgxSamcCs=";

  nativeBuildInputs = [ pandoc ];

  meta = with lib; {
    mainProgram = "bcmd";
    description = "Executing multiple commands in batches concurrently.";
    homepage = "https://github.com/DCsunset/batch-cmd";
    license = licenses.agpl3Only;
  };
}
