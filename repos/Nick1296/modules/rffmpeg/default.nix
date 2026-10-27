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
      name = "rffmpeg.yml";
      text = (lib.generators.toYAML { } cfg.settings);
      executable = false;
      destination = cfg.settingsPath;
    }
  );
  yaml = pkgs.formats.yaml { };
in
{
  options.services.rffmpeg = {
    enable = mkEnableOption "rffmpeg: remote SSH FFmpeg wrapper tool";

    package = mkPackageOption pkgs "rffmpeg" { };

    settingsPath = mkOption {
      type = types.path;
      default = "/etc/rffmpeg/rffmpeg.yml";
      description = "The directory where rffmpeg will look for the settings file.";
    };

    settings = mkOption {
      type = yaml.type;
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
      configFile
      (cfg.package.override { rffmpeg_config = "${configFile}/${cfg.settingsPath}"; })
    ];
    # symlink the file on the system
    system.activationScripts.rffmpegConfig.text = ''
      target=${escapeShellArg cfg.settingsPath}
      mkdir -p -- "$(dirname -- "$target")"
      ln -sfnT -- ${escapeShellArg "${configFile}/${cfg.settingsPath}"} "$target"
    '';
  };
}
