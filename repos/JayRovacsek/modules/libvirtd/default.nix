{ config, pkgs, ... }: {
  virtualisation.libvirtd = {
    onBoot = "start";
    onShutdown = "shutdown";
    enable = true;
    qemu = { runAsRoot = false; };
  };
  security.polkit.enable = true;
  environment.systemPackages = with pkgs; [ virt-manager ];
}
