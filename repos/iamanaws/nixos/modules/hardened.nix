{
  inputs,
  hostConfig,
  lib,
  ...
}:
let
  sshPolicy = import ../../lib/ssh-policy.nix;
in
{
  imports = [
    inputs.nix-mineral.nixosModules.nix-mineral
  ];

  boot = {
    # Preload required modules before disabling runtime kernel module loading.
    # Adapt this example to the host's filesystems and firewall.
    # kernelModules = [
    #   # /boot
    #   "vfat"
    #   "nls_cp437"
    #   "nls_iso8859_1"
    #
    #   # Firewall
    #   "nf_tables"
    #   "nft_compat"
    #   "xt_conntrack"
    #   "xt_tcpudp"
    #   "xt_pkttype"
    #   "ipt_rpfilter"
    #   "ip6t_rpfilter"
    # ];

    # Allow unprivileged user namespaces for Chromium, Flatpak and Steam sandboxes.
    # This exposes more kernel attack surface to unprivileged processes.
    kernel.sysctl = lib.optionalAttrs (hostConfig.isGraphical && hostConfig.isLinux) {
      "kernel.unprivileged_userns_clone" = lib.mkForce 1;
    };
  };

  security.sudo.execWheelOnly = true;

  services = {
    resolved = {
      # enable = true;
      # settings.Resolve = {
      #   DNSSEC = "true";
      #   DNSOverTLS = "true";
      # };
    };
  };

  nix-mineral = {
    enable = true;
    preset = [ "maximum" ];

    filesystems.enable = false;

    kernel-modules = {
      load = true; # allow runtime kernel module loading
      disable.bluetooth-related = false; # allow Bluetooth with the maximum preset
    };

    settings = {
      kernel = {
        # pti = false; # performance
      };

      misc.nix-wheel = false;
      # network.ip-forwarding = true;
      system.multilib = true; # 32-bit
      # system.proc-mem-force = "ptrace";
      system.yama = "relaxed"; # kernel.yama.ptrace_scope = 1
    };

    extras = {
      network = {
        tcp-window-scaling = true;
      };

      system = {
        lock-root = false;
      };
    };
  };

  # Client side SSH configuration
  programs.ssh = {
    inherit (sshPolicy) ciphers kexAlgorithms macs;
    hostKeyAlgorithms = sshPolicy.keyAlgorithms;
    pubkeyAcceptedKeyTypes = sshPolicy.keyAlgorithms;
    knownHosts = {
      github-ed25519 = {
        hostNames = [ "github.com" ];
        publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
      };
      gitlab-ed25519 = {
        hostNames = [ "gitlab.com" ];
        publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAfuCHKVTjquxvt6CM6tdG4SLp1Btn/nOeHHE5UOzRdf";
      };
      codeberg-ed25519 = {
        hostNames = [ "codeberg.org" ];
        publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIVIC02vnjFyL+I4RHfvIGNtOgJMe769VTF1VR4EB3ZB";
      };
    };
  };
}
