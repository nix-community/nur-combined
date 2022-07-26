{self, global, lib, pkgs, ...}:
let
  inherit (global) username;
in
{
  users.users.${username} = {
    extraGroups = [ "kvm" "libvirt" ];
  };
  virtualisation = {
    kvmgt = {
      enable = true;
      vgpus = {
        "i91-GVTg_V5_8" = {
          uuid = [
            "130e9604-32a2-4824-9d47-34b3f6e0c857"
          ];
        };
      };
    };
    libvirtd.enable = true;
  };
  environment.systemPackages = with pkgs; [
    virt-manager
  ];
}
