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

  exo2 = runCommand "exo2" { nativeBuildInputs = [ pkgs.python3Packages.fonttools ]; } ''
    cp -r --no-preserve=mode ${google-fonts.override { fonts = [ "Exo2" ]; }} $out
    find $out -name '*.ttf' -exec python -c "import sys; from fontTools.ttLib import TTFont; from fontTools.ttLib.tables.otTables import GlyphClassDef; f = TTFont(sys.argv[1]); f['GDEF'].table.GlyphClassDef.classDefs[f.getBestCmap()[0x60]] = 1; f.save(sys.argv[1])" {} \;
  '';

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
}) { inherit pkgs; }
