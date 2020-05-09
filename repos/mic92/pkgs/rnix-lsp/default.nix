{ callPackage, lib, fetchFromGitHub, rustPlatform }:

rustPlatform.buildRustPackage rec {
  pname = "rnix-lsp-unstable";
  version = "2020-05-09";

  src = fetchFromGitHub {
    owner = "Mic92";
    repo = "rnix-lsp";
    rev = "7fdde77ecbb3b32db18168692830dc4f10f2239c";
    sha256 = "0jb58df4r91dklgsa2zj2fdgjwzjrhbd7xp8mz3gv2rx1y53ilja";
  };

  cargoSha256 = "1gzw8377s2vacgfvj7421wfha82m5cyhms2q8k0b2s4z8066cf1y";

  meta = with lib; {
    description = "A work-in-progress language server for Nix, with syntax checking and basic completion";
    license = licenses.mit;
  };
}
