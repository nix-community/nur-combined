{
  pkgs ? import <nixpkgs> { },
}:

{
  # nix-update must evaluate the new version before it updates the source hash.
  # Keep that evaluation independent of the packaging imported from the source.
  determinate-nix = pkgs.stdenvNoCC.mkDerivation {
    pname = "determinate-nix";
    inherit (pkgs.callPackage ./source.nix { }) version src;
  };
}
