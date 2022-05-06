{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.profile.virtualization;

in
{
  meta.maintainers = [ wolfangaukang ];

  options.profile.virtualization = {
    docker = {
      enable = mkOption {
        default = false;
        type = types.bool;
        description = ''
          Installs Docker
        '';
      };
      extraPkgs = mkOption {
        default = [];
        type = types.listOf types.package;
        description = ''
          List of extra packages to install with Docker
        '';
      };
      dockerGroupMembers = mkOption {
        default = [];
        type = types.listOf types.str;
        description = ''
          List of users to add to Docker group 
        '';
      };
    };
    podman = {
      enable = mkOption {
        default = false;
        type = types.bool;
        description = ''
          Installs Podman 
        '';
      };
      extraPkgs = mkOption {
        default = [];
        type = types.listOf types.package;
        description = ''
          List of extra packages to install with Podman 
        '';
      }; 
    };
    qemu = {
      enable = mkOption {
        default = false;
        type = types.bool;
        description = ''
          Installs Qemu 
        '';
      };
      extraPkgs = mkOption {
        default = [];
        type = types.listOf types.package;
        description = ''
          List of extra packages to install with Qemu 
        '';
      }; 
      libvirtdGroupMembers = mkOption {
        default = [];
        type = types.listOf types.str;
        description = ''
          List of users to add to libvirtd group 
        '';
      };
    };
    virtualbox = {
      enable = mkOption {
        default = false;
        type = types.bool;
        description = ''
          Installs VirtualBox 
        '';
      };
      enableExtensionPack = mkOption {
        default = false;
        type = types.bool;
        description = ''
          Installs VirtualBox Extension Pack
        '';
      };
      extraPkgs = mkOption {
        default = [];
        type = types.listOf types.package;
        description = ''
          List of extra packages to install with VirtualBox
        '';
      }; 
      vboxusersGroupMembers = mkOption {
        default = [];
        type = types.listOf types.str;
        description = ''
          List of users to add to vboxusers group 
        '';
      };
    };
    vmware = {
      enable = mkOption {
        default = false;
        type = types.bool;
        description = ''
          Installs VMWare Workstation (vmware.host)
        '';
      };
      extraPkgs = mkOption {
        default = [];
        type = types.listOf types.package;
        description = ''
          List of extra packages to install with VMWare Workstation 
        '';
      };
    };
  };

  config = mkMerge [
    (mkIf cfg.docker.enable {
      environment.systemPackages = cfg.docker.extraPkgs;
      users.extraGroups.docker.members = cfg.docker.dockerGroupMembers; 
      virtualisation.docker.enable = true;
    })
    (mkIf cfg.podman.enable {
      environment.systemPackages = cfg.podman.extraPkgs;
      virtualisation.podman.enable = true;
    })
    (mkIf cfg.qemu.enable {
      environment.systemPackages = cfg.qemu.extraPkgs;
      users.extraGroups.libvirtd.members = cfg.qemu.libvirtdGroupMembers; 
      virtualisation.libvirtd.enable = true;
    })
    (mkIf cfg.virtualbox.enable {
      environment.systemPackages = cfg.virtualbox.extraPkgs;
      users.extraGroups.vboxusers.members = cfg.virtualbox.vboxusersGroupMembers; 
      virtualisation.virtualbox.host = {
        enable = true;
        enableExtensionPack = mkIf cfg.virtualbox.enableExtensionPack true;
      };
    })
    (mkIf cfg.vmware.enable {
      environment.systemPackages = cfg.vmware.extraPkgs;
      virtualisation.vmware.host.enable = true;
    })
  ];
}

