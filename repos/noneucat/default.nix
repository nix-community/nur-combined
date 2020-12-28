{ pkgs ? import <nixpkgs> {} }:

rec {
  # Add modules paths
  modules = import ./modules;

  codemadness-frontends = pkgs.callPackage ./pkgs/codemadness-frontends/default.nix { };
  ffmpeg-full-cuda = pkgs.callPackage ./pkgs/ffmpeg-full-cuda/default.nix { };
  immersed = pkgs.callPackage ./pkgs/immersed/default.nix { };
  immersed-cuda = pkgs.callPackage ./pkgs/immersed/default.nix { 
    ffmpeg-full = ffmpeg-full-cuda;
  };
  sfeed = pkgs.callPackage ./pkgs/sfeed/default.nix { };

  # PinePhone-related packages
  pinephone = { 
    megapixels = pkgs.callPackage ./pkgs/pinephone/megapixels/default.nix { };
    sxmo = pkgs.callPackage ./pkgs/pinephone/sxmo/default.nix { };
  };
}
