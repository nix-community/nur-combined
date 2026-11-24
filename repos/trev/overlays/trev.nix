{
  nixpkgs ? <nixpkgs>,
}:
_: prev:
let
  inherit (prev) lib;

  nur = import ../. {
    inherit nixpkgs;
    system = prev.stdenv.buildPlatform.system;
    pkgs = prev;
    includeFlakePackages = true;
  };

  # the -latest suffix keeps the packages overlay from replacing nixpkgs' versions,
  # under trev there's nothing to replace, so they're also available without it
  unsuffixed = lib.mapAttrs' (name: lib.nameValuePair (lib.removeSuffix "-latest" name)) (
    lib.filterAttrs (name: _: lib.hasSuffix "-latest" name) nur
  );
in
{
  trev = unsuffixed // nur;
}
