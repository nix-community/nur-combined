{ pkgs ? import <nixpkgs> { }, lib ? pkgs.lib, callPackage ? pkgs.callPackage }:

let thisLib = import ./lib { inherit pkgs lib callPackage; };
in lib.makeScope pkgs.newScope (self:
  (thisLib.callNixFiles self.callPackage ./pkgs) // {

    lib = lib.extend (self: super: thisLib);

    qemuImages =
      pkgs.recurseIntoAttrs (self.callPackage ./pkgs/qemu-images { });

    python3Packages = pkgs.recurseIntoAttrs
      (lib.makeScope pkgs.python3Packages.newScope (self: {
        asyncer = self.callPackage ./pkgs/asyncer { };
        dbussy = self.callPackage ./pkgs/dbussy { };
        colorpedia = self.callPackage ./pkgs/colorpedia { };
        ssort = self.callPackage ./pkgs/ssort { };
        extcolors = self.callPackage ./pkgs/extcolors { };
        convcolors = self.callPackage ./pkgs/convcolors { };
        pymatting = self.callPackage ./pkgs/pymatting { };
        rembg = self.callPackage ./pkgs/rembg { };
        warctools = self.callPackage ./pkgs/warctools { };
        blender-file = self.callPackage ./pkgs/blender-file { };
        blender-asset-tracer = self.callPackage ./pkgs/blender-asset-tracer { };
        jtbl = self.callPackage ./pkgs/jtbl { };
        git-remote-rclone = self.callPackage ./pkgs/git-remote-rclone { };
        oauth2token = self.callPackage ./pkgs/oauth2token { };
        images-upload-cli = self.callPackage ./pkgs/images-upload-cli { };
        imagehash = self.callPackage ./pkgs/imagehash { };
        pipe21 = self.callPackage ./pkgs/pipe21 { };
        pystitcher = self.callPackage ./pkgs/pystitcher { };
      }));

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
