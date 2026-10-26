{
  inputs,
  hostConfig,
  lib,
  ...
}:
let
  sshPolicy = import ../../lib/ssh-policy.nix;
  # Resolve imports without depending on the module system's pkgs argument.
  patchPkgs = inputs.nixpkgs.legacyPackages.${hostConfig.device.system};
  nixMineralSource = patchPkgs.applyPatches {
    name = "nix-mineral-initrd-compat";
    src = inputs.nix-mineral;
    patches = [
      # Drop once a release includes https://github.com/cynicsketch/nix-mineral/pull/244.
      (patchPkgs.fetchpatch2 {
        url = "https://github.com/cynicsketch/nix-mineral/commit/11acd9af1e7e6ed18b6f87452b51945306539c3f.patch?full_index=1";
        hash = "sha256-TwZ89X0WA6m5PEMrWqLqKPCxm8ISICSqopsliZ41gIY=";
      })
    ];
  };
in
{
  imports = [
    (inputs.nix-mineral.lib.importModule "${nixMineralSource}/nix-mineral.nix" { })
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
      kernel = {
        load-kernel-modules = true; # enable runtime kernel module loading
      };

      network = {
        bluetooth-kmodules = true;
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
