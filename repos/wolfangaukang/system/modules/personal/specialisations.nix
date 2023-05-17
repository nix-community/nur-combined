{ config, lib, pkgs, inputs, ... }:

with lib;
let
  cfg = config.profile.specialisations;
  docker_cfg = config.virtualisation.docker;
  podman_cfg = config.virtualisation.podman;
  qemu_cfg = config.virtualisation.libvirtd;
  vbox_cfg = config.virtualisation.virtualbox;
  vmware_cfg = config.virtualisation.vmware;

  inherit (inputs) self;

in
{
  meta.maintainers = [ wolfangaukang ];

  options.profile.specialisations = {
    work.simplerisk = {
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
    (mkIf cfg.work.simplerisk.enable {
      specialisation.simplerisk = {
        inheritParentConfig = true;
        configuration = (import "${self}/system/profiles/specialisations/simplerisk.nix" { inherit pkgs lib; });
      };
    })
  ];
}

