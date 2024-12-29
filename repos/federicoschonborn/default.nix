# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{
  lib ? import <nixpkgs/lib>,
  pkgs ? import <nixpkgs> { inherit system; },
  system ? builtins.currentSystem,
}:

lib.makeScope pkgs.newScope (
  self:
  lib.packagesFromDirectoryRecursive {
    inherit (self) callPackage;
    directory = ./pkgs/by-name;
  }
  // {
    lib = import ./lib { inherit lib; };

    # Sets
    akkoma-emoji = lib.recurseIntoAttrs (self.callPackage ./pkgs/akkoma-emoji { });
    lapcePlugins = lib.recurseIntoAttrs (self.callPackage ./pkgs/lapce-plugins { });

    # Variants
    fastfetchMinimal =
      (self.fastfetch.overrideAttrs (
        _: prevAttrs: {
          meta = (prevAttrs.meta or { }) // {
            description = "${prevAttrs.meta.description} (with all features disabled)";
          };
        }
      )).override
        {
          enableVulkan = false;
          enableWayland = false;
          enableXcbRandr = false;
          enableXrandr = false;
          enableDrm = false;
          enableDrmAmdgpu = false;
          enableGio = false;
          enableDconf = false;
          enableDbus = false;
          enableXfconf = false;
          enableSqlite3 = false;
          enableRpm = false;
          enableImagemagick = false;
          enableChafa = false;
          enableZlib = false;
          enableEgl = false;
          enableGlx = false;
          enableOsmesa = false;
          enableOpencl = false;
          enableFreetype = false;
          enablePulse = false;
          enableDdcutil = false;
          enableDirectxHeaders = false;
          enableElf = false;
          enableLibzfs = false;
          enablePciaccess = false;
        };

    dcmtkShared = pkgs.dcmtk.overrideAttrs (
      _: prevAttrs: {
        nativeBuildInputs = (prevAttrs.nativeBuildInputs or [ ]) ++ [ pkgs.ninja ];
        cmakeFlags = [ (lib.cmakeBool "BUILD_SHARED_LIBS" true) ];
      }
    );

    gtatoolFull =
      (self.gtatool.overrideAttrs (
        _: prevAttrs: {
          meta = (prevAttrs.meta or { }) // {
            description = "${prevAttrs.meta.description} (with all features enabled)";
          };
        }
      )).override
        {
          # Broken
          withBashCompletion = false;
          withDcmtk = true;
          withExr = true;
          # Needs patching
          withFfmpeg = false;
          withGdal = true;
          withJpeg = true;
          # ImageMagick 6 is marked as insecure
          withMagick = false;
          withMatio = true;
          withMuparser = true;
          withNetcdf = true;
          withNetpbm = true;
          withPcl = true;
          # Requires ImageMagick 6
          withPfs = false;
          withPng = true;
          # Needs patching
          withQt = false;
          withSndfile = true;
          withTeem = true;
        };

    libtgdFull =
      (self.libtgd.overrideAttrs (
        _: prevAttrs: {
          meta = (prevAttrs.meta or { }) // {
            description = "${prevAttrs.meta.description} (with all features enabled)";
          };
        }
      )).override
        {
          withTool = true;
          withDocs = true;
          withCfitsio = true;
          withDmctk = true;
          # Broken
          withExiv2 = false;
          withFfmpeg = true;
          withGdal = true;
          withGta = true;
          withHdf5 = true;
          withJpeg = true;
          # ImageMagick 6 is marked as insecure
          withMagick = false;
          withMatio = true;
          withMuparser = true;
          withOpenexr = true;
          # Requires ImageMagick 6
          withPfs = false;
          withPng = true;
          withPoppler = true;
          withTiff = true;
        };

    razeFull =
      (self.raze.overrideAttrs (
        _: prevAttrs: {
          meta = (prevAttrs.meta or { }) // {
            description = "${prevAttrs.meta.description} (with all features enabled)";
          };
        }
      )).override
        { withGtk3 = true; };

    teemFull =
      (self.teem.overrideAttrs (
        _: prevAttrs: {
          meta = (prevAttrs.meta or { }) // {
            description = "${prevAttrs.meta.description} (with all features enabled)";
          };
        }
      )).override
        {
          withBzip2 = true;
          withPthread = true;
          withFftw3 = true;
          withLevmar = true;
          withPng = true;
          withZlib = true;
        };

    teemExperimental =
      (self.teem.overrideAttrs (
        _: prevAttrs: {
          meta = (prevAttrs.meta or { }) // {
            description = "${prevAttrs.meta.description} (with experimental libraries and applications enabled)";
          };
        }
      )).override
        {
          withExperimentalApps = true;
          withExperimentalLibs = true;
        };

    teemExperimentalFull =
      (self.teem.overrideAttrs (
        _: prevAttrs: {
          meta = (prevAttrs.meta or { }) // {
            description = "${prevAttrs.meta.description} (with experimental libraries and applications, and all features enabled)";
          };
        }
      )).override
        {
          withExperimentalApps = true;
          withExperimentalLibs = true;
          withBzip2 = true;
          withPthread = true;
          withFftw3 = true;
          withLevmar = true;
          withPng = true;
          withZlib = true;
        };
  }
)
