{ stdenv, lib, rustPlatform, fetchFromGitHub, pkgs }:

let version = "0.1.1"; in
rustPlatform.buildRustPackage {
  pname = "xcursorlocate";
  inherit version;
  buildInputs = with pkgs; [ python3 xorg.libxcb ];
  src = fetchFromGitHub (builtins.fromJSON (builtins.readFile ./source.json));
  cargoSha256 = "1kg91cqyqg2dlg63d20p0crir04fxz3g2shi22992bb4rxx37dh2";

  meta = with lib; {
    description = "cursor location indicator for X11";
    homepage = "https://github.com/NerdyPepper/xcursorlocate";
    license = licenses.mit;
  };
}

