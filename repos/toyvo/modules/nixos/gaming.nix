{
  config,
  lib,
  pkgs,
  stablePkgs,
  ...
}:
let
  cfg = config.nixcfg.gaming;
in
{
  options.nixcfg.gaming.enable = lib.mkEnableOption "Enable various gaming programs";

  config = lib.mkIf cfg.enable {
    programs = {
      steam = {
        enable = true;
        gamescopeSession.enable = true;
      };
      gamemode.enable = true;
    };
    environment.systemPackages = with pkgs; [
      discord
      heroic
      lutris
      mangohud
      prismlauncher
      protonup-ng
      # cargo-setup-hook exports AWS_LC_SYS_USE_SYSTEM=1, but openssl is not AWS-LC;
      # build the bundled copy of aws-lc instead (needs cmake)
      (gale.overrideAttrs (old: {
        nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ cmake ];
        preBuild = (old.preBuild or "") + ''
          unset AWS_LC_SYS_USE_SYSTEM
        '';
        # libsqlite3-sys links the system sqlite under cargo-setup-hook
        buildInputs = (old.buildInputs or [ ]) ++ [ sqlite ];
        dontUseCmakeConfigure = true;
      }))
      r2modman
      steam
      steamcmd
      (wrapOBS {
        plugins = with obs-studio-plugins; [
          obs-gstreamer
          obs-vaapi
          obs-vkcapture
        ];
      })
    ];
    home-manager.sharedModules = [
      {
        home.sessionVariables.STEAM_EXTRA_COMPAT_TOOLS_PATH = "~/.steam/root/compatibilitytools.d";
      }
    ];
  };
}
