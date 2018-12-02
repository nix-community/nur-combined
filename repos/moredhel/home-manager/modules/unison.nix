{ config, pkgs, lib, ... }:
# shamelessy stolen and adapted from:
# https://github.com/nix-community/nur-combined/blob/96802352ff320fd19a12f317607aadaa61e82389/repos/tilpner/modules/unison.nix

with lib;

let
  inherit (pkgs) writeText;
  cfg = config.services.unison;

  mkUnisonService = name: opts: {
    # path = with pkgs; [ cfg.package ];

    Unit = {
      Description = "Unison Daemon profile: ${name}";
      After = [ "graphical-session-pre.target" ];
      PartOf = [ "graphical-session.target" ];
      Restart = "always";
      RestartSec = 10;
      CPUQuota = "${toString cfg.cpuQuota}%";
    };

    Service = {
      ExecStart = "${cfg.package}/bin/unison ${opts.extraArgs} ${opts.src} ${opts.dest}";
    };
  };
in {
  options.services.unison = with types; {
    enable = mkEnableOption "unison";

    package = mkOption {
      type = package;
      default = pkgs.unison;
    };

    stateDir = mkOption {
      type = path;
      default = "/var/lib/unison";
    };

    cpuQuota = mkOption {
      type = int;
      default = 75;
    };

    # format
    # src: source directory
    # dest: dest directory
    # cli switches.
    profiles = mkOption {
      default = {};
      type = attrsOf attrs;
    };
  };

  config = let
    service = mapAttrs'
        (n: v: (nameValuePair "unison-${n}" (mkUnisonService n v)))
        cfg.profiles;
    in
    mkIf cfg.enable {
      systemd.user.services = service;
    };
}
