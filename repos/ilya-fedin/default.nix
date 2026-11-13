{ pkgs ? null, system ? builtins.currentSystem }: (args: let
  pkgs = if (builtins.tryEval args.pkgs).success && args.pkgs != null
    then args.pkgs
    else import (import ./flake-compat.nix).inputs.nixpkgs {
      inherit system;
      config = import ./nixpkgs-config.nix;
    };
in with pkgs; rec {
  modules = import ./modules;

  overlays = import ./overlays;

  airsane = callPackage ./pkgs/airsane {};

  exo2 = runCommand "exo2" { nativeBuildInputs = [ pkgs.python3Packages.fonttools ]; } ''
    cp -r --no-preserve=mode ${google-fonts.override { fonts = [ "Exo2" ]; }} $out
    find $out -name '*.ttf' -exec python -c "import sys; from fontTools.ttLib import TTFont; f = TTFont(sys.argv[1]); g = f.getBestCmap()[0x60]; f['GDEF'].table.GlyphClassDef.classDefs[g] = 1; [s.MarkCoverage.glyphs.remove(g) for l in f['GPOS'].table.LookupList.Lookup for s in l.SubTable if hasattr(s, 'MarkCoverage') and g in s.MarkCoverage.glyphs]; f.save(sys.argv[1])" {} \;
  '';

  hplipWithPlugin = pkgs.hplipWithPlugin;

  nixos-collect-garbage = writeShellScriptBin "nixos-collect-garbage" ''
    ${lib.getExe' nix "nix-collect-garbage"} "$@"
    /run/current-system/bin/switch-to-configuration boot
  '';

  qt6ct = import ./pkgs/qt6ct pkgs;

  sambaWithMDNS = samba.override { enableMDNS = true; };

  termbin = writeShellScriptBin "tb" ''
    exec ${lib.getExe netcat} termbin.com 9999
  '';

  ttf-croscore = google-fonts.override { fonts = [ "Arimo" "Cousine" "Tinos" ]; };
}) { inherit pkgs; }
