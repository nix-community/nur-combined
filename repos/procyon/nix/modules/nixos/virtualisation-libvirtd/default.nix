# SPDX-FileCopyrightText: 2023 Unidealistic Raccoon <procyon@secureninja.maskmy.id>
#
# SPDX-License-Identifier: MIT

{ flake, pkgs, ... }:
{
  services.gvfs.enable = true;

  security.polkit.enable = true;

  programs.virt-manager.enable = true;

  users.extraGroups.libvirtd.members = [ "${flake.config.people.myself}" ];

  virtualisation = {
    spiceUSBRedirection.enable = true;
    libvirtd = {
      enable = true;
      onBoot = "ignore";
      onShutdown = "shutdown";
      qemu = {
        swtpm.enable = true;
        package = pkgs.qemu_kvm;
        ovmf = {
          enable = true;
          packages = with pkgs; [ OVMFFull.fd ];
        };
      };
    };
  };
}
