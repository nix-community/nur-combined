{ config, pkgs, lib, ... }:

with lib;

let

  yesNo = val: if val then "1" else "0";

  hydra.environment = builtins.removeAttrs config.systemd.services.hydra-init.environment [ "PATH" ];

  cfg = config.ma27.hydra;

  emailCfg = cfg.notifications.email;

  slackCfg = cfg.notifications.slack;

  vhostCfg = cfg.vhost;

  userScript = with builtins; concatStringsSep "\n" (flip mapAttrsToList cfg.users (name: cfg: ''
    set -e
    # creating ${name} if not exists
    result=$(echo "select * from users where username = ${escapeShellArg name};" | psql -U hydra hydra | tac | sed -n '2 p')

    if [ "$result" = "(0 rows)" ]; then
      ${config.services.hydra.package}/bin/hydra-create-user --name ${name} \
        --full-name ${if cfg.fullName != null then cfg.fullName else name} \
        --email-address ${cfg.email} \
        --password ${cfg.initialPassword} ${concatStringsSep " " (map (r: "--role ${r}") cfg.roles)}
    fi
  ''));

in

  {

    options.ma27.hydra = {

      enable = mkEnableOption "Hydra CI";

      maxOutputSize = mkOption {
        type = types.int;

        # https://github.com/NixOS/hydra/blob/4e27796eba97ea2aa82e69d4daf4a67aea74ad49/src/hydra-queue-runner/hydra-queue-runner.cc#L50
        default = 2147483648;
        description = ''
          Customize output for huge build products such as GHC.
        '';

        apply = builtins.toString;
      };

      disallowRestrictedEval = mkEnableOption "Hydra without restricted eval";

      storeUri = mkOption {
        type = types.str;
        example = "local";
        description = ''
          Where Nix should store its build artifacts.
        '';
      };

      uploadLogsToBinaryCache = mkEnableOption
        "Uploading the logs to the binary cache. Can be helpful for `nix log`";

      nixBinaryCache = mkEnableOption "`cache.nixos.org` as binary cache." // { default = true; };

      notifications = {

        email = {

          enable = mkEnableOption "Email notifications for Hydra.";

          enablePostfix = mkEnableOption "`postfix` by default for emails.";

          sender = mkOption {
            type = with types; nullOr str;
            default = null;
            description = ''
              Notification sender for Hydra which submits emails about
              build errors.

              If null, Hydra will use `[username]@[hostname]` as fallback.
            '';
          };

        };

        slack = {

          enable = mkEnableOption "Slack notifications";

          force = mkEnableOption "Forcing notifications for each build";

          jobs = mkOption {
            type = types.str;
            description = ''
              Regex to match the jobname that should be notified.
            '';
          };

          url = mkOption {
            type = types.str;
            description = ''
              URL to a slack webhook.
            '';
          };

        };

      };

      vhost = {

        enableProxy = mkEnableOption "Hydra with `nginx` on HTTP ports.";

        enableSSL = mkEnableOption "Hydra with with SSL on the proxy with ACME enabled.";

        name = mkOption {
          type = types.str;
          example = "hydra.example.com";
          description = ''
            Name of the VHost the Hydra should serve.

            Used by `services.hydra` for the internal server config, the `nginx' proxy if enabled
            and `postfix` if enabled.
          '';
        };

      };

      users = mkOption {
        description = ''
          Add one or more users to the Hydra interface.

          This doesn't provide a default to ensure that at least
          one user is created.
        '';

        type = types.attrsOf (types.submodule {
          options = {
            initialPassword = mkOption {
              type = types.str;
              description = ''
                Initial password for the new user. To be changed immediately!
              '';
            };

            email = mkOption {
              type = types.str;
              description = ''
                Email of the new user. To be used to reset the password and to receive build notifications.
              '';
            };

            roles = mkOption {
              type = with types; listOf (enum [ "admin" "create-projects" "restart-jobs" ]);
              description = ''
                List of roles the user should have.
              '';
            };

            fullName = mkOption {
              type = with types; nullOr str;
              default = null;
              description = ''
                Full name of the new user. If null, the username will be used.
              '';
            };
          };
        });
      };

      signing = {
        enable = mkEnableOption "build product signing" // { default = true; };

        keyDir = mkOption {
          type = types.str;
          default = config.ma27.hydra.vhost.name;
          description = ''
            Where to store the signing keys for build products.
          '';
        };
      };
    };

    config = mkIf cfg.enable {

      services.hydra.enable = true;
      services.hydra.hydraURL = vhostCfg.name;
      services.hydra.notificationSender = emailCfg.sender; # TODO fix!

      services.hydra.extraConfig = ''
        email_notification = ${yesNo emailCfg.enable}

        max_output_size = ${cfg.maxOutputSize}

        store_uri = ${cfg.storeUri}

        upload_logs_to_binary_cache = ${if cfg.uploadLogsToBinaryCache then "true" else "false"}

        ${optionalString slackCfg.enable ''
          <slack>
            jobs = ${slackCfg.jobs}
            force = ${if slackCfg.force then "true" else "false"}
            url = ${slackCfg.url}
          </slack>
        ''}
      '';

      services.postgresql.enable = true;

      services.postfix = mkIf emailCfg.enablePostfix {
        enable = true;
        setSendmail = true;
        domain = mkDefault vhostCfg.name; # overridable with `services.postfix.domain = "your-postfix";
      };

      networking.defaultMailServer = mkIf emailCfg.enable {
        hostName = mkDefault vhostCfg.name;
        domain = mkDefault vhostCfg.name;
        directDelivery = mkDefault false;
      };

      services.nginx.virtualHosts.${vhostCfg.name} = mkIf vhostCfg.enableProxy {
        locations."/".proxyPass = "http://localhost:${builtins.toString config.services.hydra.port}";
        forceSSL = vhostCfg.enableSSL;
        enableACME = vhostCfg.enableSSL;
      };

      systemd.services.hydra-create-users = {
        inherit (hydra) environment;

        wantedBy = [ "multi-user.target" ];
        requires = [ "hydra-init.service" ];
        after = [ "hydra-init.service" ];

        description = "Create users for Hydra.";

        path = with config.services; [ /*hydra.package*/ postgresql.package ];

        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = "yes";
          User = "hydra";
          Group = "hydra";
        };

        script = userScript;
      };

      systemd.services.hydra-create-signing-keys =
        let keyDir = cfg.signing.keyDir; in mkIf cfg.signing.enable {
          inherit (hydra) environment;

          wantedBy = [ "multi-user.target" ];
          requires = [ "hydra-init.service" ];
          after = [ "hydra-init.service" ];

          description = "Create signing keys for Hydra.";

          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = "yes";
          };

          path = with pkgs; [ coreutils config.nix.package ];

          script = ''
            if [ ! -e ~hydra/.signing-key-setup ]; then
              install -d -m 551 /etc/nix/${keyDir}
              nix-store --generate-binary-cache-key ${keyDir} \
                /etc/nix/${keyDir}/secret /etc/nix/${keyDir}/public

              chown -R hydra:hydra /etc/nix/${keyDir}
              chmod 440 /etc/nix/${keyDir}/secret
              chmod 444 /etc/nix/${keyDir}/public

              touch ~hydra/.signing-key-setup
            fi
          '';
        };

      systemd.services.hydra-init.postStart = ''
        if [ ! -d /var/lib/hydra/cache ]; then
          install -d -m 755 /var/lib/hydra/cache
          chown -R hydra-queue-runner:hydra /var/lib/hydra/cache
        fi
      '';

      nixpkgs.overlays = mkIf cfg.disallowRestrictedEval [ (import ../pkgs/hydra/overlay.nix) ];

      # sensitive default. Simple Hydra setups may require just a single
      # build machine.
      nix.buildMachines = [
        {
          hostName = "localhost";
          systems = [ "builtin" ];
          supportedFeatures = ["kvm" "nixos-test" "big-parallel" "benchmark" "local"];
          speedFactor = 1;
          maxJobs = 2;
        }
      ];

      nix.extraOptions = ''
        trusted-users = hydra hydra-evaluator hydra-queue-runner
        auto-optimise-store = true
      '';

      nix.trustedBinaryCaches = mkIf cfg.nixBinaryCache [
        "https://cache.nixos.org/"
      ];

      nix.binaryCachePublicKeys = mkIf cfg.nixBinaryCache [
        "hydra.nixos.org-1:CNHJZBh9K4tP3EKF6FkkgeVYsS3ohTl+oS0Qa8bezVs="
      ];

      nix.autoOptimiseStore = true;

    };

  }
