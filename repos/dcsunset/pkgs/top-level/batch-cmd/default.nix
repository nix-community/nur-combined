{ lib, buildNpmPackage, fetchFromGitHub, pandoc }:

buildNpmPackage rec {
  pname = "batch-cmd";
  version = "0.2.1";

  src = fetchFromGitHub {
    owner = "DCsunset";
    repo = "batch-cmd";
    rev = "v${version}";
    hash = "sha256-L10gvTuVo3aVjkW04njtaYug9NiI00EXRbHPdRJOvQY=";
  };

  # run prefetch-npm-deps package-lock.json to generate the hash
  npmDepsHash = "sha256-tmzJtcTjEzviIUtn3j8/3bVeTNEpky3tNiuAzmnkJzA=";

  nativeBuildInputs = [ pandoc ];

  meta = with lib; {
    description = "Executing multiple commands in batches concurrently.";
    homepage = "https://github.com/DCsunset/batch-cmd";
    license = licenses.agpl3;
  };
}
