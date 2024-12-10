{ config, lib, pkgs, ... }:
let
  cfg = config.sane.programs.man-db;
in
{
  sane.programs.man-db = {
    buildCost = 1;  # the cache takes a couple minutes to generate; can only build after *everything* else
    sandbox.autodetectCliPaths = "existingFile";
  };

  # fixup `apropos` & others to actually work.
  documentation.man = lib.mkIf cfg.enabled {
    # generateCaches = true;
    man-db.package = cfg.package;
  };

  environment.etc."man_db.conf".text = let
    # imported logic from <repo:nixos/nixpkgs:nixos/modules/misc/man-db.nix>,
    # but it actually works
    manualCache = pkgs.runCommand "man-cache" {
      nativeBuildInputs = [ cfg.packageUnwrapped ];
    } ''
      echo "MANDB_MAP ${config.documentation.man.man-db.manualPages}/share/man $out" > man.conf
      mandb -C man.conf -psc >/dev/null 2>&1
    '';
  in lib.mkIf cfg.enabled (lib.mkBefore ''
    # Generated manual pages cache for NixOS (immutable)
    MANDB_MAP /run/current-system/sw/share/man ${manualCache}
  '');
}
