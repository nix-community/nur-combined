{ config, lib, pkgs, ... }:

let
  cfg = config.programs.myhotkeys;
  iniFormat = pkgs.formats.json { };

  mipmip = {
    name = "Pim Snel";
    email = "post@pimsnel.com";
    github = "mipmip";
    githubId = 658612;
  };


  mkOptionCommands = description:
    lib.mkOption {
      type = lib.types.nullOr (lib.types.listOf lib.types.str);
      default = null;
      description = description;
    };

  mkOptionRoot = description:
    lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = description;
    };

in {
  meta.maintainers = [ mipmip ];

  options.programs.myhotkeys = {

    enable = lib.mkEnableOption "all My Hotkeys help screen";

    hotkey_groups = lib.mkOption {
      type = lib.types.listOf (lib.types.submodule [
        {
          options = {
            name = lib.mkOption {
              type = lib.types.str;
              description = ''
                Name of the Hotkey group, e.g. Firefox
              '';
            };

            shortcuts = lib.mkOption {
              type = lib.types.listOf (lib.types.submodule [
                {
                  options = {
                    key = lib.mkOption {
                      type = lib.types.str;
                      description = ''
                        shortcut key
                      '';
                      example = ''
                        <SHIFT><SUPER>B
                      '';
                    };

                    description = lib.mkOption {
                      type = lib.types.str;
                      description = ''
                        description to show in the popup
                      '';
                      example = ''
                        <SHIFT><SUPER>B
                      '';
                    };

                  };
                }
              ]);
              description = ''
                Shortcuts in a group
                '';
            };

          };
        }

      ]);
      default = [ ];
      description = "List of hotkey groups";
    };
  };

  config =
    let
      keys = iniFormat.generate "hotkeys-keys" cfg.hotkey_groups;

    in lib.mkIf cfg.enable {
        home.file."${config.home.homeDirectory}/.config/myhotkeys/keys.json" = {
          source = keys;
        };
  };
}
