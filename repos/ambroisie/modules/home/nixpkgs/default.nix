{ config, lib, pkgs, ... }:
let
  cfg = config.my.home.nixpkgs;
in
{
  options.my.home.nixpkgs = with lib; {
    enable = mkEnableOption "nixpkgs configuration";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      nixpkgs-review
    ];

    home.sessionVariables = {
      GITHUB_TOKEN = ''$(cat "${config.age.secrets."github/token".path}")'';
      GITHUB_API_TOKEN = ''$(cat "${config.age.secrets."github/token".path}")'';
    };
  };
}
