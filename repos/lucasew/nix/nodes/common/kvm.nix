{config, global, pkgs, lib, ...}: {
  config = lib.mkIf config.virtualisation.libvirtd.enable {
    users.users.${global.username} = {
      extraGroups = [ "kvm" "libvirtd" ];
    };
    systemd.services.libvirtd.path = with pkgs; [ virtiofsd ];
    environment.systemPackages = with pkgs; [
      virt-manager
    ];
  };
}
