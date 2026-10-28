{
  config,
  lib,
  pkgs,
  utils,
  ...
}: let
  cfg = config.services.openlist;
  serviceLib = import ../../internal/system-service {
    inherit lib pkgs;
    systemdUtils = utils;
  };
in {
  options.services.openlist = {
    enable = lib.mkEnableOption "OpenList, a file list program over many storages";

    package = lib.mkPackageOption pkgs "openlist" {};

    dataDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/openlist";
      description = "Directory holding OpenList's `config.json`, database and temporary files. OpenList rewrites `config.json` at every start, so it stays here rather than in the Nix store.";
    };

    env = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {};
      example = {
        OPENLIST_SITE_URL = "https://files.example.com";
        OPENLIST_ADDR = "127.0.0.1";
        OPENLIST_HTTP_PORT = "5244";
      };
      description = "Environment variables passed to OpenList. Keys of `config.json` take the `OPENLIST_` prefix and override the file without being written to it. Values are stored in the Nix store.";
    };
  };

  config = lib.mkIf cfg.enable (serviceLib.mkNixos (serviceLib.mkSpec {
    name = "openlist";
    description = "OpenList file list";
    packages = [cfg.package];

    process = {
      executable = lib.getExe cfg.package;
      arguments = [
        "server"
        "--data"
        cfg.dataDir
      ];
      environment = cfg.env;
      workingDirectory = cfg.dataDir;
      # OpenList writes config.json with mode 0777, JWT secret included.
      umask = "0077";
    };

    account = {
      logicalName = "openlist";
      home = cfg.dataDir;
      description = "OpenList service user";
    };

    nixos = {
      wants = ["network-online.target"];
      after = ["network-online.target"];
    };
  }));
}
