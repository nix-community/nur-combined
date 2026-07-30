{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (builtins) readFile;
  inherit (lib) mkEnableOption mkIf;
  cfg = config.abszero.services.llama-cpp;
in

{
  options.abszero.services.llama-cpp.enable = mkEnableOption "local LLM runner";

  config = mkIf cfg.enable {
    services.llama-cpp = {
      enable = true;
      package = pkgs.llama-cpp-rocm;
      settings = {
        port = 11434;
        no-ui = true;
        models-preset = pkgs.writeText "models.ini" (readFile ./models.ini);
      };
    };
    # Use unsloth's qwen chat template which auto merges messages and fixes tool calling
    environment.etc."unsloth-qwen3.6.jinja".source = ./unsloth-qwen3.6.jinja;
  };
}
