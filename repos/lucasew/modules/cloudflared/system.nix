{pkgs, lib, config, ...}:
let
  inherit (lib) mkEnableOption mkIf;
  inherit (pkgs) cloudflared;

  cfg = config.services.cloudflared;
in
{
  options.services.cloudflared = { # TODO: Make it useful
    enable = mkEnableOption "Enable cloudflared daemon";
  };
  config = mkIf cfg.enable {
    environment.systemPackages = [
      cloudflared
    ];
  };
}
