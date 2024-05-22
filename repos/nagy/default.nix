{
  pkgs ? import <nixpkgs> { },
  lib ? pkgs.lib,
  callPackage ? pkgs.callPackage,
}:

let
  by-name-overlay = pkgs.path + "/pkgs/top-level/by-name-overlay.nix";
  pkgs-overlay = import by-name-overlay ./pkgs/by-name;
  # this line allows packages to call themselves
  pkgsWithNur = import pkgs.path {
    inherit (pkgs) system;
    overlays = [ pkgs-overlay ];
  };
  applied-overlay = pkgs-overlay pkgsWithNur pkgs;
in
lib.makeScope pkgs.newScope (
  self:
  applied-overlay
  // {

    lib = lib.extend (
      final: prev:
      # this extra callPackage call is needed to give
      # the result an `override` ability.
      (callPackage ./lib { })
    );

    modules = lib.mapAttrs' (
      filename: _filetype:
      lib.nameValuePair "${lib.removeSuffix ".nix" filename}" ((import (./modules + "/${filename}")))
    ) (builtins.readDir ./modules);

    qemuImages = pkgs.recurseIntoAttrs (self.callPackage ./pkgs/qemu-images { });

    python3Packages = pkgs.recurseIntoAttrs (
      lib.makeScope pkgs.python3Packages.newScope (
        self: import ./pkgs/python3-packages { inherit (self) callPackage; }
      )
    );

    lispPackages = pkgs.recurseIntoAttrs {
      cl-opengl = pkgs.callPackage ./pkgs/cl-opengl { };
      cl-raylib = pkgs.callPackage ./pkgs/cl-raylib { };
    };
  }
)
