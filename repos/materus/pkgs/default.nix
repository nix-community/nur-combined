{ pkgs, callPackage }:
rec {
  amdgpu-pro-libs = pkgs.lib.recurseIntoAttrs {
    vulkan = callPackage ./libs/amdgpu-pro-libs { };
    amf = callPackage ./libs/amdgpu-pro-libs/amf.nix { };
    opengl = callPackage ./libs/amdgpu-pro-libs/opengl.nix { };
    prefixes = callPackage ./libs/amdgpu-pro-libs/prefixes.nix { };
    firmware = callPackage ./libs/amdgpu-pro-libs/firmware.nix { };
  };


  ffmpeg6-amf-full = (if pkgs.lib.versionOlder pkgs.ffmpeg-full.version "6.1" then
    pkgs.callPackage ./apps/ffmpeg
      {
        inherit (pkgs.darwin.apple_sdk.frameworks)
          Cocoa CoreServices CoreAudio CoreMedia AVFoundation MediaToolbox
          VideoDecodeAcceleration VideoToolbox;
      } else
    (pkgs.ffmpeg-full.overrideAttrs (finalAttrs: previousAttrs: { configureFlags = previousAttrs.configureFlags ++ [ "--enable-amf" ]; buildInputs = previousAttrs.buildInputs ++ [ pkgs.amf-headers ]; }))
  );

  obs-amf = pkgs.qt6Packages.callPackage ./apps/obs { ffmpeg = ffmpeg6-amf-full; inherit libcef; };

  polymc = pkgs.qt6Packages.callPackage ./apps/games/polymc { };
  polymc-qt5 = pkgs.libsForQt5.callPackage ./apps/games/polymc { };

  alvr = pkgs.callPackage ./apps/games/alvr { };

  vpk_fuse = callPackage ./apps/vpk_fuse.nix { };

  fbset = callPackage ./apps/fbset.nix { };

  libcef = callPackage ./libs/libcef.nix { };

  lh2ctrl = callPackage ./apps/lh2ctrl.nix { };

  emacs-materus = (pkgs.emacs29.override { withSQLite3 = true; withWebP = true; withX = true; withGTK3 = true; withAlsaLib = true; withGconf = true; withImageMagick = true; withXwidgets = true; });
}
