{ config, lib, ... }:

let
  inherit (builtins) storeDir;
  inherit (config.security.sudo) allowedCommands;
  inherit (lib) mkIf mkOption;
  inherit (lib.types) attrsOf bool listOf str submodule;
in
{
  options = {
    security.sudo.allowedCommands = mkOption { type = listOf str; default = [ ]; };

    systemd.services = mkOption {
      type = attrsOf (submodule ({ config, ... }: {
        options.restrictExecToNixStore = mkOption { type = bool; default = false; };

        config = mkIf config.restrictExecToNixStore {
          serviceConfig = {
            NoExecPaths = [ "/" ];
            ExecPaths = [ storeDir ];
          };
        };
      }));
    };
  };

  config = {
    security.sudo.extraRules = [{
      groups = [ "wheel" ];
      commands = map (c: { command = c; options = [ "NOPASSWD" ]; }) allowedCommands;
    }];
  };
}
