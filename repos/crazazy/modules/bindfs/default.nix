{ config, lib, ... }:
with lib;
{
  imports = [
    ../users
  ];
  options = {
    homeBinds = mkOption {
      type = with types; listOf str;
      default = [ ];
      description = "Bind mounts in your home folder";
    };
    persistRoot = mkOption {
      type = types.str;
      default = "/nix/persist";
    };
  };
  config = mkIf (config.homeBinds != [ ]) {
    fileSystems = genAttrs (map (loc: "/home/${config.mainUser}/${loc}") config.homeBinds)
      (loc: {
        device = "${config.persistRoot}${loc}";
        fsType = "none";
        options = [ "bind" ];
      });
    systemd.services.fix-home-perms = {
      wantedBy = [ "multi-user.target" ];
      after = map (loc: "${builtins.replaceStrings ["/"] ["-"] loc}.mount") config.homeBinds;
      serviceConfig.Type = "oneshot";
      script = "chown -R ${config.mainUser} /home/${config.mainUser}";
    };
  };
}
