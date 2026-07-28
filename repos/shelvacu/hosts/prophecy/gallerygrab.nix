{ vacuSpecialArgs, pkgs, ... }:
let
  uid = 1069;
  gid = 1069;
  outerPkgs = pkgs;
in
{
  users.users.gallerygrab = {
    inherit uid;
    isSystemUser = true;
    group = "gallerygrab";
  };
  users.groups.gallerygrab = { inherit gid; };
  environment.persistence."/persistent".directories = [ "/var/container-applets" ];
  systemd.tmpfiles.settings.vacu-container-gallerygrab = {
    "/propdata/trip/ffuts/archive/gallerygrab".d = {
      user = "gallerygrab";
      group = "gallerygrab";
    };
    "/var/container-applets/gallerygrab".d = { };
  };
  containers.gallerygrab = {
    privateNetwork = true;
    hostAddress = "192.168.100.28";
    localAddress = "192.168.100.29";

    autoStart = true;
    ephemeral = false;
    restartIfChanged = false;

    bindMounts."/g" = {
      hostPath = "/propdata/trip/ffuts/archive/gallerygrab";
      isReadOnly = false;
    };

    bindMounts."/applets" = {
      hostPath = "/var/container-applets/gallerygrab";
      isReadOnly = true;
    };

    specialArgs = vacuSpecialArgs;

    privateUsers = "pick";

    config =
      {
        lib,
        config,
        vacuRoot,
        ...
      }:
      {
        imports = [ /${vacuRoot}/common ];
        nixpkgs.pkgs = outerPkgs;
        vacu.systemKind = "container";
        system.stateVersion = "24.05";

        networking.firewall.enable = false;
        networking.useHostResolvConf = lib.mkForce false;
        services.resolved.enable = true;

        services.postgresql = {
          enable = true;
          ensureUsers = [
            {
              name = "gallerygrab";
              ensureDBOwnership = true;
            }
          ];
          ensureDatabases = [ "gallerygrab" ];
        };

        environment.systemPackages = [ config.services.postgresql.package ];

        users.users.gallerygrab = {
          inherit uid;
          # isSystemUser = true;
          isNormalUser = true;
          group = "gallerygrab";
          home = "/var/gallerygrab";
          openssh.authorizedKeys.keys = lib.attrValues config.vacu.ssh.authorizedKeys;
        };
        users.groups.gallerygrab = { inherit gid; };

        services.openssh.enable = true;
      };
  };
}
