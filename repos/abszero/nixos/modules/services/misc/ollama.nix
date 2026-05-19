{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.abszero.services.ollama;
in

{
  options.abszero.services.ollama.enable = mkEnableOption "local LLM runner";

  config.services.ollama = mkIf cfg.enable {
    enable = true;
    package = pkgs.ollama-vulkan;
    loadModels = [ "gemma4:31b" ];
  };
}
