{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.cachyos;
  hasKernels = builtins.hasAttr "cachyosKernels" pkgs;
in {
  options.cachyos = {
    # Master enable switch for the custom CachyOS kernel module.
    # System-level tuning (zram, I/O schedulers, audio, systemd) is handled
    # separately by cachyos-settings-nix via the cachyos.settings.* namespace.
    enable = lib.mkEnableOption "CachyOS kernel selection";

    kernel = {
      # Enable the CachyOS kernel instead of the default NixOS kernel.
      # Provides performance gains via tuned schedulers and compiler optimizations.
      enable = lib.mkOption {
        type = lib.types.bool;
        default = cfg.enable;
        description = "Enable CachyOS kernel (requires nix-cachyos-kernel overlay)";
      };

      # Kernel variant selection based on workload:
      # - latest: General use with EEVDF scheduler (recommended)
      # - lts: Long-term support for stability
      # - bore: Burst-Oriented Response Enhancer (gaming, interactive workloads)
      # - bmq: BitMap Queue scheduler (alternative low-latency)
      # - server: Server-optimized configuration
      # - hardened: Security-focused variant
      # - eevdf: Earliest Eligible Virtual Deadline First scheduler
      # - deckify: Steam Deck optimized
      variant = lib.mkOption {
        type = lib.types.enum [
          "latest"
          "lts"
          "bore"
          "bmq"
          "server"
          "hardened"
          "eevdf"
          "deckify"
        ];
        default = "latest";
        description = "CachyOS kernel variant";
      };

      # LTO (Clang+ThinLTO) provides additional performance via whole-program
      # optimization at the cost of longer build time.
      lto = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Use the LTO (Link Time Optimization) kernel variant";
      };
    };

    # BBRv3 TCP congestion control. Not set by cachyos-settings-nix, so it lives
    # here. Improves throughput on high-latency links (streaming, remote work).
    bbr.enable = lib.mkOption {
      type = lib.types.bool;
      default = cfg.enable;
      description = "Enable BBR TCP congestion control with fq qdisc";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.kernel.enable -> hasKernels;
        message = "cachyos.kernel.enable requires the nix-cachyos-kernel overlay (pkgs.cachyosKernels)";
      }
    ];

    # Fetch pre-built CachyOS kernels from upstream binary cache.
    # Without this, every rebuild compiles the kernel locally.
    nix.settings.extra-substituters = [
      "https://xddxdd.cachix.org"
    ];
    nix.settings.extra-trusted-public-keys = [
      "xddxdd.cachix.org-1:ay1HJyNDYmlSwj5NXQG065C8LfoqqKaTNCyzeixGjf8="
    ];
  };
}
