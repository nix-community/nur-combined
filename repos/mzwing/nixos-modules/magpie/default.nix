moduleArgs @ {
  config,
  lib,
  pkgs,
  utils,
  ...
}: let
  cfg = config.services.magpie;
  serviceLib = import ../../internal/system-service {
    inherit lib pkgs;
    systemdUtils = utils;
  };
  magpie = import ../../modules/magpie (moduleArgs // {inherit serviceLib;});
in {
  options.services.magpie =
    magpie.options
    // {
      package = lib.mkOption {
        type = lib.types.package;
        example = lib.literalExpression "pkgs.nur.repos.xyenon.magpie";
        description = "magpie package. It is installed system-wide for the CLI and run by the service.";
      };

      user = lib.mkOption {
        type = lib.types.str;
        example = "alice";
        description = "Existing user the gateway runs as. magpie keeps its state in this user's home and reads the agents' sign-ins there.";
      };
    };

  config = lib.mkIf cfg.enable (serviceLib.mkNixos (magpie.mkService {
    executable = lib.getExe cfg.package;
    packages = [cfg.package];

    account = {
      logicalName = "magpie";
      manage = false;
      nixos = {
        userName = cfg.user;
        groupName = config.users.users.${cfg.user}.group;
      };
    };

    nixos = {
      wants = ["network-online.target"];
      after = ["network-online.target"];
    };
  }));
}
