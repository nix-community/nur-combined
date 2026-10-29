{
  config,
  pkgs,
  lib,
  ...
}:

let
  self = import ../. { inherit pkgs; };
  llmAgentsPkgs = (builtins.getFlake "github:numtide/llm-agents.nix").packages.x86_64-linux;

  inherit (lib) mkOption;
  inherit (lib.types) attrsOf listOf str;
  cfg = config.nagy.ai.agent;

  # JSON payload for /etc/agent/config.json. Read by `agent` CLI,
  # which then appends the AGENT_* environment variables to it.
  agentConfig = {
    inherit (cfg) binds robinds;
    # Literal `name=value` entries first, then bare names copied from the
    # host environment. Later entries win in bwrap.
    envs = map (name: "${name}=${cfg.envs.${name}}") (lib.attrNames cfg.envs) ++ cfg.inheritEnvs;
  };
in
{
  options.nagy.ai.agent = {
    binds = mkOption {
      type = listOf str;
      default = [ ];
      example = lib.literalExpression ''
        [ "$HOME/work" ]
      '';
      description = ''
        Writable bind mounts for the agent sandbox.  Each entry is `src` or
        `src=dest`.  A leading `~` expands to `$HOME`.
      '';
    };

    robinds = mkOption {
      type = listOf str;
      default = [ ];
      example = lib.literalExpression ''
        [ "/etc/foo" "/opt/bar=/usr/lib/bar" ]
      '';
      description = ''
        Read-only bind mounts for the agent sandbox.  Same syntax as
        {option}`nagy.ai.agent.binds`.
      '';
    };

    envs = mkOption {
      type = attrsOf str;
      default = { };
      example = {
        RUST_LOG = "debug";
      };
      description = ''
        Environment variables to set to a literal value inside the agent
        sandbox.
      '';
    };

    inheritEnvs = mkOption {
      type = listOf str;
      default = [ ];
      example = [ "DEEPSEEK_API_KEY" ];
      description = ''
        Environment variable names to copy from the host environment into the
        agent sandbox.  Values take effect only when the host variable is set
        and not empty.
      '';
    };
  };

  config = {
    # Written as /etc/agent/config.json.  It is plain JSON, so it carries no
    # secret values unless `envs` names them.
    environment.etc."agent/config.json".text = builtins.toJSON agentConfig;

    environment.systemPackages = [
      llmAgentsPkgs.pi
      # llmAgentsPkgs.omp
      # llmAgentsPkgs.dsh # deepseek harness

      # pkgs.llama-cpp # -vulkan
      # pkgs.aichat
      # self.llm-ttok
    ];

    environment.sessionVariables = {
      PI_TELEMETRY = "0";
      PI_OFFLINE = "1";
      PI_SKIP_VERSION_CHECK = "1";

      # might not be needed with modern deepseek
      PI_HARNESS_CACHE_ENABLED = "0";
      PI_HARNESS_HASHLINES_ENABLED = "0";
      PI_HARNESS_STORMBREAKER_ENABLED = "0";
      # Never used
      PI_HARNESS_PLANMODE_ENABLED = "0";
    };

    # Custom tool `agent` CLI
    nagy.ai.agent = {
      envs = {
        XDG_CACHE_HOME = "/home/user/agent/cache";
        CARGO_TARGET_DIR = "/tmp/cargo-target";
      };
      inheritEnvs = [
        "PI_TELEMETRY"
        "PI_OFFLINE"
        "PI_SKIP_VERSION_CHECK"

        "PI_HARNESS_CACHE_ENABLED"
        "PI_HARNESS_HASHLINES_ENABLED"
        "PI_HARNESS_STORMBREAKER_ENABLED"
        "PI_HARNESS_PLANMODE_ENABLED"

        "DEEPSEEK_API_KEY"
        "OPENROUTER_API_KEY"
      ];
    };
  };
}
