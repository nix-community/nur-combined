{ config, lib, pkgs, inputs, ... }:

with lib;
let
  cfg = config.profile.specialisations;
  sr_cfg = config.profile.specialisations.work.simplerisk;
  g_cfg = config.profile.specialisations.gaming;
  docker_cfg = config.virtualisation.docker;
  podman_cfg = config.virtualisation.podman;
  qemu_cfg = config.virtualisation.libvirtd;
  vbox_cfg = config.virtualisation.virtualbox;
  vmware_cfg = config.virtualisation.vmware;

  inherit (inputs) self;
  inherit (lib) mkForce;
  inherit (pkgs) retroarch;
  inherit (pkgs.pkgsi686Linux) libva;

in
{
  meta.maintainers = [ wolfangaukang ];

  options.profile.specialisations = {
    work.simplerisk = {
      enable = mkOption {
        default = false;
        type = types.bool;
        description = ''
          Sets up system with the necessary tools for SimpleRisk tasks
        '';
      };
    };
    gaming = {
      enable = mkOption {
        default = false;
        type = types.bool;
        description = ''
          Sets up system with gaming setup
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
      # TODO: Enable setup per user
      home = {
        enable = mkOption {
          default = false;
          type = types.bool;
          description = ''
            Enables home manager per user
          '';
        };
        enableProtontricks = mkOption {
          default = false;
          type = types.bool;
          description = ''
            Installs Protontricks
          '';
        };
        retroarch = {
          enable = mkOption {
            default = false;
            type = types.bool;
            description = ''
              Installs Retroarch
            '';
          };
          package = mkOption {
            default = pkgs.retroarch;
            type = types.package;
            description = ''
              Indicates what retroarch package will be installed
            '';
          };
          coresToLoad = mkOption {
            default = [ ];
            type = types.listOf types.package;
            description = ''
              Cores to load into Retroarch
            '';
          };
        };
        extraPkgs = mkOption {
          default = [ ];
          type = types.listOf types.package;
          description = ''
            List of packages to install on specialisation (home-level)
          '';
        };
      };
    };
  };

  config = mkMerge [
    (mkIf cfg.work.simplerisk.enable {
      specialisation.simplerisk = {
        inheritParentConfig = true;
        configuration = (import "${self}/system/profiles/specialisations/simplerisk.nix" { inherit pkgs lib; });
      };
    })
    (mkIf cfg.gaming.enable {
      specialisation.gaming = {
        inheritParentConfig = true;
        configuration = {
          environment.systemPackages = g_cfg.system.extraPkgs;
          hardware.steam-hardware.enable = g_cfg.steam.enableSteamHardware;
          programs = {
            gamemode = {
              enable = true;
              settings = {
                custom = {
                  start = "${pkgs.libnotify}/bin/notify-send 'GameMode started'";
                  end = "${pkgs.libnotify}/bin/notify-send 'GameMode ended'";
                };
              };
            };
            steam = {
              enable = cfg.gaming.steam.enable;
              gamescopeSession.enable = cfg.gaming.steam.enableGamescope;
            };
          };
          nixpkgs.config.allowUnfreePredicate = (
            pkg: builtins.elem (getName pkg) [ "steam" "steam-original" "steam-runtime" ]
          );
          hardware.opengl = {
            extraPackages32 = [ libva ];
            setLdLibraryPath = true;
          };
          home-manager.users.bjorn.defaultajAgordoj.gaming = {
            enable = g_cfg.home.enable;
            enableProtontricks = g_cfg.home.enableProtontricks;
            retroarch = {
              enable = g_cfg.home.retroarch.enable;
              package = g_cfg.home.retroarch.package;
              coresToLoad = g_cfg.home.retroarch.coresToLoad;
            };
            extraPkgs = g_cfg.home.extraPkgs;
          };
        };
      };
    })
  ];
}

