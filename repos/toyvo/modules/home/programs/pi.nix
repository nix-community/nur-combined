{
  config,
  lib,
  pkgs,
  stablePkgs,
  inputs,
  system,
  ...
}:
let
  jsonFormat = pkgs.formats.json { };
  cfg = config.programs.pi-coding-agent;
in
{
  options.programs.pi-coding-agent = {
    auth = lib.mkOption {
      type = jsonFormat.type;
      default = { };
      description = "Authentication credentials for the PI coding agent.";
    };

    mcpServers = lib.mkOption {
      type = jsonFormat.type;
      default = { };
      description = ''
        MCP servers for the PI coding agent, written to mcp.json.
        See https://pi.dev/docs/mcp for the server entry format.
      '';
      example = {
        nixos.command = "lib.getExe pkgs.mcp-nixos";
        github = {
          url = "https://api.githubcopilot.com/mcp";
          headers.Authorization = "!echo Bearer $(cat /run/secrets/github_pat)";
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    programs.pi-coding-agent.package = inputs.pi.packages.${system}.pi;
    # Shared NixOS lookup server, mirroring programs.opencode.settings.mcp.nixos.
    # programs.pi-coding-agent.mcpServers.nixos = {
    #   command = lib.getExe stablePkgs.mcp-nixos;
    # };

    home.file = {
      "${cfg.configDir}/auth.json" = lib.mkIf (cfg.auth != { }) {
        source = jsonFormat.generate "pi-coding-agent-auth.json" cfg.auth;
      };
      "${cfg.configDir}/mcp.json" = lib.mkIf (cfg.mcpServers != { }) {
        source = jsonFormat.generate "pi-coding-agent-mcp.json" {
          mcpServers = cfg.mcpServers;
        };
      };
    };
  };
}
