{ lib, ... }: with lib; {
  config.documentation.nixos.options.warningsAreErrors = mkDefault true;
}
