{ pkgs ? null }: (args: let
  pkgs = if (builtins.tryEval args.pkgs).success && args.pkgs != null
    then args.pkgs
    else import (import ./flake-compat.nix).inputs.nixpkgs {
      config = import ./nixpkgs-config.nix;
    };
in with pkgs; rec {
  modules = import ./modules;

  overlays = import ./overlays;

  airsane = callPackage ./pkgs/airsane {};

  hplipWithPlugin = if stdenv.hostPlatform.isLinux then pkgs.hplipWithPlugin else null;

  nixos-collect-garbage = writeShellScriptBin "nixos-collect-garbage" ''
    ${nix}/bin/nix-collect-garbage "$@"
    /run/current-system/bin/switch-to-configuration boot
  '';

  qt6ct = import ./pkgs/qt6ct pkgs;

  sambaWithMDNS = samba.override { enableMDNS = true; };

  silver = callPackage ./pkgs/silver {};

  termbin = writeShellScriptBin "tb" ''
    exec ${netcat}/bin/nc termbin.com 9999
  '';

  ttf-croscore = google-fonts.override { fonts = [ "Arimo" "Cousine" "Tinos" ]; };
}) { inherit pkgs; }
