{pkgs, lib, config, ...}@args:
with lib;
let 
  nixgram = import ./package.nix args;
in
{
  options = {
    services.nixgram = {
      enable = mkEnableOption "enable telegram interface for custom commands";
      customCommands = mkOption {
        type = with types; attrsOf str;
        default = {};
        example = {
          echo = "echo $*";
        };
        description = "Custom extra commands that the bot can handle";
      };
    };
  };
  config = mkIf config.services.nixgram.enable {
    systemd.user.services.nixgram = import ./service.nix args;
    home.packages = [
      nixgram
    ]
    ++ builtins.attrValues (
      builtins.mapAttrs 
        (name: value: pkgs.writeShellScriptBin ("nixgram-" + name) value)
        config.services.nixgram.customCommands
    );
  };
}
