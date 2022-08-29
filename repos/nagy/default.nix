{ pkgs ? import <nixpkgs> { }, lib ? pkgs.lib, callPackage ? pkgs.callPackage
, recurseIntoAttrs ? pkgs.recurseIntoAttrs }:

let
  nixFiles = lib.filterAttrs (k: v: (v == "regular") && lib.hasSuffix ".nix" k)
    (builtins.readDir ./pkgs);
  thePackages = lib.mapAttrs' (k: v:
    lib.nameValuePair (lib.removeSuffix ".nix" k)
    (callPackage (./pkgs + ("/" + k)) { })) nixFiles;
in thePackages // rec {

  lib = callPackage ./lib.nix { };

  luaPackages = lua53Packages;

  lua53Packages = recurseIntoAttrs {
    lua-curl = pkgs.lua53Packages.callPackage ./pkgs/lua-curl { };
  };

  python3Packages = recurseIntoAttrs
    (pkgs.lib.makeScope pkgs.python3Packages.newScope (py3: {
      asyncer = py3.callPackage ./pkgs/asyncer { };
      vosk = py3.callPackage ./pkgs/libvosk/python.nix { inherit libvosk; };
      dbussy = py3.callPackage ./pkgs/dbussy { };
      colorpedia = py3.callPackage ./pkgs/colorpedia { };
      ssort = py3.callPackage ./pkgs/ssort { };
      extcolors = py3.callPackage ./pkgs/extcolors { };
      convcolors = py3.callPackage ./pkgs/convcolors { };
      pymatting = py3.callPackage ./pkgs/pymatting { };
      rembg = py3.callPackage ./pkgs/rembg { };
      warctools = py3.callPackage ./pkgs/warctools { };
      blender-file = py3.callPackage ./pkgs/blender-file { };
      blender-asset-tracer = py3.callPackage ./pkgs/blender-asset-tracer { };
      jtbl = py3.callPackage ./pkgs/jtbl { };
    }));

  lttoolbox = callPackage ./pkgs/lttoolbox { };

  apertium = callPackage ./pkgs/apertium { inherit lttoolbox; };

  lispPackages = recurseIntoAttrs {
    vacietis = callPackage ./pkgs/vacietis { };
    dbus = callPackage ./pkgs/cl-dbus { };
  };

  libvosk = callPackage ./pkgs/libvosk { };

  cl-opengl = callPackage ./pkgs/cl-opengl { };

  cl-raylib = callPackage ./pkgs/cl-raylib { };

  ksv = callPackage ./pkgs/ksv { };

  sasl2-oauth = callPackage ./pkgs/sasl2-oauth.nix { inherit sasl2-oauth; };
}
