{ pkgs, ... }:

let
  # write the custom ipxe script for iscsi boot
  bootScript = pkgs.writeText "boot.ipxe" ''
    #!ipxe

    # get ip address for ipxe environment
    dhcp

    # wait 3 seconds, press ctrl-b to enter shell for debugging
    prompt --key 0x02 --timeout 3000 Press Ctrl-B for the iPXE command line... || goto boot_iscsi
    shell

    :boot_iscsi
    echo Booting from iSCSI target...
    # attach and boot from iscsi. format: iscsi:<ip>::::<iqn>
    sanboot iscsi:192.168.0.20::::iqn.2005-10.org.nixos.ctl:pxe-windows
  '';

  # compile a custom ipxe binary with the script embedded
  customIpxe = pkgs.ipxe.override {
    embedScript = bootScript;
  };
in
{
  # open required ports for proxy dhcp (67, 4011) and tftp (69)
  networking.firewall.allowedUDPPorts = [
    67
    69
    4011
  ];

  services.dnsmasq = {
    enable = true;

    settings = {
      # disable dns server function to prevent conflicts
      port = 0;
    };

    extraConfig = ''
      # enable built-in tftp server
      enable-tftp

      # specify the root directory for tftp files
      tftp-root=/var/lib/tftpboot

      # set proxy dhcp for the subnet 192.168.0.x
      dhcp-range=192.168.0.0,proxy

      # define a boot menu prompt (optional, visible for 3 seconds)
      pxe-prompt="Press F8 for network boot", 3

      # pxe service for modern uefi (type 9 architecture)
      pxe-service=X86-64_EFI, "Boot to iPXE (UEFI)", ipxe.efi

      # pxe service for modern uefi (type 7 architecture, commonly used by some boards)
      pxe-service=BC_EFI, "Boot to iPXE (UEFI)", ipxe.efi
    '';
  };

  # use systemd to automatically create symlinks for the compiled uefi boot file
  systemd.tmpfiles.rules = [
    "d /var/lib/tftpboot 0755 root root - -"
    "L+ /var/lib/tftpboot/ipxe.efi - - - - ${customIpxe}/ipxe.efi"
  ];
}
