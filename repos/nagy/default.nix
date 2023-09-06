{ pkgs ? import <nixpkgs> { }, lib ? pkgs.lib, callPackage ? pkgs.callPackage }:

let thisLib = import ./lib { inherit pkgs lib callPackage; };
in lib.makeScope pkgs.newScope (self:
  (thisLib.callNixFiles self.callPackage ./pkgs) // {

    lib = lib.extend (final: prev:
      # this extra callPackage call is needed to give
      # the result an `override` ability.
      (callPackage ./lib { }));

    qemuImages =
      pkgs.recurseIntoAttrs (self.callPackage ./pkgs/qemu-images { });

    python3Packages = pkgs.recurseIntoAttrs
      (lib.makeScope pkgs.python3Packages.newScope
        (self: import ./pkgs/python3-packages { inherit (self) callPackage; }));

    lispPackages = pkgs.recurseIntoAttrs {
      vacietis = pkgs.callPackage ./pkgs/vacietis { };
      dbus = pkgs.callPackage ./pkgs/cl-dbus { };
      cl-opengl = pkgs.callPackage ./pkgs/cl-opengl { };
      cl-raylib = pkgs.callPackage ./pkgs/cl-raylib { };
      s-dot = pkgs.callPackage ./pkgs/s-dot { };
      s-dot2 = pkgs.callPackage ./pkgs/s-dot2 { };
      tinmop = pkgs.callPackage ./pkgs/tinmop { };
    };

    ksv = self.callPackage ./pkgs/ksv { };

    qr2text = self.callPackage ./pkgs/qr2text { };

    urlp = self.callPackage ./pkgs/urlp { };

    overlay = lib.composeManyExtensions (thisLib.importNixFiles ./overlays);
  })
