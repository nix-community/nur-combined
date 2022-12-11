# This module adds optional support for running Docker containers
# within the NixOS container. The configuration follows the
# description at
#
#   https://wiki.archlinux.org/index.php?title=Systemd-nspawn&oldid=756917#Run_docker_in_systemd-nspawn

{ config, lib, ... }:

with lib;

let

  moduleCheck = config._module.check;

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

    config = mkMerge [
      { _module.check = moduleCheck; }
      (mkIf config.enableDockerSupport {
        extraFlags =
          map (sc: "--system-call-filter=${sc}") [ "add_key" "keyctl" "bpf" ];
      })
    ];
  };

in {
  options = {
    containers =
      mkOption { type = types.attrsOf (types.submodule containerModule); };
  };
}
