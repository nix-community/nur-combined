# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{
  system ? builtins.currentSystem,
  pkgs ? import <nixpkgs> { inherit system; },
  lib ? pkgs.lib,
}:

lib.makeScope pkgs.newScope (
  self:
  lib.packagesFromDirectoryRecursive {
    inherit (self) callPackage;
    directory = ./pkgs/by-name;
  }
  // {
    lib = import ./lib { inherit system pkgs lib; };

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
          enableOpencl = false;
          enableFreetype = false;
          enablePulse = false;
          enableDdcutil = false;
          enableDirectxHeaders = false;
          enableElf = false;
          enableLibzfs = false;
          enablePciaccess = false;
        };

    libtgdWithoutTool = self.libtgd.override { withTool = false; };

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
          # Broken
          withExiv2 = false;
          withFfmpeg = true;
          withGdal = false;
          withHdf5 = false;
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

    libtgdFullWithoutTool =
      (self.libtgd.overrideAttrs (
        _: prevAttrs: {
          meta = (prevAttrs.meta or { }) // {
            description = "${prevAttrs.meta.description} (with all features enabled)";
          };
        }
      )).override
        {
          withTool = false;
          withDocs = true;
          withCfitsio = true;
          # Broken
          withExiv2 = false;
          withFfmpeg = true;
          withGdal = false;
          withHdf5 = false;
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
          # Broken
          withLevmar = false;
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
          # Broken
          withLevmar = false;
          withPng = true;
          withZlib = true;
        };
  }
)
