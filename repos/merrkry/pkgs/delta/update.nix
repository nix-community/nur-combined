{
  pkgs ? import <nixpkgs> { },
}:

{
  # Let nix-update change the source pin before importing its packaging.
  delta = pkgs.stdenvNoCC.mkDerivation (finalAttrs: {
    __structuredAttrs = true;
    strictDeps = true;
    pname = "delta";
    inherit (pkgs.callPackage ./source.nix { }) version src;
  });
}
