{ pkgs, callPackage }:
rec {
  amdgpu-pro-libs = pkgs.lib.recurseIntoAttrs {
    vulkan = callPackage ./libs/amdgpu-pro-libs { };
    amf = callPackage ./libs/amdgpu-pro-libs/amf.nix { };
    opengl = callPackage ./libs/amdgpu-pro-libs/opengl.nix { };
    prefixes = callPackage ./libs/amdgpu-pro-libs/prefixes.nix { };
    firmware = callPackage ./libs/amdgpu-pro-libs/firmware.nix { };
  };
  svt-av1-psy = callPackage ./libs/svt-av1-psy.nix { };

  ffmpeg_7-amf-full = (pkgs.ffmpeg_7-full.overrideAttrs (finalAttrs: previousAttrs: { configureFlags = previousAttrs.configureFlags ++ [ "--enable-amf" ]; buildInputs = previousAttrs.buildInputs ++ [ pkgs.amf-headers ]; }));

  polymc = pkgs.qt6Packages.callPackage ./apps/games/polymc { };
  polymc-qt5 = pkgs.libsForQt5.callPackage ./apps/games/polymc { };

  alvr = pkgs.callPackage ./apps/games/alvr { };

  vpk_fuse = callPackage ./apps/vpk_fuse.nix { };

  fbset = callPackage ./apps/fbset.nix { };

  lh2ctrl = callPackage ./apps/lh2ctrl.nix { };
}
