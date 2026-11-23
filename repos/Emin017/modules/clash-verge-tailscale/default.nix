# Home Manager module for Clash Verge Rev on Linux and macOS.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.clash-verge.tailscale;
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
  configDirectory =
    if isDarwin then
      "Library/Application Support/io.github.clash-verge-rev.clash-verge-rev"
    else
      ".local/share/io.github.clash-verge-rev.clash-verge-rev";
in
{
  options.programs.clash-verge.tailscale = {
    enable = lib.mkEnableOption "Tailscale compatibility for Clash Verge Rev";

    tailnet = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "tail4121a.ts.net";
      description = ''
        Tailnet DNS suffix to route through Tailscale. When null, only prevent
        Tailscale domains from receiving Clash Fake-IP addresses. Linux binds
        tailnet traffic to the configured interface; Darwin uses Network
        Extension-compatible rules without an interface binding.
      '';
    };

    interface = lib.mkOption {
      type = lib.types.str;
      default = "tailscale0";
      description = "Linux network interface used when tailnet routing is enabled.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.file."${configDirectory}/profiles/Script.js".source =
      if cfg.tailnet == null then
        ./fake-ip-filter.js
      else if isDarwin then
        pkgs.replaceVars ./darwin-tailscale.js { inherit (cfg) tailnet; }
      else
        pkgs.replaceVars ./tailscale.js {
          inherit (cfg) tailnet;
          tailscaleInterface = cfg.interface;
        };
  };
}
