{ config, pkgs, lib, ... }:

with lib;

let
  inherit (pkgs) writeText;
  cfg = config.services.unison;

  concatMapAttrsStringsSep = sep: f: attrs: concatStringsSep sep (mapAttrsToList f attrs);

  toKV = k: v:
    if isList v then concatMapStringsSep "\n" (toKV k) v
    else if isBool v then toKV k (if v then "true" else "false")
    else "${k} = ${toString v}";

  toProfile = p: concatMapAttrsStringsSep "\n" toKV p;

  mkUnisonService = name: profile: {
    path = with pkgs; [ cfg.package openssh ];

    serviceConfig = {
      Restart = "always";
      RestartSec = 10;

      User = config.users.users.unison.name;
      CPUQuota = "${toString cfg.cpuQuota}%";
    };

    environment = {
      HOME = cfg.stateDir;
      UNISON = cfg.stateDir;
    };

    preStart = ''
      cp ${writeText "${name}.prf" (toProfile profile)} \
         ${cfg.stateDir}/${name}.prf
    '';

    script = ''
      ${cfg.package}/bin/unison ${name}
    '';

    postStop = ''
      rm ${cfg.stateDir}/${name}.prf
    '';

    wantedBy = [ "multi-user.target" ];
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

    profiles = mkOption {
      default = {};
      type = attrsOf attrs;
    };
  };

  config = mkIf cfg.enable {
    users.users.unison = {
      group = "unison";
      isSystemUser = true;
      shell = pkgs.bash;

      home = cfg.stateDir;
      createHome = true;

      packages = [ cfg.package ];
    };

    users.groups.unison = {};

    systemd.services =
      mapAttrs'
        (n: v: (nameValuePair "unison-${n}" (mkUnisonService n v)))
        cfg.profiles;
  };
}
