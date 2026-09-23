{
  config,
  lib,
  pkgs,
  ...
}:
let
  jsonFormat = pkgs.formats.json { };
  cfg = config.programs.pi-coding-agent;
in
{
  options.programs.pi-coding-agent.auth = lib.mkOption {
    type = jsonFormat.type;
    default = { };
    description = "Authentication credentials for the PI coding agent.";
  };

  config = lib.mkIf cfg.enable {
    home.file."${cfg.configDir}/auth.json" = lib.mkIf (cfg.auth != { }) {
      source = jsonFormat.generate "pi-coding-agent-auth.json" cfg.auth;
    };
  };
}
