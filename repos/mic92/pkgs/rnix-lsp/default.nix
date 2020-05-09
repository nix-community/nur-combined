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

  cargoSha256 = "1akshs4xsbmma90c57cfi0b2ma50x8gzvj08h9gsixr0zi46g0hn";

  meta = with lib; {
    description = "A work-in-progress language server for Nix, with syntax checking and basic completion";
    license = licenses.mit;
  };
}
