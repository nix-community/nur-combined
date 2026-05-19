{ config, lib, ... }:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.abszero.hardware.framework-desktop-amd-ai-max-300-series;
in

{
  options.abszero.hardware.framework-desktop-amd-ai-max-300-series.enable = mkEnableOption ''
    Framework desktop AMD Ryzen AI Max 300 series configuration complementary to
    `inputs.nixos-hardware.nixosModules.framework-desktop-amd-ai-max-300-series`. Due to the
    nixos-hardware module being effective on import, it's not imported by this module; you have to
    import them yourself
  '';

  config = mkIf cfg.enable {
    hardware = {
      bluetooth.enable = true;
      enableRedistributableFirmware = true;
    };

    services.fwupd.enable = true;
  };
}
