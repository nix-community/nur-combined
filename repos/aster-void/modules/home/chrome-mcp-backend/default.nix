# RECOMMENDATION:
# Since this constantly runs a chromium instance in the background,
# it is more battery-friendly to use nixosModules.chrome-devtools-mcp instead of this.
#
# only use this if you either:
# - cannot access system config / don't have nixos
# - need a long-running browser session that outlives MCP server for some reason
{
  pkgs,
  config,
  lib,
  ...
}: {
  options.services.chrome-mcp-backend = with lib; {
    enable = mkEnableOption "chromium instance for chrome devtools mcp backend";
    package = mkOption {
      type = types.package;
      default = pkgs.chromium;
    };

    # flag options
    port = mkOption {
      type = types.port;
      default = 9222;
    };
    headless = mkOption {
      type = types.bool;
      default = true;
      example = false;
    };
    incognito = mkOption {
      type = types.bool;
      default = true;
      example = false;
    };
    extraFlags = mkOption {
      type = with types; listOf str;
      default = [];
    };
    env = mkOption {
      type = with types; attrsOf str;
      default = {};
    };
  };

  config = let
    cfg = config.services.chrome-mcp-backend;
    flags =
      [
        "--remote-debugging-port=${toString cfg.port}"
      ]
      ++ lib.optional cfg.headless "--headless"
      ++ lib.optional cfg.incognito "--incognito"
      ++ cfg.extraFlags;
  in {
    systemd.user = {
      enable = true;
      services.chrome-mcp-backend-chromium = {
        Install = {
          WantedBy = ["default.target"];
        };
        Service = {
          ExecStart = "${lib.getExe cfg.package} ${lib.escapeShellArgs flags}";
        };
      };
    };
  };
}
