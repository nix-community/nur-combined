{ config, pkgs, inputs, lib,... }:
let
  mkBoolOpt = default: description: lib.mkOption {
    inherit default;
    inherit description;
    type = lib.types.bool;
    example = true;
  };

  cfg = config.materus.profile.nixpkgs;
in
{
  options.materus.profile.nixpkgs.enable = mkBoolOpt false "Enable materus nixpkgs config";
  options.materus.profile.nixpkgs.enableOverlays = mkBoolOpt (cfg.enable) "Enable materus overlays";

  config.nixpkgs.config = lib.mkIf cfg.enable{
    allowUnfree = lib.mkDefault true;
    joypixels.acceptLicense = lib.mkDefault true;
    firefox.enablePlasmaBrowserIntegration = lib.mkDefault config.services.xserver.desktopManager.plasma5.enable;
  };
  config.nixpkgs.overlays = lib.mkIf cfg.enableOverlays [inputs.emacs-overlay.overlay];
}
