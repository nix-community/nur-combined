{ lib, buildNpmPackage, fetchFromGitHub, pandoc }:

buildNpmPackage rec {
  pname = "batch-cmd";
  version = "0.1.4";

  src = fetchFromGitHub {
    owner = "DCsunset";
    repo = "batch-cmd";
    rev = "v${version}";
    hash = "sha256-7hbIH4DTxq5DzhBiI4k7sfsCnqGOJ/fujGy84tOMpx0=";
  };

  # run prefetch-npm-deps package-lock.json to generate the hash
  npmDepsHash = "sha256-LZK5+2pfpCYn8D+5yU4CDQk1cYfoSKf+UU47NFWTRHU=";

  nativeBuildInputs = [ pandoc ];

  meta = with lib; {
    description = "Executing multiple commands in batches concurrently.";
    homepage = "https://github.com/DCsunset/batch-cmd";
    license = licenses.agpl3;
  };
}
