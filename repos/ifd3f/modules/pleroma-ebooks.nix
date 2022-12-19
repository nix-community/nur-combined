{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.services.pleroma-ebooks;
  defaultUser = "pleroma-ebooks";
in {
  options.services.pleroma-ebooks.bots = let
    botOpts = types.submodule ({ name, config, ... }: {
      options = {
        user = mkOption {
          type = types.str;
          description = "(Linux) User to run under";
          default = defaultUser;
        };

        group = mkOption {
          type = types.str;
          description = "Group to run under";
          default = defaultUser;
        };

        accessTokenFile = mkOption {
          description = ''
            Path to access token file.

            You can generate one here: https://tools.splat.soy/pleroma-access-token
          '';
          type = types.str;
          default = "/var/lib/secrets/pleroma-ebooks/${name}";
        };

        dbPath = mkOption {
          description = "Path to store the database";
          type = types.str;
          default = "/var/lib/pleroma-ebooks/${name}.db";
        };

        site = mkOption {
          description = "Site to post on";
          type = types.str;
        };

        postOnCalendar = mkOption {
          description =
            "How often to post. See systemd.time(7) for more information about the format.";
          type = types.str;
          default = "hourly";
        };

        extraConfig = mkOption {
          description = ''
            Additional options to add to the config.

            See the default config for more details: https://github.com/ioistired/pleroma-ebooks/blob/master/config.defaults.json
          '';
          type = types.attrs;
          default = {
            cw = null;
            learn_from_cw = false;
            ignored_cws = [ ];
            mention_handling = 1;
            max_thread_length = 15;
            strip_paired_punctuation = false;
            limit_length = false;
            length_lower_limit = 5;
            length_upper_limit = 50;
            overlap_ratio_enabled = false;
            overlap_ratio = 0.7;
            generation_mode = "markov";
          };
        };

        config = mkOption {
          description = ''
            Additional options to add to the config.

            See the default config for more details: https://github.com/ioistired/pleroma-ebooks/blob/master/config.defaults.json
          '';
          type = types.attrs;
        };
      };

      config.config = {
        site = config.site;
        db_path = config.dbPath;
      } // config.extraConfig;
    });

  in mkOption {
    type = with types; attrsOf botOpts;
    default = { };
    description = ''
      Bots to run. If none are defined then this module is disabled.
    '';
  };

  config.systemd = mkMerge (mapAttrsToList (name: botCfg:
    let
      unitName = "pleroma-ebooks-${name}";
      baseConfigJSON = pkgs.writeText "pleroma-ebooks-${name}-config.json"
        (builtins.toJSON botCfg.config);

      generate-pleroma-ebooks-config = pkgs.writeShellApplication {
        name = "generate-pleroma-ebooks-config";
        runtimeInputs = with pkgs; [ coreutils jq ];
        text = with botCfg; ''
          config="$(mktemp)"
          chmod 600 "$config"

          access_token="$(cat ${accessTokenFile})"
          jq --arg token "$access_token" '. + {access_token: $token}' < ${baseConfigJSON} > "$config"

          echo "$config"
        '';
      };
    in {
      services = {
        "${unitName}-config" = {
          description = "Set up ${unitName} required directories";
          environment = { inherit (botCfg) user group accessTokenFile dbPath; };

          script = ''
            mkdir -p "$(dirname "$accessTokenFile")"
            chown -R "$user:$group" "$(dirname "$accessTokenFile")"

            mkdir -p "$(dirname "$dbPath")"
            chown -R "$user:$group" "$(dirname "$dbPath")"
          '';
        };

        "${unitName}" = {
          path = with pkgs; [ generate-pleroma-ebooks-config pleroma-ebooks ];
          unitConfig.ConditionPathExists = botCfg.accessTokenFile;

          script = ''
            cd ${pkgs.pleroma-ebooks}/bin
            config="$(generate-pleroma-ebooks-config)"
            fetch_posts.py -c "$config"
            gen.py -c "$config"
            rm "$config"
          '';

          serviceConfig = {
            User = botCfg.user;
            Group = botCfg.group;
          };
        };
      };

      timers."${unitName}" = {
        wantedBy = [ "network-online.target" ];
        timerConfig.OnCalendar = botCfg.postOnCalendar;
      };
    }) cfg.bots);

  config.users = mkMerge (mapAttrsToList (name: botCfg: {
    users = optionalAttrs (botCfg.user == defaultUser) {
      ${defaultUser} = {
        group = botCfg.group;
        isSystemUser = true;
      };
    };

    groups =
      optionalAttrs (botCfg.group == defaultUser) { ${defaultUser} = { }; };
  }) cfg.bots);
}

