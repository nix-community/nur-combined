{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  pango,
  cairo,
  glib,
  wayland,
}:

let
  rpathLibs = [
    pango
    glib
    cairo
    wayland
  ];
in

rustPlatform.buildRustPackage rec {
  pname = "i3bar-river";
  version = "master";

  src = fetchFromGitHub {
    owner = "MaxVerevkin";
    repo = pname;
    rev = "e195a50d75c394a69a7228f8c1e5ad320c3ad06d";
    sha256 = "sha256-Ckf+TSdOtTOKC8qz7ClxxhqVOc7MEwGy82Oj5GWnyhg=";
  };

  cargoHash = "sha256-N3FXw3z2jpp6MKPGoL4pFIqa2t2H6VtuICMWAJlwaog=";

  nativeBuildInputs = [ pkg-config ];

  buildInputs = rpathLibs;

  postInstall = ''
    # Strip executable and set RPATH
    # Stolen from https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/applications/terminal-emulators/alacritty/default.nix#L107
    strip -s $out/bin/i3bar-river
    patchelf --set-rpath "${lib.makeLibraryPath rpathLibs}" $out/bin/i3bar-river
  '';

  dontPatchELF = true;

  meta = with lib; {
    description = "A port of i3bar for river.";
    homepage = "https://github.com/MaxVerevkin/i3bar-river";
    license = licenses.gpl3Plus;
    maintainers = [ maintainers.polykernel ];
    platforms = platforms.linux;
  };
}
