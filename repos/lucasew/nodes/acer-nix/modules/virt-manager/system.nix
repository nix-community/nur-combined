{pkgs, config, ...}:
{
  virtualisation.libvirtd.enable = true;
  environment.systemPackages = with pkgs; [
    virt-manager
  ];
}
