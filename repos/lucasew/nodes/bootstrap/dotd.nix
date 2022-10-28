{ config, pkgs, lib, ... }:
let
  inherit (lib) mkOption mkMerge mkIf mkEnableOption types;
  cfg = config.environment.dotd;
in {
  options = {
    environment.dotd = mkOption {
      description = "dotd abstraction services";
      default = {};
      type = types.attrsOf (types.submodule {
        options = {
          enable = mkEnableOption "dotd service";
        };
      });
    };
  };
  config.systemd = mkMerge (let
        keys = builtins.attrNames cfg;
      in builtins.map (key: let
        item = cfg.${key};
        normalizedKey = builtins.replaceStrings ["/"] ["_"] key;
      in {
        paths."dotd-${normalizedKey}-watcher" = {
          inherit (item) enable;
          wantedBy = [ "default.target" ];
          pathConfig = {
            PathChanged = "/etc/${key}.d";
          };
        };
        services."dotd-${normalizedKey}-watcher" = {
          inherit (item) enable;
          script = ''
            echo "Reacting to file change..."
            systemctl restart "dotd-${normalizedKey}" || true
          '';
        };
        services."dotd-${normalizedKey}" = {
          inherit (item) enable;
          restartIfChanged = true;
          wantedBy = [ "default.target" ];
          script = ''
            DOTD_FILE="/etc/${key}"
            DOTD_FOLDER="/etc/${key}.d"
            mkdir -p "$(dirname "$DOTD_FILE")"
            mkdir -p "$DOTD_FILE.d"
            if test -e "$DOTD_FILE"; then
              rm "$DOTD_FILE"
            fi
            mkfifo "$DOTD_FILE" -m 644
            while true; do
              echo Someone accessed the named pipe >&2
              ls -1 "$DOTD_FOLDER" | sort | while read file; do
                cat "$DOTD_FOLDER/$file" || true
              done > "$DOTD_FILE"
            done
          '';
        };
    }) keys);
}
