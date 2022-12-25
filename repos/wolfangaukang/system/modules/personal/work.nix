{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.profile.work;
  docker_cfg = config.virtualisation.docker;
  podman_cfg = config.virtualisation.podman;
  qemu_cfg = config.virtualisation.libvirtd;
  vbox_cfg = config.virtualisation.virtualbox;
  vmware_cfg = config.virtualisation.vmware;

in
{
  meta.maintainers = [ wolfangaukang ];

  options.profile.work = {
    simplerisk = {
      enable = mkOption {
        default = false;
        type = types.bool;
        description = ''
          Sets up system with the necessary tools for SimpleRisk tasks
        '';
      };
    };
  };

  config = mkMerge [
    (mkIf cfg.simplerisk.enable {
      assertions = [
        {
          assertion = !podman_cfg.enable;
          message = "Podman is enabled. Please disable it through `virtualisation.podman.enable`";
        }
        {
          assertion = !qemu_cfg.enable;
          message = "QEMU is enabled. Please disable it through `virtualisation.qemu.enable`";
        }
      ];
      profile.virtualization = {
        docker = {
          enable = true;
          extraPkgs = with pkgs; [ docker-compose ];
          dockerGroupMembers = [ "bjorn" ];
        };
        virtualbox = {
          enable = true;
          enableExtensionPack = true;
          vboxusersGroupMembers = [ "bjorn" ];
        };
        vmware.enable = true;
      };
    })
  ];
}

