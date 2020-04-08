{ pkgs ? import <nixpkgs> { } }:

with pkgs;

rustPlatform.buildRustPackage rec {
  name = "cabytcini-${version}";
  version = "0.2.0";

  src = fetchgit {
    url = "https://tulpa.dev/cadey/cabytcini";
    rev = "37a77a67833de76d974277e6fe798c135beb7863";
    sha256 = "0i4x2jl8928ndakwqayhih06g0p1i4l3nsap5v12pw4fnnbs9sqd";
  };

  buildInputs = [ pkg-config xorg.libX11 openssl ];

  cargoSha256 = "1a6f7fsn5bph32gaw204s0kgxn23ycmj4kcahgvhlhclm0fsb455";

  meta = with lib; {
    description = "lo mi cabytcini cankyuijde";
    homepage = "https://tulpa.dev/cadey/cabytcini";
    license = licenses.mit;
    maintainers = [ maintainers.xe ];
  };
}
