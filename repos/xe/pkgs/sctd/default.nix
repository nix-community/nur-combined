{ stdenv, fetchFromGitHub, rustPlatform, pkg-config, libX11, libXrandr }:

rustPlatform.buildRustPackage rec {
  pname = "sctd";
  src = fetchFromGitHub (builtins.fromJSON (builtins.readFile ./source.json));

  buildInputs = [
    pkg-config
    libX11
    libXrandr
  ];

  version = "0.1.2";
  cargoSha256 = "00bbia9hdk60fpm4i71s5x419z0hfrjwlvys747mn58nnqwzr12h";
  verifyCargoDeps = true;
  meta = with stdenv.lib; {
    description = "set color temperature daemon ";
    homepage = "https://github.com/amir/${pname}";
    maintainers = with maintainers; [ xe ];
  };
}
