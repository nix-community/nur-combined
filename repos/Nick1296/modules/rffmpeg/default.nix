{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.rffmpeg;
  configFile = (
    pkgs.writeTextFile {
      name = cfg.settingsFile;
      text = (lib.generators.toYaml { } cfg.settings);
      executable = false;
      destination = cfg.settingsPath;
    }
  );
in
{
  options.services.rffmpeg = {
    enable = mkEnableOption "rffmpeg: remote SSH FFmpeg wrapper tool";

    package = mkPackageOption pkgs "rffmpeg" { };

    settingsDir = mkOption {
      type = types.path;
      default = "/etc/rffmpeg/";
      description = "The directory where rffmpeg will look for the settings file.";
    };

    settingsFile = mkOption {
      type = types.str;
      default = "rffmpeg.yml";
      description = "The filename of the rffmpeg settings file.";
    };

    settings = mkOption {
      type = pkgs.formats.yaml.type;
      default = { };
      description = ''
        Configuration for rffmpeg written as a Nix attribute set.
        Check https://github.com/joshuaboniface/rffmpeg/ for all the options
      '';
      example = literalExpression ''
        rffmpeg= {
             # Directory configuration
             directories = {
                 # Persistent directory to store state database.
                 state = "/var/lib/rffmpeg";

                 # Temporary directory to store SSH persistence sockets.
                 persist = "/run/shm";

                 # The user who should own the state directory and database.
                 # This should normally be the user who normally runs rffmpeg commands (i.e. the media
                 # server service user).
                 owner = "jellyfin";

                 # The group who should own the state directory and database (an administrative group).
                 # Use this group to control who is able to run "rffmpeg" management commands; users in
                 # this group will have unlimited access to the tool to add/remove hosts, view status, etc.
                 group = "sudo";
             };
         };
      '';
    };
  };

  config = mkIf cfg.enable {

    #export rffmpeg and the generated config
    environment.systemPackages = [
      (cfg.package.override { rffmpeg_config = "${cfg.settingsPath}/${cfg.settingsFile}"; })
    ]
    ++ lib.optional (cfg.settings != { }) configFile;
  };
}
