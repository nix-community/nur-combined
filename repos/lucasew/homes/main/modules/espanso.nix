{pkgs, config, lib, ...}:
with lib;
let
  cfg = config.services.espanso;
  systemdUserService = import ../../../lib/systemdUserService.nix;
  yaml = pkgs.formats.yaml {};
in {
  # blocking: https://github.com/NixOS/nixpkgs/issues/133802
  options = {
    services.espanso = {
      enable = mkEnableOption "Espanso: cross platform text expander in Rust";
      config = mkOption {
        type = yaml.type;
        description = "Espanso configuration";
        default = {
          matches = [
            { # Simple text replacement
              trigger = ":espanso";
              replace = "Hi there!";
            }
            { # Dates
              trigger = ":date";
              replace = "{{mydate}}";
              vars = {
                name = "mydate";
                type = "date";
                params = {
                  format = "%m/%d/%Y";
                };
              };
            }
            { # Shell commands
              trigger = ":shell";
              replace = "{{output}}";
              vars = {
                name = "output";
                type = "shell";
                params = {
                  cmd = "echo Hello from your shell";
                };
              };
            }
          ];
        };
      };
    };
  };
  config = mkIf cfg.enable {
    systemd.user.services = {
      espanso = systemdUserService {
        description = "Espanso: cross platform text expander in Rust";
        enable = true;
        command = "${pkgs.espanso}/bin/espanso daemon";
      };
    };
    home.file.".config/espanso/default.yml".source = yaml.generate "default.yml" cfg.config;
    home.packages = with pkgs; [
      espanso
    ];
  };
}
