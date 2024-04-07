{
  config,
  lib,
  pkgs,
  self,
  ...
}:

let
  inherit (lib)
    mkEnableOption
    mkPackageOption
    mkOption
    types
    mkIf
    ;
  cfg = config.services.nixgram;
in

{
  options.services.nixgram = {
    enable = mkEnableOption "nixgram";
    package = mkPackageOption pkgs "nixgram" { };
    environmentFile = mkOption {
      type = types.path;
      example = "/var/run/secrets/nixgram.env";
      default = "/var/run/secrets/nixgram";
      description = "Dotenv file to load with secrets to load before starting nixgram";
    };
    customCommands = mkOption {
      type = types.attrsOf types.str;
      default = { };
      example = {
        echo = ''echo "$@"'';
      };
      description = "Custom extra commands that the bot can handle";
    };
    user = mkOption {
      type = types.str;
      default = "nixgram";
      example = "someone";
      description = "The user to run nixgram as";
    };
    group = mkOption {
      type = types.str;
      default = "nixgram";
      example = "somegroup";
      description = "The group to run nixgram as";
    };
  };
  config = mkIf cfg.enable {
    sops.secrets."nixgram" = {
      sopsFile = ../../../secrets/nixgram.env;
      format = "dotenv";
    };
    systemd.services.nixgram = {
      description = "nixgram service";
      requires = [ "network-online.target" ];
      script = "nixgram";
      path =
        [ cfg.package ]
        ++ (lib.pipe cfg.customCommands [
          (builtins.mapAttrs (k: v: pkgs.writeShellScriptBin "nixgram-${k}" v))
          (builtins.attrValues)
        ]);
      serviceConfig = {
        Restart = "on-failure";
        DynamicUser = true;
        User = cfg.user;
        Group = cfg.group;
        EnvironmentFile = mkIf (cfg.environmentFile != null) cfg.environmentFile;
      };
      wantedBy = [ "multi-user.target" ];
    };
  };
}
