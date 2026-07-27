{
  config,
  lib,
  inputs,
  pkgs,
  ...
}:

let
  cfg = config.profile.specialisations;

  inherit (lib)
    types
    mdDoc
    mkEnableOption
    mkIf
    mkMerge
    mkOption
    ;

in
{

  options.profile.specialisations = {
    work.simplerisk = {
      enable = mkEnableOption (mdDoc "set up system with the necessary tools for SimpleRisk tasks");
      indicator = mkOption {
        default = false;
        type = types.bool;
        description = ''
          Flag that indicates the specialisation is enabled
        '';
      };
    };
    gaming = {
      enable = mkEnableOption (mdDoc "Sets up system with gaming setup");
      indicator = mkOption {
        default = false;
        type = types.bool;
        description = ''
          Flag that indicates the specialisation is enabled
        '';
      };
      steam = {
        enable = mkOption {
          default = false;
          type = types.bool;
          description = ''
            Enables Steam through NixOS modules
          '';
        };
        enableSteamHardware = mkOption {
          default = false;
          type = types.bool;
          description = ''
            Enables Steam Hardware
          '';
        };
        enableGamescope = mkOption {
          default = false;
          type = types.bool;
          description = ''
            Enables Gamescope session on Steam
          '';
        };
      };
      system.extraPkgs = mkOption {
        default = [ ];
        type = types.listOf types.package;
        description = ''
          List of packages to install on specialisation (system-level)
        '';
      };
    };
  };

  config = mkMerge [
    (mkIf cfg.work.simplerisk.enable {
      assertions = [
        {
          assertion = pkgs.stdenv.hostPlatform.isLinux;
          message = "The SimpleRisk profile only works for Linux";
        }
      ];
      specialisation.simplerisk = {
        inheritParentConfig = true;
        configuration = {
          imports = [ "${inputs.self}/system/profiles/simplerisk.nix" ];
        };
      };
    })
    (mkIf cfg.gaming.enable {
      assertions = [
        {
          assertion = pkgs.stdenv.hostPlatform.isLinux;
          message = "The gaming profile only works for Linux";
        }
      ];
      specialisation.gaming = {
        inheritParentConfig = true;
        configuration = {
          imports = [ "${inputs.self}/system/profiles/gaming.nix" ];
        };
      };
    })
  ];
}
