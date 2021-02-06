{pkgs, config, lib, ...}:
with lib;
let
  cfg = config.services.randomtube;
in
{
  options = {
    services.randomtube = {
      enable = mkEnableOption "Enable RandomTube service";
      when = mkOption {
        type = types.str;
        default = "*-*-* 3:00:00";
        example = literalExample ''"*-*-* 3:00:00" # Run everyday at 3AM'';
        description = "systemd calendar expression about when to trigger the service";
      };
      nice = mkOption {
        type = types.ints.between -20 19;
        default = 19;
        example = 19;
        description = "priority of the running process, small values have higher priorities";
      };
      extraParameters = mkOption {
        type = types.str;
        default = "-ms 60";
        example = "-ms 60";
        description = "parameters passed to randomtube actor";
      };
      package = mkOption {
        type = types.package;
        default = "${pkgs.callPackage "${builtins.fetchGit {
          url = "ssh://git@github.com/lucasew/randomtube.git";
          rev = "d387833072132e0ecba5e53570e04a518edd70ab";
        }}" {}}";
        description = "the randomtube package";
      };
      secretsDotenv = mkOption {
        type = types.path;
        description = "a dotenv like file to get the credentials. To work it must have TELEGRAM_BOT and FETCH_ENDPOINT variables that are mapped respectively as parameters -tg and -fe";
      };
    };
  };
  config = mkIf cfg.enable (let
    binary = "${cfg.package}/bin/randomtube";
    wrappedBinary = pkgs.writeShellScript "randomtube-wrapped" ''
      PATH=$PATH:${pkgs.ffmpeg}/bin
      ${pkgs.dotenv}/bin/dotenv @${cfg.secretsDotenv} -- ${binary} ${cfg.extraParameters}
    '';
  in {
    systemd = {
      services.randomtube = {
        serviceConfig = {
          Type = "oneshot";
          Nice = cfg.nice;
        };
        script = "${wrappedBinary}";
      };
      timers.randomtube = {
        wantedBy = [ "timers.target" ];
        partOf = [ "randomtube.service" ];
        timerConfig.OnCalendar = cfg.when;
      };
    };
  });
}
