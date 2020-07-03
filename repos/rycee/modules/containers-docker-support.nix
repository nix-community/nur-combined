# This module adds optional support for running Docker containers
# within the NixOS container. The configuration follows the
# description at
#
#   https://wiki.archlinux.org/index.php?title=Systemd-nspawn&oldid=594617#Run_docker_in_systemd-nspawn

{ config, lib, ... }:

with lib;

let

  cfgContainers = filterAttrs (n: v: v.enableDockerSupport) config.containers;

  containerNames = attrNames cfgContainers;

  containerModule = { config, ... }: {
    options.enableDockerSupport = mkEnableOption "" // {
      description = ''
        Whether support for the Docker daemon should be added to
        this declarative container. Note, this will disable a number
        of important isolation features of this container and should
        only be enabled if you fully trust the container to access
        your system as a whole.
      '';
    };

    config = mkIf config.enableDockerSupport {
      bindMounts = {
        "/sys/fs/cgroup" = {
          hostPath = "/sys/fs/cgroup";
          isReadOnly = false;
        };
      };
      additionalCapabilities = [ "all" "CAP_SYS_ADMIN" ];
      extraFlags =
        map (sc: "--system-call-filter=${sc}") [ "add_key" "keyctl" ];
    };
  };

in {
  options = {
    containers =
      mkOption { type = types.attrsOf (types.submodule containerModule); };
  };

  config = mkIf (cfgContainers != [ ]) {
    environment.etc = foldl' (a: b: a // b) { }
      (map (n: { "containers/${n}.conf".text = "SYSTEMD_NSPAWN_USE_CGNS=0"; })
        containerNames);
  };
}
