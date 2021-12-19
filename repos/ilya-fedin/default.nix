{ pkgs ? import <nixpkgs> {} }:

with pkgs;

rec {
  modules = import ./modules;

  overlays = import ./overlays;

  exo2 = callPackage ./pkgs/exo2 {};

  gtk-layer-background = callPackage ./pkgs/gtk-layer-background {};

  # Qt 5.15 is not default on mac, tdesktop requires 5.15 (and kotatogram subsequently)
  kotatogram-desktop = libsForQt515.callPackage ./pkgs/kotatogram-desktop {
    inherit (darwin.apple_sdk.frameworks)
      Cocoa
      CoreFoundation
      CoreServices
      CoreText
      CoreGraphics
      CoreMedia
      OpenGL
      AudioUnit
      ApplicationServices
      Foundation
      AGL
      Security
      SystemConfiguration
      Carbon
      AudioToolbox
      VideoToolbox
      VideoDecodeAcceleration
      AVFoundation
      CoreAudio
      CoreVideo
      CoreMediaIO
      QuartzCore
      AppKit
      CoreWLAN
      WebKit
      IOKit
      GSS
      MediaPlayer
      IOSurface
      Metal
      MetalKit;

    # C++20 is required, darwin has Clang 7 by default
    stdenv = if stdenv.isDarwin then llvmPackages_12.libcxxStdenv else stdenv;

    # tdesktop has random crashes when jemalloc is built with gcc.
    # Apparently, it triggers some bug due to usage of gcc's builtin
    # functions like __builtin_ffsl by jemalloc when it's built with gcc.
    jemalloc = jemalloc.override { stdenv = llvmPackages.stdenv; };
  };

  mir = callPackage ./pkgs/mir {};

  mirco = callPackage ./pkgs/mirco {
    inherit mir;
  };

  silver = callPackage ./pkgs/silver {};

  virtualboxWithExtpack = virtualbox.override {
    extensionPack = virtualboxExtpack;
  };

  #wlcs = callPackage ./pkgs/wlcs {};
}
