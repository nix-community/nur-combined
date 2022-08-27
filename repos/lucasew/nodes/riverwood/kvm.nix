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
      enable = lib.mkDefault true;
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

  imports = [
    ({config, ...}: {
      config = lib.mkIf (config.virtualisation.kvmgt.enable) {
        boot = {
          kernelParams = [ "intel_iommu=on" "i915.enable_gvt=1" ];
          kernelModules = [ "kvmgt" "vfio-iommu-type1" "mdev" ];
        };
      };
    })
  ];

  environment.systemPackages = with pkgs; [
    virt-manager
  ];
}
