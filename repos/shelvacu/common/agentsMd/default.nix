{
  config,
  pkgs,
  lib,
  vacuModuleType,
  ...
}:
let
  inherit (lib) mkOption types;
  cfg = config.vacu.agentsMd;
  deploy = pkgs.makeVacuPythonScript {
    name = "vacu-agents-md-deploy";
    src = ./main.py;
    data = {
      inherit (cfg) contents;
      dst_dir = config.users.users.${cfg.user}.home;
      name = "AGENTS.md";
    };
  };
in
lib.optionalAttrs (vacuModuleType == "nixos") {
  options.vacu.agentsMd = {
    enable = lib.mkEnableOption "create&update a ~/AGENTS.md file";

    user = mkOption {
      type = types.str;
      default = "agent";
    };

    contents = mkOption {
      type = types.lines;
      default = "";
    };
  };

  # This doesn't remove it when enable=false, i'll just do that manually
  config = lib.mkIf cfg.enable {
    system.activationScripts.vacuAgentsMd = {
      deps = [ "users" ];
      text = lib.getExe deploy;
    };
  };
}
