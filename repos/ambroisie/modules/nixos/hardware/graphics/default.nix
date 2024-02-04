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

      amdvlk = lib.mkEnableOption "Use AMDVLK instead of Mesa RADV driver";
    };

    intel = {
      enableKernelModule = lib.my.mkDisableOption "Kernel driver module";
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      hardware.opengl = {
        enable = true;
      };
    }

    # AMD GPU
    (lib.mkIf (cfg.gpuFlavor == "amd") {
      boot.initrd.kernelModules = lib.mkIf cfg.amd.enableKernelModule [ "amdgpu" ];

      hardware.opengl = {
        extraPackages = with pkgs; [
          # OpenCL
          rocmPackages.clr
          rocmPackages.clr.icd
        ]
        ++ lib.optional cfg.amd.amdvlk amdvlk
        ;

        extraPackages32 = with pkgs; [
        ]
        ++ lib.optional cfg.amd.amdvlk driversi686Linux.amdvlk
        ;
      };
    })

    # Intel GPU
    (lib.mkIf (cfg.gpuFlavor == "intel") {
      boot.initrd.kernelModules = lib.mkIf cfg.intel.enableKernelModule [ "i915" ];

      environment.variables = {
        VDPAU_DRIVER = "va_gl";
      };

      hardware.opengl = {
        extraPackages = with pkgs; [
          # Open CL
          intel-compute-runtime

          # VA API
          intel-media-driver
          intel-vaapi-driver
          libvdpau-va-gl
        ];
      };
    })
  ]);
}
