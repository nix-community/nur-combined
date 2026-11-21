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

  config.services.llama-cpp = mkIf cfg.enable {
    enable = true;
    settings = {
      port = 11434;
      no-ui = true;
      parallel = 1; # Single server slot
      kv-unified = true;
      models-memory-margin = 4096; # Keep 4GiB free
      sleep-idle-seconds = 1800; # Sleep after 30mins of inactivity
      models-preset = pkgs.writeText "models.ini" (readFile ./models.ini);
    };
  };
}
