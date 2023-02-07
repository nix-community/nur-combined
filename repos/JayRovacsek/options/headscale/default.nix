{ config, lib, pkgs, ... }:
with lib;
let
  cfg = services.headscale;
  settingsFormat = pkgs.formats.yaml { };
in {
  options.services.headscale = {
    # TODO: make the below a submodule that
    # exposes name, ephemerality and 
    # secretsFile so we can abstract agenix out
    tailnets = mkOption {
      type = with types; listOf str;
      default = [ ];
    };
  };
}
