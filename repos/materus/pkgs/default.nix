{ pkgs, callPackage }:
rec {
  amdgpu-pro-libs = pkgs.lib.recurseIntoAttrs {
    vulkan = callPackage ./libs/amdgpu-pro-libs { };
    amf = callPackage ./libs/amdgpu-pro-libs/amf.nix { };
    opengl = callPackage ./libs/amdgpu-pro-libs/opengl.nix { };
    prefixes = callPackage ./libs/amdgpu-pro-libs/prefixes.nix { };
    firmware = callPackage ./libs/amdgpu-pro-libs/firmware.nix { };
  };


  ffmpeg6-amf-full = pkgs.callPackage ./apps/ffmpeg {
    inherit (pkgs.darwin.apple_sdk.frameworks)
      Cocoa CoreServices CoreAudio CoreMedia AVFoundation MediaToolbox
      VideoDecodeAcceleration VideoToolbox;
  };

  obs-amf = pkgs.qt6Packages.callPackage ./apps/obs { ffmpeg = ffmpeg6-amf-full; };

  polymc = pkgs.qt6Packages.callPackage ./apps/games/polymc {};

  xmake = callPackage ./dev/xmake {};

}
