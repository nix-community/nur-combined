{ config, lib, pkgs, ... }:
let
  cfg = config.my.hardware.graphics;
in
{
  options.my.hardware.graphics = with lib; {
    enable = mkEnableOption "graphics configuration";

    gpuFlavor = mkOption {
      type = with types; nullOr (enum [ "amd" "intel" ]);
      default = null;
      example = "intel";
      description = "Which kind of GPU to install driver for";
    };

    amd = {
      enableKernelModule = lib.my.mkDisableOption "Kernel driver module";
    };

    intel = {
      enableKernelModule = lib.my.mkDisableOption "Kernel driver module";
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      hardware.graphics = {
        enable = true;
      };
    }

    # AMD GPU
    (lib.mkIf (cfg.gpuFlavor == "amd") {
      hardware.amdgpu = {
        initrd.enable = cfg.amd.enableKernelModule;
      };

      hardware.graphics = {
        extraPackages = with pkgs; [
          # OpenCL
          rocmPackages.clr
          rocmPackages.clr.icd
        ];
      };
    })

    # Intel GPU
    (lib.mkIf (cfg.gpuFlavor == "intel") {
      boot.initrd.kernelModules = lib.mkIf cfg.intel.enableKernelModule [ "i915" ];

      environment.variables = {
        VDPAU_DRIVER = "va_gl";
      };

      hardware.graphics = {
        extraPackages = with pkgs; [
          # Open CL
          intel-compute-runtime

          # VA API
          intel-media-driver
          intel-vaapi-driver
          libvdpau-va-gl
        ];

        extraPackages32 = with pkgs.driversi686Linux; [
          # VA API
          intel-media-driver
          intel-vaapi-driver
          libvdpau-va-gl
        ];
      };
    })
  ]);
}
