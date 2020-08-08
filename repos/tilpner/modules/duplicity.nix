{ config, pkgs, lib, ... }:

# Manual setup required:
#   Create a file /var/lib/duplicity/env/global.sh to set environment variables
#   required for duplicity to authenticate with your storage target, e.g.:
#     export AWS_ACCESS_KEY_ID=...
#     export AWS_SECRET_ACCESS_KEY=...
#
#   Backup /var/lib/duplicity/gpg, it's needed to decrypt your data

# How to restore from this:
# duplicity \
#   --use-agent \
#   --gpg-options '--no-default-keyring --no-tty --batch --homedir=/cfg/pgp/foo' \
#   s3://s3.wasabisys.com/your-backups/foo/bar ./

with lib;

let
  inherit (pkgs) writeText writeShellScriptBin;
  cfg = config.services.duplicity;

  joinFlags = concatMapStringsSep "\n" (s: "  ${s} \\");

  mkBackupService = store: {
    path = with pkgs; [ cfg.package gnupg gawk ];

    unitConfig = {
      StartLimitInterval = 5000;
      StartLimitBurst = 5;
    };

    serviceConfig = {
      # Prevent restart loops, which quickly become costly
      # with cloud providers that will happily let you pay
      # for infinite storage
      Restart = "no";

      # Make sure crypto doesn't hinder normal
      # operations too much on a single-core
      CPUQuota = "${toString cfg.cpuQuota}%";
    };

    script = 
      let
        homedir = "${cfg.stateDir}/gpg";
        connectionOptions = [
          "--use-agent"
          "--num-retries ${toString store.numRetries}"
          "--archive-dir '${cfg.stateDir}/cache'"
          "--name '${store.name}'"
          "--allow-source-mismatch"
          "--encrypt-key \"$FINGERPRINT\""
          "--sign-key \"$FINGERPRINT\""
          "--gpg-options '--no-tty --batch --homedir=\'${homedir}\''"
        ] ++ store.extraArgs;
      in ''
        mkdir -pm=700 '${cfg.stateDir}/env'
        [ -e '${cfg.stateDir}/env/global.sh' ] &&
          source '${cfg.stateDir}/env/global.sh'
        [ -e '${cfg.stateDir}/env/${store.name}.sh' ] &&
          source '${cfg.stateDir}/env/${store.name}'

        if [ ! -d '${homedir}' ]; then
          mkdir -pm=700 '${homedir}' 
          gpg \
            --homedir='${homedir}' \
            --batch \
            --generate-key <<EOD
              %echo Generating GPG key
              %no-protection

              Key-Type: rsa
              Key-Length: 2048

              Key-Usage: cert, encrypt, sign

              Name-Real: ${config.networking.hostName}/${store.name}

              Expire-Date: 0

              %commit
              %echo done
        EOD
        fi

        FINGERPRINT=$(
          gpg \
            --homedir='${homedir}' \
            --list-keys \
            --with-colons |
          awk -F: '/^pub:/ { print $5 }'
        )

        ${store.preHook}

        function post() {
          :; # empty bash functions are invalid
          ${store.postHook}
        }

        trap post EXIT

        duplicity \
          --asynchronous-upload \
          --volsize ${toString store.volSize} \
          --full-if-older-than ${store.expiration} \
          --include-filelist ${writeText "include-filelist"
                                (concatStringsSep "\n" store.include)} \
          --exclude-filelist ${writeText "exclude-filelist"
                                (concatStringsSep "\n" store.exclude)} \
        ${joinFlags connectionOptions}
          ${store.dir} \
          ${store.remote}

        duplicity cleanup \
          --force \
        ${joinFlags connectionOptions}
          ${store.remote}

        duplicity remove-all-but-n-full ${toString store.numFullToKeep} \
        ${joinFlags connectionOptions}
          ${store.remote}
    '';
  };

  mkBackupTimer = store: {
    timerConfig = {
      OnCalendar = store.time;
      Persistent = true;
    };

    wantedBy = [ "timers.target" ];
  };
in {
  # TODO: coexist
  disabledModules = [ "services/backup/duplicity.nix" ];

  options.services.duplicity = with types; {
    enable = mkEnableOption "duplicity";

    package = mkOption {
      type = package;
      default = pkgs.duplicity;
    };

    stateDir = mkOption {
      type = path;
      default = "/var/lib/duplicity";
    };

    cpuQuota = mkOption {
      type = int;
      default = 75;
    };

    stores = mkOption {
      default = {};
      type = attrsOf (submodule ({ name, config, ... }: {
        options = {
          dir = mkOption {
            type = str;
          };

          include = mkOption {
            type = listOf str;
            default = [];
          };

          exclude = mkOption {
            type = listOf str;
            default = [];
          };

          remote = mkOption {
            type = str;
          };

          time = mkOption {
            type = str;
            default = "04:04";
          };

          expiration = mkOption {
            type = str;
            default = "30D";
          };

          numFullToKeep = mkOption {
            type = int;
            default = 3;
          };

          numRetries = mkOption {
            type = int;
            default = 3;
          };

          volSize = mkOption {
            type = int;
            default = 250;
          };

          extraArgs = mkOption {
            type = listOf str;
            default = [];
          };

          preHook = mkOption {
            type = str;
            default = "";
          };

          postHook = mkOption {
            type = str;
            default = "";
          };
        };
      }));
    };
  };

  config = mkIf cfg.enable {
    users.users.duplicity = {
      isSystemUser = true;

      home = cfg.stateDir;
      createHome = true;
    };

    systemd.services =
      mapAttrs'
        (n: v: let store = v // { name = n; }; in
          (nameValuePair "duplicity-${n}" (mkBackupService store)))
        cfg.stores;

    systemd.timers =
      mapAttrs'
        (n: v: let store = v // { name = n; }; in
          (nameValuePair "duplicity-${n}" (mkBackupTimer store)))
        cfg.stores;
  };
}
