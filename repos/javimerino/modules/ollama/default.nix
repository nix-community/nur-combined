{ config, lib, pkgs, ... }:

let cfg = config.services.ollama;
in {
  options.services.ollama = {
    enable = lib.mkEnableOption "ollama systemd service";
    package = lib.mkPackageOption pkgs "ollama" { };
  };

  config = lib.mkIf cfg.enable {
    systemd.user.services.ollama = {
      Unit.Description = "ollama server";
      Service = {
        Type = "exec";
        ExecStart = "${cfg.package}/bin/ollama serve";
        Restart = "on-failure";
      };
      Install.WantedBy = [ "default.target" ];
    };
  };
}
