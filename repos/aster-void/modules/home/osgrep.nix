{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.programs.osgrep;
  osgrepPackage = import ../../packages/osgrep {inherit pkgs;};
in {
  _class = "homeManager";

  options.programs.osgrep = {
    enable = lib.mkEnableOption "osgrep semantic code search";
    package = lib.mkOption {
      type = lib.types.package;
      default = osgrepPackage;
      description = "The osgrep package to use";
    };
    enableClaudeCodeIntegration = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable Claude Code integration with automatic osgrep serve management";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [cfg.package];

    home.activation.installOsgrepClaudePlugin = lib.mkIf cfg.enableClaudeCodeIntegration (
      lib.hm.dag.entryAfter ["writeBoundary"] ''
        # Install osgrep Claude Code plugin
        if command -v claude >/dev/null 2>&1; then
          $DRY_RUN_CMD ${cfg.package}/bin/osgrep install-claude-code
        fi
      ''
    );
  };
}
