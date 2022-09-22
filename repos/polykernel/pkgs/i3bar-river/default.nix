{ lib
, rustPlatform
, fetchFromGitHub
, pkg-config
, pango
, cairo
, glib
, wayland
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
    rev = "9ddde2d2ee9833412e39afbd1ed907cdea22f08f";
    sha256 = "sha256-58Rw/PBvQX90L99aI32lA+pcO2jfwmiHKeV6ZdDp07Q=";
  };

  cargoHash = "sha256-lhrFGNyQ0zBdmT6QbMuDEAnZk39uDkRwgWqXibYRJxY=";

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ pango ];

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
