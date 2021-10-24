{ lib, fetchFromGitHub, crystal }:

crystal.buildCrystalPackage rec {
  pname = "crelease";
  version = "1.0.0";

  ## LEARNING
  # nix-prefetch-github elorest crelease --rev v1.0.0
  # nix-shell -p nix-prefetch-github --command "nix-prefetch-github elorest crelease --rev v1.0.0"
  src = fetchFromGitHub {
    owner = "mipmip";
    repo = "crelease";
    rev = "0027765b2c25469c9bb5768abf1f8d50ee2fbb7e"; #master
    sha256 = "0pld5pvz3y5i536k6r226zr8rbp54mawsbjq1lq2nm9k2dk748gw";
  };

  doCheck = false;

  meta = with lib; {
    description = "Application to simpify versioning and releasing crystal projects.";
    homepage = "https://github.com/elorest/crelease";
    license = licenses.mit;
  };
}

