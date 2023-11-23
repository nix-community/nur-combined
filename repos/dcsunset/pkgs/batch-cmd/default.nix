{ lib, buildNpmPackage, fetchFromGitHub, pandoc }:

buildNpmPackage rec {
  pname = "batch-cmd";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "DCsunset";
    repo = "batch-cmd";
    rev = "v${version}";
    hash = "sha256-/IR5fuROwCe23Yv8Mp2mpALYR04u4/u2AsHoGPSEYdQ=";
  };

  # run prefetch-npm-deps package-lock.json to generate the hash
  npmDepsHash = "sha256-/AWYEuHV6XzCiHH1Fd2wXJ1vlLd+fzzxBbxSq9Hj69I=";

  nativeBuildInputs = [ pandoc ];

  meta = with lib; {
    description = "Executing multiple commands in batches concurrently.";
    homepage = "https://github.com/DCsunset/batch-cmd";
    license = licenses.agpl3;
  };
}
