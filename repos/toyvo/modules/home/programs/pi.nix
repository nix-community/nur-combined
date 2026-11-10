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
    programs.pi-coding-agent = {
      package = inputs.pi.packages.${system}.pi;
      # Shared NixOS lookup server, mirroring programs.opencode.settings.mcp.nixos.
      mcpServers.nixos = {
        command = lib.getExe pkgs.mcp-nixos;
      };

      settings = {
        defaultModel = "muse-spark-1.3-contributor";
        defaultProvider = "opencode-go";
        packages = [
          "git:github.com/obra/superpowers"
        ];
      };

      extraPackages = with pkgs; [
        fd
        ripgrep
      ];

      context = ''
        Always use ripgrep (`rg`) instead of `grep` and `fd` instead of `find` when searching file contents or locating files. Only fall back to `grep`/`find` when absolutely necessary (e.g. `rg`/`fd` are unavailable or unable to express the required query).
      '';
    };

    # auth.json is mutable runtime state for pi (lock files, `/login`
    # saves, availability refresh) and must NOT be a read-only store
    # symlink — that fails every write with EACCES. Seed a real file on
    # first activation instead; pi then owns it. Changing the nix-side
    # `auth` later requires deleting the file (or merging by hand), since
    # overwriting here would clobber tokens pi saved itself.
    home.activation.piCodingAgentAuthSeed = lib.mkIf (cfg.auth != { }) (
      lib.hm.dag.entryAfter [ "linkGeneration" ] ''
        authFile="${cfg.configDir}/auth.json"
        if [ ! -f "$authFile" ]; then
          mkdir -p "$(dirname "$authFile")"
          cp ${jsonFormat.generate "pi-coding-agent-auth.json" cfg.auth} "$authFile"
          chmod 600 "$authFile"
        fi
      ''
    );

    home.file = {
      "${cfg.configDir}/mcp.json" = lib.mkIf (cfg.mcpServers != { }) {
        source = jsonFormat.generate "pi-coding-agent-mcp.json" {
          mcpServers = cfg.mcpServers;
        };
      };
    };
  };
}
