{
  lib,
  config,
  pkgs,
  vaculib,
  inputs,
  ...
}:
let
  cfg = config.vacu.garage;
  socketsDir = "/run/garage-sockets";
  sockets = {
    s3 = "${socketsDir}/s3.sock";
    admin = "${socketsDir}/admin.sock";
  };
in
{
  options.vacu.garage = {
    rpcPort = lib.mkOption { type = lib.types.port; };
    rpcBindAddr = lib.mkOption {
      type = lib.types.str;
      default = "[::]";
    };
    publicIp = lib.mkOption {
      type = lib.types.str;
      default = config.vacu.hosts.${config.vacu.hostName}.primaryIp;
      defaultText = "default text";
    };
    dataDir = lib.mkOption { type = lib.types.path; };
    capacity = lib.mkOption {
      type = lib.types.str;
      default = "2T";
    };
    sockets = vaculib.mkOutOptions sockets;
  };
  config = {
    users.users.garage = {
      isSystemUser = true;
      group = "garage";
    };
    users.groups.garage = { };
    users.groups.garage-sockets = { };
    sops.secrets.garageAdminKey = {
      owner = "garage";
      restartUnits = [ "garage.service" ];
    };
    sops.secrets.garageRpcKey = {
      owner = "garage";
      sopsFile = "${config.vacu.sops.secretsPath}/garage-rpc.key";
      format = "binary";
      restartUnits = [ "garage.service" ];
    };
    services.garage = {
      enable = true;
      package = pkgs.garage_2;
      settings = {
        data_dir = [
          {
            path = cfg.dataDir;
            inherit (cfg) capacity;
          }
        ];
        replication_factor = 3;
        consistency_mode = "consistent";
        db_engine = "lmdb";
        metadata_fsync = true;
        data_fsync = true;
        disable_scrub = lib.mkDefault false; # this is running on zfs, but i like the extra check
        block_ram_buffer_max = lib.mkDefault "16G";
        compression_level = 3;
        rpc_secret_file = config.sops.secrets.garageRpcKey.path;
        rpc_bind_addr = "${cfg.rpcBindAddr}:${toString cfg.rpcPort}";
        rpc_public_addr = "${cfg.publicIp}:${toString cfg.rpcPort}";
        allow_punycode = false;
        s3_api = {
          api_bind_addr = sockets.s3;
          s3_region = "garage";
        };
        admin = {
          api_bind_addr = sockets.admin;
          admin_token_file = config.sops.secrets.garageAdminKey.path;
          metrics_require_token = true;
        };
      };
    };
    systemd.services.garage.serviceConfig = {
      User = "garage";
      Group = "garage";
      DynamicUser = false;
      ReadWritePaths = [
        socketsDir
        "/var/lib/garage"
      ];
      ReadPaths = [
        config.services.garage.settings.rpc_secret_file
        config.services.garage.settings.admin.admin_token_file
      ];
      StateDirectory = lib.mkForce "";
      LimitNOFile = 1073741824;
      SocketBindAllow = [ "tcp:${toString cfg.rpcPort}" ];
      SocketBindDeny = "any";
    };
    networking.firewall.allowedTCPPorts = [ cfg.rpcPort ];
    systemd.tmpfiles.settings."10-whatever" = {
      ${socketsDir}.d = {
        user = "garage";
        group = "garage-sockets";
        mode = vaculib.accessModeStr {
          user = "all";
          group.execute = true;
        };
      };
      "/var/lib/garage".d = {
        user = "garage";
        group = "garage";
        mode = vaculib.accessModeStr { user = "all"; };
      };
    };
  }
  // lib.optionalAttrs (inputs ? impermanence) {
    environment.persistence."/persistent".directories = [
      {
        directory = "/var/lib/garage";
        user = "garage";
        group = "garage";
        mode = vaculib.accessModeStr { user = "all"; };
      }
    ];
  };
}
