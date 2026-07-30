{ config, lib, ... }:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.abszero.services.sillytavern;
  stCfg = config.services.sillytavern;
in

{
  options.abszero.services.sillytavern.enable = mkEnableOption "sillytavern LLM frontend";

  config.services = mkIf cfg.enable {
    sillytavern = {
      enable = true;
      whitelist = false;
      configFile = "${stCfg.package}/lib/node_modules/sillytavern/default/config.yaml";
    };
    tailscale.serve.services.sillytavern.endpoints."tcp:80" = "http://127.0.0.1:${
      toString (if stCfg.port != null then stCfg.port else 8000)
    }";
  };
}
