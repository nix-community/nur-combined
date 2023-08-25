{ lib, buildNpmPackage, fetchFromGitHub, pandoc }:

buildNpmPackage rec {
  pname = "batch-cmd";
  version = "0.1.2";

  src = fetchFromGitHub {
    owner = "DCsunset";
    repo = "batch-cmd";
    rev = "v${version}";
    hash = "sha256-6RUlnXQtxlBTnn2Ept1qJj7KdOpDlX2ZOEdHXuvfLnU=";
  };

  # run prefetch-npm-deps package-lock.json to generate the hash
  npmDepsHash = "sha256-HTngCf8CvyMR/6WoiD/L7Y7kU2FZG02QbAxyjRipHYQ=";

  nativeBuildInputs = [ pandoc ];

  meta = with lib; {
    description = "Executing multiple commands in batches concurrently.";
    homepage = "https://github.com/DCsunset/batch-cmd";
    license = licenses.agpl3;
  };
}
