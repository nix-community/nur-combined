{
  pkgs,
  lib,
  config,
  ...
}:
{
  options.eownerdead.hardening = lib.mkEnableOption (
    lib.mdDoc ''
      NixOS Hardening

      See the (wiki)[https://wiki.nixos.org/wiki/NixOS_Hardening].
    ''
  );

  config = lib.mkIf config.eownerdead.hardening {
    # security.lockKernelModules = true;

    security.protectKernelImage = true;

    # Hide kptrs even for processes with CAP_SYSLOG
    boot.kernel.sysctl."kernel.kptr_restrict" = "2";

    # Disable bpf() JIT (to eliminate spray attacks)
    boot.kernel.sysctl."net.core.bpf_jit_enable" = false;

    # Disable ftrace debugging
    boot.kernel.sysctl."kernel.ftrace_enabled" = false;

    # Disable io_uring, a large source of security vulnerabilities
    # https://security.googleblog.com/2023/06/learnings-from-kctf-vrps-42-linux.html
    # boot.kernel.sysctl."kernel.io_uring_disabled" = 2;

    # Enable strict reverse path filtering (that is, do not attempt to route
    # packets that "obviously" do not belong to the iface's network; dropped
    # packets are logged as martians).
    boot.kernel.sysctl."net.ipv4.conf.all.log_martians" = true;
    boot.kernel.sysctl."net.ipv4.conf.all.rp_filter" = "1";
    boot.kernel.sysctl."net.ipv4.conf.default.log_martians" = true;
    boot.kernel.sysctl."net.ipv4.conf.default.rp_filter" = "1";

    # Ignore broadcast ICMP (mitigate SMURF)
    boot.kernel.sysctl."net.ipv4.icmp_echo_ignore_broadcasts" = true;

    # Ignore incoming ICMP redirects (note: default is needed to ensure that the
    # setting is applied to interfaces added after the sysctls are set)
    boot.kernel.sysctl."net.ipv4.conf.all.accept_redirects" = false;
    boot.kernel.sysctl."net.ipv4.conf.all.secure_redirects" = false;
    boot.kernel.sysctl."net.ipv4.conf.default.accept_redirects" = false;
    boot.kernel.sysctl."net.ipv4.conf.default.secure_redirects" = false;
    boot.kernel.sysctl."net.ipv6.conf.all.accept_redirects" = false;
    boot.kernel.sysctl."net.ipv6.conf.default.accept_redirects" = false;

    # Ignore outgoing ICMP redirects (this is ipv4 only)
    boot.kernel.sysctl."net.ipv4.conf.all.send_redirects" = false;
    boot.kernel.sysctl."net.ipv4.conf.default.send_redirects" = false;

    # security.allowSimultaneousMultithreading = false;

    security.forcePageTableIsolation = true;

    nix.settings.allowed-users = [ "@users" ];

    # security.virtualisation.flushL1DataCache = "always";

    security.apparmor.enable = true;
    security.apparmor.killUnconfinedConfinables = true;
  };
}
