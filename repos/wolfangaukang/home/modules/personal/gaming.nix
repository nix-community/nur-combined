{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.defaultajAgordoj.gaming;

in
{
  meta.maintainers = [ wolfangaukang ];

  options.defaultajAgordoj.gaming = {
    enable = mkOption {
      default = false;
      type = types.bool;
      description = ''
        Enables gaming profile on Home-Manager 
      '';
    };
    enableProtontricks = mkOption {
      default = false;
      type = types.bool;
      description = ''
        Enables Protontricks
      '';
    };
    retroarch = {
      enable = mkOption {
        default = false;
        type = types.bool;
        description = ''
          Enables Retroarch 
        '';
      };
      package = mkOption {
        default = pkgs.retroarchFull;
        type = types.package;
        description = ''
          Retroarch package to install
        '';
      };
      coresToLoad = mkOption {
        default = [];
        type = types.listOf types.package;
        description = ''
          Cores to load on Retroarch (recommended when using bare or normal) 
        '';
      };
    };
    extraPkgs = mkOption {
      default = [];
      type = types.listOf types.package;
      description = ''
        List of extra packages to install 
      '';
    };
  };
  
  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.enableProtontricks {
      home.packages = settings.packages.gaming;
    })
    (mkIf cfg.retroarch.enable (mkMerge [
      (mkIf (cfg.retroarch.coresToLoad == [ ]) {
        home.packages = with pkgs; [
          cfg.retroarch.package
        ];
      })
      (mkIf (cfg.retroarch.coresToLoad != [ ]) {
        home.packages = with pkgs; [
          (cfg.retroarch.package.override {
            cores = cfg.retroarch.coresToLoad;
          })
        ];
      })
    ]))
    {
      home.packages = cfg.extraPkgs; 
    }
  ]);
}
