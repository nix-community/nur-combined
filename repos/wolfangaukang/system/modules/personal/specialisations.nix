{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  cfg = config.profile.specialisations;
  g_cfg = config.profile.specialisations.gaming;

  inherit (lib)
    types
    mdDoc
    mkEnableOption
    mkForce
    mkIf
    mkMerge
    mkOption
    ;
  notify-send = lib.getExe pkgs.libnotify;

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
      specialisation.simplerisk = {
        inheritParentConfig = true;
        configuration = {
          imports = [ "${inputs.self}/system/profiles/cinnamon.nix" ];
          profile = {
            predicates.unfreePackages = [
              "Oracle_VirtualBox_Extension_Pack"
              "slack"
              "vmware-workstation"
            ];
            specialisations.work.simplerisk.indicator = true;
            virtualization = {
              podman.enable = mkForce false;
              qemu.enable = mkForce false;
              docker = {
                enable = true;
                extraPkgs = with pkgs; [ docker-compose ];
                dockerGroupMembers = [ "bjorn" ];
              };
              virtualbox = {
                enable = true;
                enableExtensionPack = true;
                vboxusersGroupMembers = [ "bjorn" ];
              };
              # vmware.enable = true;
            };
          };
          services.qbittorrent.enable = mkForce false;
        };
      };
    })
    (mkIf cfg.gaming.enable {
      specialisation.gaming = {
        inheritParentConfig = true;
        configuration = {
          environment.systemPackages = g_cfg.system.extraPkgs;
          hardware = {
            graphics.extraPackages32 = [ pkgs.pkgsi686Linux.libva ];
            steam-hardware.enable = g_cfg.steam.enableSteamHardware;
          };
          profile = {
            specialisations.gaming.indicator = true;
            predicates.unfreePackages = [
              "steam"
              "steam-run"
              "steam-original"
              "steam-unwrapped"
            ];
          };
          programs = {
            gamemode = {
              enable = true;
              settings = {
                custom = {
                  start = "${notify-send} 'GameMode started'";
                  end = "${notify-send} 'GameMode ended'";
                };
              };
            };
            steam = {
              enable = cfg.gaming.steam.enable;
              gamescopeSession.enable = cfg.gaming.steam.enableGamescope;
            };
          };
          services.qbittorrent.enable = mkForce false;
        };
      };
    })
  ];
}
