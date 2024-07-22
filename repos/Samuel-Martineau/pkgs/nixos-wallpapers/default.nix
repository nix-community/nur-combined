{ stdenvNoCC, fetchFromGitHub }:

stdenvNoCC.mkDerivation {
  name = "nixos-wallpapers";

  src = fetchFromGitHub {
    owner = "NixOS";
    repo = "nixos-artwork";
    rev = "de03e887f03037e7e781a678b57fdae603c9ca20";
    hash = "sha256-78FyNyGtDZogJUWcCT6A/T2MK87nGN/muC7ANH1b1V8=";
  };

  installPhase = ''
    rm -r wallpapers/source
    cp -r wallpapers $out
  '';

  phases = [
    "unpackPhase"
    "installPhase"
  ];
}
