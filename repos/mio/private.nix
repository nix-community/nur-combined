{
  pkgs ? import <nixpkgs> {
    #config.permittedInsecurePackages = [
    #  "qtwebengine-5.15.19"
    #];
    config.allowUnfree = true;
  },
}:
rec {
  stdenv = pkgs.stdenv;
  fixcmake =
    x:
    x.overrideAttrs (old: {
      cmakeFlags = (old.cmakeFlags or [ ]) ++ [
        "-DCMAKE_POLICY_VERSION_MINIMUM=3.5"
      ];
    });
  v3Optimizations =
    if pkgs.stdenv.hostPlatform.isx86_64 then
      pkgs.stdenvAdapters.withCFlags [
        "-march=x86-64-v3"
        "-mtune=raptorlake"
      ]
    else
      stdenv: stdenv;
  v3overrideAttrs =
    if pkgs.stdenv.hostPlatform.isx86_64 then
      x:
      x.overrideAttrs (old: {
        env.NIX_CFLAGS_COMPILE = "-march=x86-64-v3 -mtune=raptorlake";
        env.RUSTFLAGS = "-C target_cpu=x86-64-v3";
      })
    else
      x: x;
  goV3OverrideAttrs =
    if pkgs.stdenv.hostPlatform.isx86_64 then
      x:
      x.overrideAttrs (old: {
        GOAMD64 = "v3";
      })
    else
      x: x;
  v3override =
    if pkgs.stdenv.hostPlatform.isx86_64 then
      x:
      x.override (prev: {
        stdenv = v3Optimizations pkgs.clangStdenv;
      })
    else
      x:
      x.override (prev: {
        stdenv = pkgs.clangStdenv;
      });
  v3overridegcc =
    if pkgs.stdenv.hostPlatform.isx86_64 then
      x:
      x.override (prev: {
        stdenv = v3Optimizations prev.stdenv;
      })
    else
      x: x;
  nodarwin =
    x:
    x.overrideAttrs (old: {
      meta = old.meta // {
        broken = pkgs.stdenv.hostPlatform.isDarwin;
      };
    });
  x8664linux =
    x:
    x.overrideAttrs (old: {
      meta = old.meta // {
        broken = !pkgs.stdenv.hostPlatform.isLinux || !pkgs.stdenv.hostPlatform.isx86_64;
      };
    });
  wip =
    x:
    x.overrideAttrs (old: {
      meta = old.meta // {
        broken = true;
      };
    });
  #  from chaotic-nyx
  nyxUtils = import ./shared/utils.nix {
    lib = pkgs.lib;
    nyxOverlay = null;
  };
  inherit (nyxUtils) multiOverride overrideDescription drvDropUpdateScript;
  #  from chaotic-nyx
  callOverride =
    path: attrs:
    with pkgs;
    import path (
      {
        final = pkgs;
        prev = pkgs;
        flakes = {
          self.overlays = import ./overlays;
          nixpkgs = pkgs.path;
        };
        inherit
          nyxUtils
          gitOverride
          rustPlatform_latest
          ;
      }
      // attrs
    );

  #  from chaotic-nyx
  gitOverride =
    with pkgs;
    import ./shared/git-override.nix {
      inherit (pkgs)
        lib
        callPackage
        fetchFromGitHub
        fetchFromGitLab
        fetchFromGitea
        ;
      inherit (pkgs.rustPlatform) fetchCargoVendor;
      nyx = ./.;
      fetchRevFromGitHub = pkgs.callPackage ./shared/github-rev-fetcher.nix { };
      fetchRevFromGitLab = pkgs.callPackage ./shared/gitlab-rev-fetcher.nix { };
      fetchRevFromGitea = pkgs.callPackage ./shared/gitea-rev-fetcher.nix { };
    };

  icu = pkgs.callPackage ./pkgs/icu { };
  cachyosPackages = callOverride ./pkgs/linux-cachyos { nyxUtils = nyxUtils; };
}
