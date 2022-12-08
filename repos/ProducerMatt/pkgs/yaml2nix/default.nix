{ lib, fetchFromGitHub, rustPlatform }:

rustPlatform.buildRustPackage rec {
  pname = "yaml2nix";
  version = "2021-08-21";

  src = fetchFromGitHub {
    owner = "euank";
    repo = "yaml2nix";
    rev = "b220acf";
    sha256 = "KAWBoLjfk9jNVZ5tSODEq6r9A4I6eUlNwJPhCxkK+sQ=";
  };

  cargoSha256 = "FZ9GlNyFX+15sza9sTbHqLvkVpu1oBYzo0ydCptyZyc=";

  meta = with lib; {
    description = "A command-line tool to convert yaml into a nix expression";
    homepage = "https://github.com/euank/yaml2nix";
    license = licenses.gpl3;
    maintainers = with maintainers; [ ProducerMatt ];
  };
}
