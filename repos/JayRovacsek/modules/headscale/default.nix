{ config, pkgs, lib, ... }:
let
  meta = import ./meta.nix { inherit config pkgs lib; };
  derpServerStunPort = 3478;
  metricsPort = 9090;
  grpcPort = 50443;
  unstablePackages =
    config.flake.inputs.unstable.outputs.legacyPackages.${pkgs.system};
in {

  imports = [ ./acl.nix ];

  age.secrets = meta.secrets;

  networking.firewall = {
    allowedTCPPorts = [ config.services.headscale.port grpcPort metricsPort ];
    allowedUDPPorts = [ config.services.headscale.port derpServerStunPort ];
  };

  environment.systemPackages = (with pkgs; [ sqlite-interactive ])
    ++ (with unstablePackages; [ headscale ]);

  systemd.services."headscale-autosetup" = {
    inherit (meta) script;

    description = "Automatic configuration of Headscale";

    # make sure we perform actions prior to headscale starting
    before = [ "headscale.service" ];
    wantedBy = [ "headscale.service" ];

    # Required to use nix-shell within our script
    path = with pkgs; [ bash sqlite-interactive ];

    serviceConfig = {
      User = config.services.headscale.user;
      Group = config.services.headscale.group;
      Type = "exec";
    };
  };

  services.headscale = {
    enable = true;
    port = 8080;
    # Required until 0.16 is stabilised
    package = unstablePackages.headscale;
    address = "0.0.0.0";
    serverUrl = "https://headscale.rovacsek.com";

    database = {
      inherit (config.services.headscale) user;
      type = "sqlite3";
      path = "/var/lib/headscale/db.sqlite";
      name = "headscale";
    };

    dns = {
      magicDns = true;
      # Replace this in time with resolved magic DNS address of my DNS resolvers.
      nameservers = [ "192.168.6.4" "192.168.6.2" ];
      domains = [ "rovacsek.com.internal" ];
      baseDomain = "rovacsek.com.internal";
      # More settings for this in services.headscale.settings as they currently aren't mapped in nix module
    };

    ## TODO: Address the below to use my own options.
    # see also: https://github.com/kradalby/dotfiles/blob/bfeb24bf2593103d8e65523863c20daf649ca656/machines/headscale.oracldn/headscale.nix#L45
    derp = {
      # TODO: Remove below once I have paths correctly configured
      # urls = [ ];
      # paths = [ "/etc/headscale/derp-server.json" ];
      updateFrequency = "24h";
      autoUpdate = true;
    };

    # TODO: make this dynamic depending on a search through /etc configs for this system
    aclPolicyFile = "/etc/headscale/acls.json";

    ephemeralNodeInactivityTimeout = "5m";

    # This will override settings that are not exposed as nix module options
    settings = {
      # TODO: move this to agenix
      noise.private_key_path = "/var/lib/headscale/noise_private.key";
      metrics_listen_addr = "127.0.0.1:${builtins.toString metricsPort}";
      grpc_listen_addr = "127.0.0.1:${builtins.toString grpcPort}";
      ip_prefixes = [ "100.64.0.0/10" ];

      # Enable headscale to act as DERP
      derp = {
        server = {
          enabled = true;
          region_id = 999;
          region_code = "rovacsek";
          region_name = "stun.headscale.rovacsek.com";
          stun_listen_addr = "0.0.0.0:${builtins.toString derpServerStunPort}";
        };
      };
    };
  };
}
