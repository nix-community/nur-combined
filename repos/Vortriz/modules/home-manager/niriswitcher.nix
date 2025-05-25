{
    config,
    lib,
    pkgs,
    ...
}:
with lib; let
    cfg = config.programs.niriswitcher;
    flakePkgs = import ../.. {inherit pkgs;};
in {
    options.programs.niriswitcher = {
        enable = mkEnableOption "niriswitcher";

        package = mkPackageOption flakePkgs "niriswitcher" {};

        config = mkOption {
            type = types.attrs;
            default = {};
            description = ''
                Configuration for niriswitcher, written to `XDG_CONFIG_HOME/niriswitcher/config.toml`.
                Options as per https://github.com/isaksamsten/niriswitcher/tree/main?tab=readme-ov-file#options.
            '';
            example = {
                keys = {
                    modifier = "Super";
                    switch = {
                        next = "Tab";
                        prev = "Shift+Tab";
                    };
                };
                center_on_focus = true;
                appearance = {
                    system_theme = "dark";
                    icon_size = 64;
                };
            };
        };

        style = mkOption {
            type = types.lines;
            default = "";
            description = ''
                Custom CSS for niriswitcher, written to `XDG_CONFIG_HOME/niriswitcher/style.css`.
                As per https://github.com/isaksamsten/niriswitcher?tab=readme-ov-file#themes.
            '';
            example = ''
                /* To make the application name visible for non-selected applications (but dimmed) */
                .application-name {
                  opacity: 1;
                  color: rgba(255, 255, 255, 0.6);
                }
                .application.selected .application-name {
                  color: rgba(255, 255, 255, 1);
                }
            '';
        };
    };

    config = mkMerge [
        (mkIf cfg.enable {
            home.packages = [cfg.package];
        })

        (mkIf (cfg.config != {}) {
            xdg.configFile."niriswitcher/config.toml".source = pkgs.writers.writeTOML "config.toml" cfg.config;
        })

        (mkIf (cfg.style != "") {
            xdg.configFile."niriswitcher/style.css".source = pkgs.writers.writeText "style.css" cfg.style;
        })
    ];
}
