{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:
{
  imports = [ inputs.nix-index-database.homeModules.nix-index ];

  options.eownerdead.dev.nix.enable =
    lib.mkEnableOption "Enable Nix develop tools";

  config = lib.mkIf config.eownerdead.dev.nix.enable {
    home.packages = with pkgs; [
      nixd
      nixfmt
      statix
      hydra-check
      nix-output-monitor
      comma
      nixpkgs-review
      nix-fast-build
      vulnix
      dix
      nh
    ];

    programs.nix-index = {
      enable = true;
      enableBashIntegration = true;
    };
  };
}
