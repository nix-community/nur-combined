{ lib, buildNpmPackage, fetchFromGitHub, }:

buildNpmPackage rec {
  pname = "solidity-metrics";
  version = "0.0.27";

  src = fetchFromGitHub {
    owner = "Consensys";
    repo = "solidity-metrics";
    rev = "127c57cb9ee23c02423daadef8b5c77836a14ff7";
    hash = "sha256-Ms0rNY0NYIsnKNHXUzZ12eIuo46bmXswhRmtYCHAMP8=";
  };

  dontNpmBuild = true;

  npmDepsHash = "sha256-I4JoRuCfoBD9fmgWNaO8B84ZwVF5qM3VnzqmzpX+C0Q=";

  meta = {
    broken = false;
    description = "Solidity Code Metrics";
    homepage = "https://github.com/Consensys/solidity-metrics";

    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
  };
}
