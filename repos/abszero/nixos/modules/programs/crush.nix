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
            ];
          };
        })
      ];
      # Remove attribution in commit and PR
      options.attribution.generated_with = false;
    };
  };
}
