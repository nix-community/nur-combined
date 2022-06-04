{ lib, pkgs, config, ... }: with lib; let
  cfg = config.services.matrix-synapse.appservices;
  inherit (import ./matrix-common.nix { inherit lib pkgs; }) registrationModule;
  appservices = attrValues cfg;
  enabledAppservices = filter (cfg: cfg.enable) appservices;
  localAppservices = filterAttrs (_: appservice: appservice.enable) config.services.matrix-appservices or { };
  enable = cfg != { };
  appserviceModule = { name, ... }: {
    imports = [ registrationModule ];
    options = {
      enable = mkEnableOption "appservice ${name}" // {
        default = true;
      };
    };
    config = {
      configuration = {
        name = "matrix-synapse-${name}";
        combinedPath = "/run/matrix-synapse/${name}.yaml";
      };
    };
  };
  appserviceType = types.submodule appserviceModule;
in {
  options.services.matrix-synapse.appservices = mkOption {
    type = with types; attrsOf appserviceType;
    default = { };
  };
  config = {
    services.matrix-synapse = {
      settings.app_service_config_files = mkIf enable (map (cfg: cfg.configuration.path) enabledAppservices);
      appservices = mapAttrs (_: appservice: appservice.registration.set) localAppservices;
    };
    systemd.services.matrix-synapse = mkIf (config.services.matrix-synapse.enable && enable) {
      serviceConfig = {
        RuntimeDirectory = [ "matrix-synapse" ];
      };
      preStart = mkMerge (map (appservice: ''
        ${appservice.configuration.out.generate}
      '') enabledAppservices);
    };
  };
}
