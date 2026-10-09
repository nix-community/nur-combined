{
  pkgs ? import <nixpkgs> { },
}:

{
  # Let nix-update change the source pin before importing its packaging.
  delta = pkgs.stdenvNoCC.mkDerivation {
    pname = "delta";
    inherit (pkgs.callPackage ./source.nix { }) version src;
  };
}
