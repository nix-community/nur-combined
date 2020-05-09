{ callPackage, lib, fetchFromGitHub, rustPlatform }:

rustPlatform.buildRustPackage rec {
  pname = "rnix-lsp-unstable";
  version = "2020-05-09";

  src = fetchFromGitHub {
    owner = "nix-community";
    repo = "rnix-lsp";
    rev = "a8e0b96b2c4d58b0157e3a770777f9d0b17fda20";
    sha256 = "0jb58df4r91dklgsa2zj2fdgjwzjrhbd7xp8mz3gv2rx1y53ilja";
  };

  cargoSha256 = "1gzw8377s2vacgfvj7421wfha82m5cyhms2q8k0b2s4z8066cf1y";

  meta = with lib; {
    description = "A work-in-progress language server for Nix, with syntax checking and basic completion";
    license = licenses.mit;
  };
}
