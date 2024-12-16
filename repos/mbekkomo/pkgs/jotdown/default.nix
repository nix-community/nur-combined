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

  cargoHash = "sha256-gsrwC7X1pnr9ZQDqq0SnNxYHFdRI9VRuIQtA1s7Yz7A=";

  meta = {
    description = "A parser for the Djot markup language";
    homepage = "https://github.com/hellux/jotdown#readme";
    license = lib.licenses.mit;
    maintainers = [];
  };
}
