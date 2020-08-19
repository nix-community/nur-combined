{ stdenv, lib, rustPlatform, fetchFromGitHub, pkgconfig, openssl }:

let version = "0.1.4"; in
rustPlatform.buildRustPackage {
  pname = "pista";
  inherit version;
  buildInputs = [ openssl pkgconfig ];
  src = fetchFromGitHub (builtins.fromJSON (builtins.readFile ./source.json));
  cargoSha256 = "13qf4ahzah5gqcpvdvnw87aya9qvvkg2bharhgxddk2bzsf4j66s";

  meta = with lib; {
    description = "a simple {bash, zsh} prompt for programmers";
    homepage = "https://github.com/NerdyPepper/pista";
    license = licenses.mit;
  };
}

