{ pkgs ? import <nixpkgs> { }

, channels
, package ? null
}:

let
  inherit (builtins) findFile nixPath removeAttrs;
  inherit (lib) concatMapAttrs filterAttrs genAttrs getAttrs mapAttrs' nameValuePair warnIf;
  inherit (pkgs) lib;

  mkNur = p: import ../../nur.nix { pkgs = p; };
  nurLibs = [ "hmModules" "modules" "lib" ];
in
filterAttrs
  (n: v: let broken = v ? meta && v.meta.problems ? broken; in warnIf broken "${n}: broken" (! broken))
  (concatMapAttrs
    (channelName: channelPkgs:
    mapAttrs'
      (n: nameValuePair "${n}@${channelName}")
      (
        let nur = mkNur channelPkgs; in
        if package == null then removeAttrs nur nurLibs
        else getAttrs [ package ] nur
      )
    )
    (genAttrs channels (c: import (findFile nixPath c) { config.allowUnfree = true; overlays = [ ]; })))
