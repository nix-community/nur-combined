{ config, lib, ... }:

let
  inherit (lib)
    types
    mkEnableOption
    mkIf
    mkMerge
    mkOption
    ;
  cfg = config.profile.virtualization;

in
{
  options.profile.virtualization = {
    docker = {
      enable = mkEnableOption "Docker";
      extraPkgs = mkOption {
        default = [ ];
        type = types.listOf types.package;
        description = ''
          List of extra packages to install with Docker
        '';
      };
      dockerGroupMembers = mkOption {
        default = [ ];
        type = types.listOf types.str;
        description = ''
          List of users to add to Docker group
        '';
      };
    };
    podman = {
      enable = mkEnableOption "Podman";
      extraPkgs = mkOption {
        default = [ ];
        type = types.listOf types.package;
        description = ''
          List of extra packages to install with Podman
        '';
      };
    };
    qemu = {
      enable = mkEnableOption "QEMU";
      extraPkgs = mkOption {
        default = [ ];
        type = types.listOf types.package;
        description = ''
          List of extra packages to install with Qemu
        '';
      };
      libvirtdGroupMembers = mkOption {
        default = [ ];
        type = types.listOf types.str;
        description = ''
          List of users to add to libvirtd group
        '';
      };
    };
    virtualbox = {
      enable = mkEnableOption "VirtualBox";
      enableExtensionPack = mkEnableOption "VirtualBox Extension Pack";
      extraPkgs = mkOption {
        default = [ ];
        type = types.listOf types.package;
        description = ''
          List of extra packages to install with VirtualBox
        '';
      };
      vboxusersGroupMembers = mkOption {
        default = [ ];
        type = types.listOf types.str;
        description = ''
          List of users to add to vboxusers group
        '';
      };
    };
    vmware = {
      enable = mkEnableOption "VMWare Workstation (vmware.host)";
      extraPkgs = mkOption {
        default = [ ];
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
      virtualisation = {
        libvirtd.enable = true;
        spiceUSBRedirection.enable = true;
      };
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
