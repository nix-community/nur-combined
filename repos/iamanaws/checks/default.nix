{
  pkgs,
  inputs,
  hostRegistry,
}:
let
  inherit (pkgs) lib;
  inherit (pkgs.stdenv) hostPlatform;
  inherit (import ../lib/hostUtils.nix { inherit lib; }) mkModuleTree mkNixosModules;

  args = {
    inherit
      pkgs
      lib
      inputs
      hostRegistry
      ;
    # A path, so a check copies only the files it names
    flakeRoot = ../.;
    nixosModules = mkNixosModules ../nixos;
  };
  join = lib.concatStringsSep "-";

  # Backend directories only apply on their own platform
  backends = {
    nixos = hostPlatform.isLinux;
    darwin = hostPlatform.isDarwin;
  };

  # A file is one check, it returns true or a derivation
  check =
    name: path:
    let
      value = import path args;
    in
    if lib.isDerivation value then
      value
    else
      assert value;
      pkgs.runCommand name { } ''
        touch "$out"
      '';

  # A directory's default.nix returns several checks, fixtures hold data
  load =
    prefix:
    lib.concatMapAttrs (
      name: value:
      if name == "fixtures" then
        { }
      else if name == "default" then
        lib.mapAttrs' (key: lib.nameValuePair (join (prefix ++ [ key ]))) (import value args)
      else if lib.isAttrs value then
        load (prefix ++ [ name ]) value
      else
        { ${join (prefix ++ [ name ])} = check (join (prefix ++ [ name ])) value; }
    );
in
# Every file below this directory is a check, named after its path
load [ ] (
  lib.filterAttrs (name: _: name != "default" && (backends.${name} or true)) (mkModuleTree ./.)
)
