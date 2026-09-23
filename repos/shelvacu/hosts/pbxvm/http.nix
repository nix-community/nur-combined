{ lib, config, ... }:
let
  cfg = config.vacu.pbx;
in
{
  # The phone would rather not use TFTP at all: before falling back to it, it
  # tries HTTP on port 6970 of the same server, for every file it fetches --
  # SEP<MAC>.cnf.xml, the dial template, the locale files, the .tlv trust lists
  # it will not find, and the firmware images. So serving the same directory over
  # HTTP costs one tiny daemon and takes provisioning from tens of seconds to a
  # couple:
  #
  #   over TFTP: 8 files, ~6.6s apart, ~45s of boot, ~80s to registration
  #   over HTTP: the same 8 files in 7s, ~40s to registration
  #
  # The 6.6s per file is the phone's own doing and nothing to do with the server:
  # every TFTP transfer has its first packet dropped (the phone tries IPv6 first
  # and its own log says `sendto() failed: Address family not supported`) and then
  # waits out a 500ms retransmit timer, and the fetches are serial.
  #
  # atftpd stays on, because TFTP is the fallback and because nothing here is
  # load-bearing enough to want a single path to it.
  #
  # darkhttpd rather than nginx or caddy: this serves three static files, read
  # only, to one handset. It has no config file, the module runs it under a
  # DynamicUser, and that user can read what it needs -- /run/secrets.d is
  # `drwxr-x--x`, so anyone may traverse it to a file sops has left
  # world-readable, which is what the phone's config is (mode 0444, and TFTP
  # hands it to any asker anyway).
  services.darkhttpd = lib.mkIf cfg.httpProvisioning {
    enable = true;
    rootDir = cfg.tftpRoot;
    port = cfg.httpPort;
    # Not 0.0.0.0: the module passes --ipv6 whenever the host has IPv6, and
    # darkhttpd binds one socket. `::` with the kernel's default
    # net.ipv6.bindv6only=0 takes IPv4 as well, arriving v4-mapped -- the same
    # way atftpd already logs the phone as ::ffff:10.78.78.249.
    address = "::";
    # Nothing here benefits from advertising a version to the LAN.
    hideServerId = true;
  };

  networking.firewall.allowedTCPPorts = lib.mkIf cfg.httpProvisioning [ cfg.httpPort ];
}
