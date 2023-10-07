{ lib, buildNpmPackage, fetchFromGitHub, pandoc }:

buildNpmPackage rec {
  pname = "batch-cmd";
  version = "0.1.5";

  src = fetchFromGitHub {
    owner = "DCsunset";
    repo = "batch-cmd";
    rev = "v${version}";
    hash = "sha256-mtmPnR8nZDrUW57w3ia+hxR3X+9esgt0Z0d0u1vpiqc=";
  };

  # run prefetch-npm-deps package-lock.json to generate the hash
  npmDepsHash = "sha256-TrBO7/+p3n/nfJJn8DOupaQ2FgkYRF4RCuxNZLw1Kic=";

  nativeBuildInputs = [ pandoc ];

  meta = with lib; {
    description = "Executing multiple commands in batches concurrently.";
    homepage = "https://github.com/DCsunset/batch-cmd";
    license = licenses.agpl3;
  };
}
