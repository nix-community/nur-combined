{ pkgs }:

let
  inherit (pkgs)
    mkShell
    exiftool
    flacon
    flac
    losslesscut-bin
    qflipper
    shntool
    sops
    sox
    ssh-to-age
    ;

in
{
  exif = mkShell { buildInputs = [ exiftool ]; };
  flac = mkShell {
    buildInputs = [
      flacon
      flac
      shntool
      sox
    ];
  };
  flipper = mkShell { buildInputs = [ qflipper ]; };
  sops-env = mkShell {
    buildInputs = [
      sops
      ssh-to-age
    ];
  };
  video = mkShell { buildInputs = [ losslesscut-bin ]; };
}
