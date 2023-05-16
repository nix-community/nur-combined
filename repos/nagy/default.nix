{ pkgs ? import <nixpkgs> { }, lib ? pkgs.lib
, recurseIntoAttrs ? pkgs.recurseIntoAttrs }:

let
  inherit (import ./lib {
    inherit pkgs lib;
    inherit (pkgs) callPackage;
  })
    callNixFiles importNixFiles;
in lib.makeScope pkgs.newScope (self:
  (callNixFiles self.callPackage ./pkgs) // {

    lib = lib.extend (self: super: pkgs.callPackage ./lib { });

    qemuImages = recurseIntoAttrs (self.callPackage ./pkgs/qemu-images { });

    python3Packages = recurseIntoAttrs
      (lib.makeScope pkgs.python3Packages.newScope (py3: {
        dool = py3.callPackage ./pkgs/dool { };
        asyncer = py3.callPackage ./pkgs/asyncer { };
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
        git-remote-rclone = py3.callPackage ./pkgs/git-remote-rclone { };
        oauth2token = py3.callPackage ./pkgs/oauth2token { };
        images-upload-cli = py3.callPackage ./pkgs/images-upload-cli { };
        imagehash = py3.callPackage ./pkgs/imagehash { };
      }));

    lispPackages = recurseIntoAttrs {
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

    rfcs = self.callPackage ./pkgs/rfcs.nix { };

    overlay = lib.composeManyExtensions (importNixFiles ./overlays);
  })
