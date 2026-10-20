{ pkgs, ... }:
{
  virtualisation.libvirtd.enable = true;
  programs.dconf.enable = true;

  # The upstream template enables --network-veth by default. Do not create a
  # veth for nspawn machines unless a per-machine .nspawn file requests one.
  systemd.services."systemd-nspawn@".serviceConfig.ExecStart = [
    ""
    "${pkgs.systemd}/bin/systemd-nspawn --quiet --keep-unit --boot --link-journal=try-guest -U --settings=override --machine=%i"
  ];

  environment.systemPackages = with pkgs; [
    virt-manager
    virtiofsd
    #qemu
    #qemu_kvm
    #guestfs-tools
  ];
}
