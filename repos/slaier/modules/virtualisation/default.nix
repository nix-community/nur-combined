{ pkgs, ... }:
{
  virtualisation.libvirtd = {
    enable = true;
    allowedBridges = [ "br0" ];
  };
  environment.systemPackages = with pkgs; [
    virt-manager
  ];
}
