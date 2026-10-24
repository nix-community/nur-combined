{
  pkgs,
  nixosModules,
  ...
}:

{
  imports = with nixosModules; [
    profiles.core
    display.default
  ];

  powerManagement = {
    enable = true;
    # TLP owns the tunables; PowerTOP remains installed for diagnostics.
    powertop.enable = false;
  };

  services = {
    upower.enable = true;
    # https://linrunner.de/tlp/
    tlp = {
      enable = true;
      settings = {
        # AC/BAT/SAV settings map to TLP's performance/balanced/power-saver profiles.
        # Restore the power-source profile when plugging or unplugging the charger.
        TLP_AUTO_SWITCH = 1;
        TLP_PROFILE_AC = "PRF";
        TLP_PROFILE_BAT = "BAL";

        # If hot on AC, set TLP_AUTO_SWITCH above to 0 and enable:
        # TLP_PROFILE_DEFAULT = "BAL";

        CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
        CPU_ENERGY_PERF_POLICY_ON_BAT = "balance_power";
        CPU_ENERGY_PERF_POLICY_ON_SAV = "power";

        CPU_BOOST_ON_AC = 1;
        CPU_BOOST_ON_BAT = 1;
        # Select with sudo tlp power-saver; return with sudo tlp balanced.
        CPU_BOOST_ON_SAV = 0;

        # TLP uses firmware profiles where the hardware supports them.
        PLATFORM_PROFILE_ON_AC = "performance";
        PLATFORM_PROFILE_ON_BAT = "balanced";
        PLATFORM_PROFILE_ON_SAV = "low-power";
      };
    };
  };

  hardware.graphics.enable = true;
  environment.systemPackages = with pkgs; [
    acpi
    powertop
  ];
}
