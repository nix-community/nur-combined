{ lib, fetchFromGitHub, rustPlatform, ... }:
rustPlatform.buildRustPackage rec {
  pname = "jotdown";
  version = "0.7.0";

  src = fetchFromGitHub {
    owner = "hellux";
    repo = pname;
    rev = version;
    hash = "sha256-1s0J6TF/iDSqKUF4/sgq2irSPENjinftPFZnMgE8Dn8=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-SGmlNpauPk2qSIIdP0hfGUplCV9ZvyHhZss8XXuxfHg=";

  meta = {
    description = "A parser for the Djot markup language";
    homepage = "https://github.com/hellux/jotdown#readme";
    license = lib.licenses.mit;
    maintainers = [];
  };
}
