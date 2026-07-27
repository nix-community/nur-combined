{ lib, options, config, pkgs, ... }: with lib; let
  cfg = config.services.pulseaudio;
  pulseaudio = if options ? services.pulseaudio.extraModules
    then config.services.pulseaudio
    else config.hardware.pulseaudio;
  optsConvert = opts: concatStringsSep " "
    (mapAttrsToList (k: v: "${k}=${optStr false (optConvert false v)}") opts);
  optStr = inner: opt:
    if ! hasInfix " " opt then opt
    else if inner then "'${opt}'"
    else ''"${opt}"'';
  optConvert = inner: opt:
    if isString opt && inner then optStr inner opt
    else if isAttrs opt then concatStringsSep " "
      (mapAttrsToList (k: v: "${k}=${optConvert true v}") opt)
    else if isList opt then concatMapStringsSep "," (optConvert true) opt
    else if opt == true then "1"
    else if opt == false then "0"
    else toString opt;
  optPrimitive = with types; oneOf [ (nullOr str) int bool float ];
  optAttrs = with types; attrsOf optPrimitive;
  optList = with types; listOf optPrimitive;
  optType = with types; oneOf [ optPrimitive optAttrs optList ];
  moduleType = { config, ... }: {
    options = {
      module = mkOption {
        type = types.str;
      };
      opts = mkOption {
        type = types.attrsOf optType;
        default = { };
      };
      configLine = mkOption {
        type = types.str;
        internal = true;
      };
    };
    config.configLine =
      "load-module module-${config.module}"
      + optionalString (config.opts != { }) (" " + optsConvert config.opts);
  };
in {
  options.services.pulseaudio = {
    clearDefaults = mkOption {
      type = types.bool;
      default = false;
    };
    samples = mkOption {
      type = with types; attrsOf path;
      default = { };
    };
    defaults = {
      source = mkOption {
        type = with types; nullOr str;
        default = null;
      };
      sink = mkOption {
        type = with types; nullOr str;
        default = null;
      };
    };
    loadModule = with types; let
      moduleType' = submodule moduleType;
      moduleType'' = coercedTo str (module: { inherit module; }) moduleType';
    in mkOption {
      type = listOf moduleType'';
      default = [ ];
    };
    x11bell = {
      enable = mkEnableOption "x11bell";
      samplePath = mkOption {
        type = types.path;
        default = "${pkgs.sound-theme-freedesktop}/share/sounds/freedesktop/stereo/message.oga";
        defaultText = "\${pkgs.sound-theme-freedesktop}/share/sounds/freedesktop/stereo/message.oga";
      };
      sample = mkOption {
        type = types.str;
        default = "x11-bell";
      };
      display = mkOption {
        type = types.str;
        default = ":0";
      };
    };
    bluetooth = {
      enable = mkEnableOption "pulseaudio bluetooth";
      provider = mkOption {
        type = types.enum [ "auto" "native" "ofono" ];
        default = "native";
      };
    };
  };

  config = let
    serviceConf = {
      extraModules = mkIf cfg.bluetooth.enable [ pkgs.pulseaudio-modules-bt ];
      #package = mkIf cfg.bluetooth.enable pkgs.pulseaudioFull;
    };
    conf = {
      bluetooth.provider = mkIf config.services.ofono.enable (mkDefault "ofono");
      configFile = mkIf cfg.clearDefaults
        (builtins.toFile "default.pa" "");
      loadModule = optional cfg.x11bell.enable {
        module = "x11-bell";
        opts = {
          inherit (cfg.x11bell) sample display;
        };
      } ++ optionals cfg.bluetooth.enable [
        "bluetooth-policy"
        {
          module = "bluetooth-discover";
          opts.headset = cfg.bluetooth.provider;
        }
      ];
      samples = mkIf cfg.x11bell.enable {
        ${cfg.x11bell.sample} = mkDefault cfg.x11bell.samplePath;
      };
      extraConfig = mkMerge (
        mapAttrsToList (samp: path: "load-sample ${samp} ${path}") cfg.samples
        ++ map (mod: mod.configLine) cfg.loadModule
        ++ [
          (mkIf (cfg.defaults.source != null) "set-default-source ${cfg.defaults.source}")
          (mkIf (cfg.defaults.sink != null) "set-default-sink ${cfg.defaults.source}")
        ]
      );
    };
    isNixpkgsStable = lib.versionOlder lib.version "25.05";
  in {
    services.pulseaudio = mkMerge ([
      conf
    ] ++ optional (!isNixpkgsStable) serviceConf);
    hardware.${if isNixpkgsStable then "pulseaudio" else null} = serviceConf;
  };
}
