{ config, lib, ... }:

let
  inherit (lib) mkEnableOption mkIf mkMerge;
  cfg = config.abszero.programs.crush;
in

{
  options.abszero.programs.crush.enable = mkEnableOption "terminal AI agent";

  config.programs.crush = mkIf cfg.enable {
    enable = true;
    settings = {
      providers = mkMerge [
        (mkIf config.services.ollama.enable {
          ollama = {
            name = "Ollama";
            type = "openai-compat";
            base_url = "http://localhost:${toString config.services.ollama.port}/v1";
            models = [
              {
                name = "Gemma 4 31B";
                id = "gemma4:31b";
                context_window = 64000;
                default_max_tokens = 6400;
              }
              {
                name = "gpt-oss 120B Derestricted";
                id = "gpt-oss-120b-Derestricted:latest";
                context_window = 64000;
                default_max_tokens = 6400;
              }
            ];
          };
        })
        (mkIf config.services.llama-cpp.enable {
          llama-cpp = {
            name = "llama-cpp";
            type = "openai-compat";
            base_url = "http://localhost:${toString config.services.llama-cpp.settings.port}/v1";
            models = [
              {
                name = "Qwen 3.6 27B";
                id = "qwen3.6-27b";
                context_window = 64000;
                default_max_tokens = 6400;
              }
              {
                name = "Qwen 3.6 35B A3B";
                id = "qwen3.6-35b-a3b";
                context_window = 48000;
                default_max_tokens = 4800;
              }
            ];
          };
        })
      ];
      mcp = {
        context7 = {
          type = "http";
          url = "https://mcp.context7.com/mcp";
          headers.CONTEXT7_API_KEY = "$CONTEXT7_API_KEY";
        };
        firecrawl = {
          type = "http";
          url = "https://mcp.firecrawl.dev/$FIRECRAWL_API_KEY/v2/mcp";
        };
      };
      lsp = {
        nix.command = "nixd";
      };
      options = {
        # Remove attribution in commit and PR
        attribution.generated_with = false;
      };
    };
  };
}
