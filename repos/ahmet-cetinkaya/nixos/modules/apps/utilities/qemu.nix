{pkgs, ...}: let
  defaultNetworkXml = pkgs.writeText "libvirt-default-network.xml" ''
    <network>
      <name>default</name>
      <forward mode='nat'/>
      <bridge name='virbr0' stp='on' delay='0'/>
      <ip address='192.168.122.1' netmask='255.255.255.0'>
        <dhcp>
          <range start='192.168.122.2' end='192.168.122.254'/>
        </dhcp>
      </ip>
    </network>
  '';
in {
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
    virtio-win # Windows guest support and firmware for UEFI virtual machines.
    OVMF
    spice # SPICE display and USB redirection support.
    spice-gtk
  ];

  boot.kernel.sysctl."net.ipv4.ip_forward" = true;
  networking.firewall.trustedInterfaces = [ "virbr0" ];

  # Enabling IPv4 forwarding for libvirt/docker NAT networks causes the
  # kernel to silently disable accept_ra on all interfaces (RFC 4862
  # default: a forwarding host stops listening for Router Advertisements).
  # This breaks IPv6 autoconfiguration on the physical uplink, so force
  # accept_ra back on for eno1 (mode 2 accepts RAs even with forwarding on).
  boot.kernel.sysctl."net.ipv6.conf.eno1.accept_ra" = 2;

  systemd.services.libvirt-network-default = {
    description = "Start libvirt NAT network for QEMU VMs";
    wantedBy = [ "multi-user.target" ];
    after = [ "libvirtd.service" ];
    serviceConfig.Type = "oneshot";
    script = ''
      # Only define if the network doesn't already exist.
      if ! ${pkgs.libvirt}/bin/virsh net-info default >/dev/null 2>&1; then
        ${pkgs.libvirt}/bin/virsh net-define ${defaultNetworkXml}
      fi
      if ! ${pkgs.libvirt}/bin/virsh net-info default | ${pkgs.gnugrep}/bin/grep -q 'Active:.*yes'; then
        ${pkgs.libvirt}/bin/virsh net-start default
      fi
      ${pkgs.libvirt}/bin/virsh net-autostart default
    '';
  };
}
