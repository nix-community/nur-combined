{ inputs, pkgs, ... }:
{
  # Intel laptops with active intel_pstate (HWP) and iHD graphics.
  imports = [ inputs.nixos-hardware.nixosModules.common-cpu-intel ];

  services = {
    thermald.enable = true;
    tlp.settings = {
      # Intel HWP scales dynamically with powersave, including turbo when allowed.
      CPU_SCALING_GOVERNOR_ON_AC = "powersave";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      CPU_SCALING_GOVERNOR_ON_SAV = "powersave";

      # Percentage limits use Intel's P-state driver.
      CPU_MIN_PERF_ON_AC = 0;
      CPU_MAX_PERF_ON_AC = 100;
      CPU_MIN_PERF_ON_BAT = 0;
      CPU_MAX_PERF_ON_BAT = 60;
      CPU_MIN_PERF_ON_SAV = 0;
      CPU_MAX_PERF_ON_SAV = 50;
    };
  };

  hardware.graphics.extraPackages = [ pkgs.libvdpau-va-gl ];
  environment.sessionVariables.LIBVA_DRIVER_NAME = "iHD";
}
