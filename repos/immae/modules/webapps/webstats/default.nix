{ lib, pkgs, config, ... }:
let
  name = "goaccess";
  cfg = config.services.webstats;
in {
  options.services.webstats = {
    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/${name}";
      description = ''
        The directory where Goaccess stores its data.
      '';
    };
    sites = lib.mkOption {
      type = lib.types.listOf (lib.types.submodule {
        options = {
          conf = lib.mkOption {
            type = lib.types.nullOr lib.types.path;
            default = null;
            description = ''
              use custom goaccess configuration file instead of the
              default one.
              '';
          };
          name = lib.mkOption {
            type = lib.types.str;
            description  = ''
              Domain name. Corresponds to the Apache file name and the
              folder name in which the state will be saved.
              '';
          };
        };
      });
      default = [];
      description = "Sites to generate stats";
    };
  };

  config = lib.mkIf (builtins.length cfg.sites > 0) {
    services.duplyBackup.profiles.goaccess = {
      rootDir = cfg.dataDir;
    };
    users.users.root.packages = [
      pkgs.goaccess
    ];

    services.cron = {
      enable = true;
      systemCronJobs = let
        stats = domain: conf: let
          config = if builtins.isNull conf
            then pkgs.runCommand "goaccess.conf" {
                dbPath = "${cfg.dataDir}/${domain}";
              } "substituteAll ${./goaccess.conf} $out"
            else conf;
          d = pkgs.writeScriptBin "stats-${domain}" ''
            #!${pkgs.stdenv.shell}
            set -e
            shopt -s nullglob
            date_regex=$(LC_ALL=C date -d yesterday +'%d\/%b\/%Y')
            TMPFILE=$(mktemp)
            trap "rm -f $TMPFILE" EXIT

            mkdir -p ${cfg.dataDir}/${domain}
            cat /var/log/httpd/access-${domain}.log | sed -n "/\\[$date_regex/ p" > $TMPFILE
            for i in /var/log/httpd/access-${domain}*.gz; do
              zcat "$i" | sed -n "/\\[$date_regex/ p" >> $TMPFILE
            done
            ${pkgs.goaccess}/bin/goaccess $TMPFILE --no-progress -o ${cfg.dataDir}/${domain}/index.html -p ${config}
            '';
          in "${d}/bin/stats-${domain}";
        allStats = sites: pkgs.writeScript "stats" ''
          #!${pkgs.stdenv.shell}

          mkdir -p ${cfg.dataDir}
          ${builtins.concatStringsSep "\n" (map (v: stats v.name v.conf) sites)}
          '';
      in
        [
          "5 0 * * * root ${allStats cfg.sites}"
        ];
    };
  };
}
