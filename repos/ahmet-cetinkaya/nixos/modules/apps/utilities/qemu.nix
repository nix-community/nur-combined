{pkgs, ...}: {
  virtualisation = {
    libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        runAsRoot = true;
        swtpm.enable = true;
      };
    };
    spiceUSBRedirection.enable = true;
  };

  programs.virt-manager.enable = true;

  environment.systemPackages = with pkgs; [
    virt-manager
    virt-viewer
    qemu_kvm
    swtpm
    libvirt
    virtio-win
    OVMF
    spice
    spice-gtk
  ];

  users.extraGroups.libvirtd.members = ["ac"];
  users.extraGroups.kvm.members = ["ac"];

  boot.kernel.sysctl."net.ipv4.ip_forward" = true;
  networking.firewall.trustedInterfaces = [ "virbr0" ];

  systemd.services.libvirt-network-default = {
    description = "Start libvirt NAT network for QEMU VMs";
    wantedBy = [ "multi-user.target" ];
    after = [ "libvirtd.service" ];
    serviceConfig.Type = "oneshot";
    script = ''
      ${pkgs.libvirt}/bin/virsh net-define /home/ac/VMs/QEMU/default-network.xml || true
      ${pkgs.libvirt}/bin/virsh net-start default || true
      ${pkgs.libvirt}/bin/virsh net-autostart default || true
    '';
  };
}
