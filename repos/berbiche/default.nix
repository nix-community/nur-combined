{ pkgs ? import <nixpkgs> {}
# nixpkgs' rustPlatform with an unstable version of Rust
, rustPlatformNightly ? null
}:

let
  inherit (pkgs) lib;

  niv = import ./nix/sources.nix;

  rust-overlay = import pkgs.path {
    inherit (pkgs) system;
    overlays = [ (import niv.rust-overlay) ];
  };
  rustUnstable = rust-overlay.rust-bin.nightly.latest;
  rustPlatform =
    if rustPlatformNightly != null then
      rustPlatformNightly
    else
      pkgs.makeRustPlatform { cargo = rustUnstable.cargo; rustc = rustUnstable.default; };

  pkgs' = self: {
    inherit rustPlatform;
    callPackage = lib.callPackageWith (pkgs // self);
    callPackages  = lib.callPackagesWith (pkgs // self);

    # Had to adapt the CI script
    eww = throw "eww has been renamed to 'eww-flavors.x11'.";
    eww-flavors = lib.recurseIntoAttrs (self.callPackages ./pkgs/eww { });
    eww-wayland = self.eww-flavors.wayland;
    eww-x11 = self.eww-flavors.x11;

    kinect-audio-setup = self.callPackage ./pkgs/kinect-audio-setup { };
    mpvpaper = self.callPackage ./pkgs/mpvpaper { };
    waylock = self.callPackage ./pkgs/waylock { };
    wlclock = self.callPackage ./pkgs/wlclock { };
    wlr-sunclock = self.callPackage ./pkgs/wlr-sunclock { };

    # nwg-piotr's stuff
    nwg-panel = self.callPackage ./pkgs/nwg-panel { };
    nwg-menu = self.callPackage ./pkgs/nwg-menu { };
  };

  pkgs'' = lib.fix pkgs' // {
    lib = import ./lib { inherit pkgs; }; # functions
    modules = import ./modules; # NixOS modules
    overlays = import ./overlays; # nixpkgs overlays
  };
in
  # Do not expose these internal attributes
  builtins.removeAttrs pkgs'' [ "rustPlatform" "callPackage" "callPackages" ]
