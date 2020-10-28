{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.services.mopidy;

  configFile = ".mpdscribble/mpdscribble.conf";

  toMopidyIni = generators.toINI {
    mkKeyValue = key: value:
      let
        quoted = v:
          if hasPrefix " " v || hasSuffix " " v
          then ''"${v}"''
          else v;

        value' =
          if isString value then quoted value
          else toString value;

      in
        if isNull value
        then ""
        else "${key}=${value'}";
  };

  mopidyEnv = pkgs.buildEnv {
    name = "mopidy-with-extensions-${cfg.package.version}";
    paths = closePropagation cfg.extraPackages;
    pathsToLink = [ "/${pkgs.mopidyPackages.python.sitePackages}" ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      makeWrapper ${cfg.package}/bin/mopidy $out/bin/mopidy \
        --prefix PYTHONPATH : $out/${pkgs.mopidyPackages.python.sitePackages}
    '';
  };

in

{
  options = {
    services.mopidy = {
      enable = mkEnableOption "Whether to enable mopidy.";

      package = mkOption {
        type = with types; package;
        default = pkgs.mopidy;
        description = "Package to use for mopidy.";
      };

      extraPackages = mkOption {
        type = with types; listOf package;
        default = [ ];
        example = [ pkgs.mopidy-spotify ];
        description = "Extra packages to use for mopidy, such as plugins.";
      };

      config = mkOption {
        type = with types; attrsOf (attrsOf
          (either str (either int (either bool (either path (either (listOf str)))))));
        default = { };
        example = {
          mpd = {
            hostname = "::";
            port = 6600;
          };

          spotify = {
            username = "myUsername";
            password = "myPassword";
            client_id = "myClientId";
            cleint_secret = "myClientSecret";
          };

          file = {
            enabled = true;
            media_dirs = [ "/home/username/Music" ];
            follow_symlinks = false;
            metadata_timeout = 2000;
          };
        };
      };

      extraConfig = mkOption {
        type = types.lines;
        default = "";
        description = "Extra configuration that will be appended to the end.";
      };
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];
    xdg.configFile."mopidy/mopidy.conf".text =
      toMopidyIni cfg.config + "\n" + cfg.extraConfig;

    systemd.user.services.mopidy = {
      Unit = {
        Description = "mopidy server";
        After = [ "network.target" "sound.target" ];
      };

      Install = {
        WantedBy = [ "default.target" ];
      };

      Service = {
        Type = "simple";
        ExecStart = "${mopidyEnv}/bin/mopidy --config ${config.xdg.configFile."mopidy/mopidy.conf".source}";
        Restart = "on-failure";
      };
    };
  };
}
