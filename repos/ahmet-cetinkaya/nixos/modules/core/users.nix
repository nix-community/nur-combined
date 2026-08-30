{
  config,
  lib,
  pkgs,
  ...
}: {
  users.users.ac = {
    isNormalUser = true;
    # programs.zsh.enable is declared in modules/apps/utilities/zsh.nix.
    shell = pkgs.zsh;
    extraGroups =
      [
        # networkmanager: enabled in modules/core/network.nix
        "networkmanager"
        # wheel: NixOS administrative access and sudo
        "wheel"
        # docker: required by enabled Docker feature modules
        "docker"
        # video: standard graphics and device access
        "video"
        # libvirtd, kvm: originate from modules/apps/utilities/qemu.nix
        "libvirtd"
        "kvm"
      ]
      # vboxusers: tied to modules/apps/utilities/virtualbox.nix
      ++ lib.optionals config.virtualisation.virtualbox.host.enable ["vboxusers"];
  };
}
