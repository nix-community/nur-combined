{
  inputs,
  hostConfig,
  lib,
  ...
}:
{
  imports = [
    inputs.nix-mineral.nixosModules.nix-mineral
  ];

  boot = {
    # kernelPackages = pkgs.linuxPackagesFor pkgs.linuxKernel.kernels.linux_hardened;

    # Enable unprivileged user namespaces (kernel-level risk)
    # for chromium based apps, flatpacks, and steam sandboxing
    kernel.sysctl = lib.optionalAttrs (hostConfig.isGraphical && hostConfig.isLinux) {
      "kernel.unprivileged_userns_clone" = lib.mkForce 1;
      # "kernel.yama.ptrace_scope" = lib.mkOverride 10 1;
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
        # cpu-mitigations = "smt-on"; # performance
        # pti = false; # performance
      };

      misc.nix-wheel = false;
      # network.ip-forwarding = true;
      system.multilib = true; # 32-bit
      # system.proc-mem-force = "ptrace";
      system.yama = "relaxed";
    };

    extras = {
      network = {
        bluetooth-kmodules = true;
        tcp-window-scaling = true;
      };

      misc = {
        doas-sudo-wrapper = false;
        replace-sudo-with-doas = false;
        usbguard = {
          enable = false;
          # gnome-integration = true;
        };
      };

      system = {
        lock-root = false;
        unprivileged-userns = true;
        zram = true;
      };
    };
  };

  # Client side SSH configuration
  programs.ssh = {
    ciphers = [
      "aes256-gcm@openssh.com"
      "aes256-ctr,aes192-ctr"
      "aes128-ctr"
      "aes128-gcm@openssh.com"
      "chacha20-poly1305@openssh.com" # ?
    ];
    hostKeyAlgorithms = [
      "ssh-ed25519"
      "ssh-ed25519-cert-v01@openssh.com"
      "sk-ssh-ed25519@openssh.com"
      "sk-ssh-ed25519-cert-v01@openssh.com"
      "rsa-sha2-512"
      "rsa-sha2-512-cert-v01@openssh.com"
      "rsa-sha2-256"
      "rsa-sha2-256-cert-v01@openssh.com"
    ];
    kexAlgorithms = [
      "curve25519-sha256"
      "curve25519-sha256@libssh.org"
      "diffie-hellman-group16-sha512"
      "diffie-hellman-group18-sha512"
      "sntrup761x25519-sha512@openssh.com"
    ];
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
    macs = [
      # "hmac-sha2-512" # ?
      "hmac-sha2-512-etm@openssh.com"
      "hmac-sha2-256-etm@openssh.com"
      "umac-128-etm@openssh.com"
    ];
  };
}
