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
  cargoSha256 = "1dxqzkv7y7h09drqcj2b0ds3bgkhgcc058r1fprhs76ic9h1z92q";
  verifyCargoDeps = true;
  meta = with stdenv.lib; {
    description = "set color temperature daemon ";
    homepage = "https://github.com/amir/${pname}";
    maintainers = with maintainers; [ xe ];
  };
}
