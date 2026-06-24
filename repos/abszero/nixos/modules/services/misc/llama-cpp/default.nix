{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.abszero.services.llama-cpp;
in

{
  options.abszero.services.llama-cpp.enable = mkEnableOption "local LLM runner";

  config.services.llama-cpp = mkIf cfg.enable {
    enable = true;
    package = pkgs.llama-cpp-rocm;
    settings = {
      port = 11434;
      no-ui = true;
      models-preset = toString ./models.ini;
    };
  };
}
