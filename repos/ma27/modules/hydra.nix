{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.ma27.hydra;
in
{
  options.ma27.hydra = {
    enable = mkEnableOption "My Hydra";

    architectures = mkOption {
      example = [ "x86_64-linux" ];
      type = types.listOf types.str;
      description = "Support architecutres for our Hydra";
    };

    extraConfig = mkOption {
      default = {};
      type = types.attrs;
      description = "Extra config for Hydra CI";
    };

    vhost = mkOption {
      example = "hydra.example.org";
      type = types.str;
      description = "VHost for Hydra CI";
    };

    enableNginx = mkEnableOption "Nginx for Hydra" // { default = true; };

    enableSSL = mkOption {
      default = true;
      type = types.bool;
      description = "Whether to configure nginx host with SSL or not.";
    };

    email = mkOption {
      example = "admin@example.org";
      type = types.str;
      description = "Cert owner email";
    };

    initialPassword = mkOption {
      type = types.str;
      description = "Initial password of the admin user";
    };

    keyDir = mkOption {
      type = types.str;
      description = "Key dir for Hydra artifacts";
    };

    disallowRestrictedEval = mkEnableOption "restricted evaluation on Hydra" // { default = true; };
  };

  config = mkIf cfg.enable {
    nix.buildMachines = [
      {
        hostName = "localhost";
        systems = [ "builtin" ] ++ cfg.architectures;
        supportedFeatures = ["kvm" "nixos-test" "big-parallel" "benchmark" "local"];
        speedFactor = 1;
        maxJobs = 2;
      }
    ];

    services.postfix = {
      enable = true;
      setSendmail = true;
    };

    services.postgresql = {
      enable = true;
      package = pkgs.postgresql;
    };

    services.hydra = {
      enable = true;
      hydraURL = cfg.vhost;
      extraConfig = ''
        store_uri = file:///var/lib/hydra/cache?secret_key=/etc/nix/${cfg.keyDir}/secret
        max_output_size = 4294967296
      '';
    } // cfg.extraConfig;

    services.nginx.virtualHosts.${cfg.vhost} = mkIf cfg.enableNginx {
      forceSSL = cfg.enableSSL;
      enableACME = cfg.enableSSL;
      locations."/".proxyPass = "http://localhost:3000";
    };

    security.acme.certs.${cfg.vhost} = mkIf cfg.enableSSL {
      inherit (cfg) email;
    };

    systemd.services.hydra-manual-setup = {
      description = "Create Admin User for Hydra";
      serviceConfig.Type = "oneshot";
      serviceConfig.RemainAfterExit = true;
      wantedBy = [ "multi-user.target" ];
      requires = [ "hydra-init.service" ];
      after = [ "hydra-init.service" ];
      environment = builtins.removeAttrs config.systemd.services.hydra-init.environment [ "PATH" ];
      script = ''
        if [ ! -e ~hydra/.setup-is-complete ]; then
          # create admin user (remember to change the password)
          /run/current-system/sw/bin/hydra-create-user admin --full-name 'admin' --email-address '${cfg.email}' --password ${cfg.initialPassword} --role admin
          # create signing keys
          /run/current-system/sw/bin/install -d -m 551 /etc/nix/${cfg.keyDir}
          /run/current-system/sw/bin/nix-store --generate-binary-cache-key ${cfg.keyDir} /etc/nix/${cfg.keyDir}/secret /etc/nix/${cfg.keyDir}/public
          /run/current-system/sw/bin/chown -R hydra:hydra /etc/nix/${cfg.keyDir}
          /run/current-system/sw/bin/chmod 440 /etc/nix/${cfg.keyDir}/secret
          /run/current-system/sw/bin/chmod 444 /etc/nix/${cfg.keyDir}/public
          # create cache
          /run/current-system/sw/bin/install -d -m 755 /var/lib/hydra/cache
          /run/current-system/sw/bin/chown -R hydra-queue-runner:hydra /var/lib/hydra/cache
          # done
          touch ~hydra/.setup-is-complete
        fi
      '';
    };

    nix.gc = {
      automatic = true;
      dates = "15 3 * * *";
    };

    nix.extraOptions = ''
      trusted-users = hydra hydra-evaluator hydra-queue-runner
      auto-optimise-store = true
    '';

    nix.trustedBinaryCaches = [
      "https://cache.nixos.org/"
    ];

    nix.binaryCachePublicKeys = [
      "hydra.nixos.org-1:CNHJZBh9K4tP3EKF6FkkgeVYsS3ohTl+oS0Qa8bezVs="
    ];

    nixpkgs.overlays = mkIf cfg.disallowRestrictedEval [ (import ../pkgs/hydra/overlay.nix) ];
  };
}
