{ lib, ... }:

let
  inherit (lib) mkEnableOption;
in

{
  # Other modules use this option for Plasma integration
  options.abszero.services.desktopManager.plasma6.enable = mkEnableOption "the next generation desktop for Linux";
}
