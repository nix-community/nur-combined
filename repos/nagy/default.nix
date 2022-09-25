{ pkgs ? import <nixpkgs> { }, lib ? pkgs.lib
, recurseIntoAttrs ? pkgs.recurseIntoAttrs }:

with lib;
let
  nixFiles = filterAttrs (k: v: (v == "regular") && hasSuffix ".nix" k)
    (builtins.readDir ./pkgs);
  nagyNurPkgs = makeScope pkgs.newScope (self:

    let
      callPackage = self.callPackage;
      thePackages = mapAttrs' (k: v:
        nameValuePair (removeSuffix ".nix" k)
        (callPackage (./pkgs + ("/" + k)) { })) nixFiles;
    in (thePackages // rec {

      lib = extend
        (self: super: pkgs.callPackage ./lib.nix { inherit (super) lib; });

      luaPackages = lua53Packages;

      qemuImages = recurseIntoAttrs (self.callPackage ./pkgs/qemu-images { });

      lua53Packages = recurseIntoAttrs {
        lua-curl = pkgs.lua53Packages.callPackage ./pkgs/lua-curl { };
      };

      python3Packages = recurseIntoAttrs
        (makeScope pkgs.python3Packages.newScope (py3: {
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
          blender-asset-tracer =
            py3.callPackage ./pkgs/blender-asset-tracer { };
          jtbl = py3.callPackage ./pkgs/jtbl { };
          git-remote-rclone = py3.callPackage ./pkgs/git-remote-rclone { };
          oauth2token = py3.callPackage ./pkgs/oauth2token { };
        }));

      lttoolbox = callPackage ./pkgs/lttoolbox { };

      apertium = callPackage ./pkgs/apertium { };

      lispPackages = recurseIntoAttrs {
        vacietis = pkgs.callPackage ./pkgs/vacietis { };
        dbus = pkgs.callPackage ./pkgs/cl-dbus { };
        cl-opengl = pkgs.callPackage ./pkgs/cl-opengl { };
        cl-raylib = pkgs.callPackage ./pkgs/cl-raylib { };
        s-dot = pkgs.callPackage ./pkgs/s-dot { };
        s-dot2 = pkgs.callPackage ./pkgs/s-dot2 { };
        tinmop = pkgs.callPackage ./pkgs/tinmop { };
      };

      libvosk = callPackage ./pkgs/libvosk { };

      ksv = callPackage ./pkgs/ksv { };

      sasl2-oauth = callPackage ./pkgs/sasl2-oauth.nix { inherit sasl2-oauth; };
    }));

in nagyNurPkgs
