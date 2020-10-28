{ stdenv, fetchFromGitHub, rustPlatform, pkg-config, libX11, libXrandr }:

rustPlatform.buildRustPackage rec {
  pname = "steno-lookup";
  src = fetchFromGitHub (builtins.fromJSON (builtins.readFile ./source.json));

  version = "0.1.0";
  cargoSha256 = "1907mnxxxpwp691hskjkixrz5a8x1dqh4b4gq4p13xxhqq07hhr3";
  verifyCargoDeps = true;
  legacyCargoFetcher = true;
  meta = with stdenv.lib; {
    maintainers = with maintainers; [ xe ];
  };
}
