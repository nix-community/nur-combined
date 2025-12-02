{ config, lib, ... }:

let
  inherit (lib) mkIf mkDefault;
  inherit (lib.abszero.modules) mkExternalEnableOption;
  cfg = config.abszero.hardware.framework-desktop-amd-ai-max-300-series;
in

{
  imports = [ ../../../lib/modules/config/abszero.nix ];

  options.abszero.hardware.framework-desktop-amd-ai-max-300-series.enable =
    mkExternalEnableOption config ''
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
