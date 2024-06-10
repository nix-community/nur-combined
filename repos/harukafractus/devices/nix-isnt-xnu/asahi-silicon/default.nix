{ pkgs, asahi, ... }: {
  nixpkgs.overlays = [ asahi.overlays.apple-silicon-overlay ];

  hardware.asahi = {
    withRust = true;
    peripheralFirmwareDirectory = ./.; # Just in case
    #extractPeripheralFirmware = false; # Enable / Disable firmware
    useExperimentalGPUDriver = true; # Purity Problem
    experimentalGPUInstallMode = "replace";
  };
}