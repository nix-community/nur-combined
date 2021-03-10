{pkgs, lib, config, ...}:
with builtins;
with lib;
let
  cfg = config.services.cloudflared;
in
{
  options.services.cloudflared = { # TODO: Make it useful
    enable = mkEnableOption "Enable cloudflared daemon";
  };
  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      cloudflared
    ];
  };
}
