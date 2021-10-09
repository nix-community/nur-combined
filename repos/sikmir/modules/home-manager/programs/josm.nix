{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.programs.josm;
  configDir =
    if pkgs.stdenv.isDarwin then
      "${config.home.homeDirectory}/Library/Preferences/JOSM"
    else
      "${config.xdg.configHome}/JOSM";
  configFile = "${configDir}/preferences.xml";
in
{
  meta.maintainers = [ maintainers.sikmir ];

  options.programs.josm = {
    enable = mkEnableOption "An extensible editor for OpenStreetMap";

    package = mkOption {
      default = pkgs.josm;
      defaultText = literalExpression "pkgs.josm";
      description = "JOSM package to install.";
      type = types.package;
    };

    accessTokenKey = mkOption {
      default = "";
      description = "OAuth Access Token Key.";
      type = types.str;
    };

    accessTokenSecret = mkOption {
      default = "";
      description = "OAuth Access Token Secret.";
      type = types.str;
    };
  };

  config = mkIf cfg.enable (
    mkMerge [
      {
        home.packages = [ cfg.package ];

        home.activation.createJOSMConfigFile = lib.hm.dag.entryBefore [ "writeBoundary" ] ''
          . ${./josm/init-prefs.sh}
          . ${./josm/upsert-tag.sh}
          export PATH=${pkgs.xmlstarlet}/bin:$PATH
          initPrefs ${cfg.package.version} ${configFile}
          upsertTag josm.version ${cfg.package.version} ${configFile}
        '';
      }

      (
        mkIf (cfg.accessTokenKey != "") {
          home.activation.setupAccessTokenKey = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
            . ${./josm/upsert-tag.sh}
            export PATH=${pkgs.xmlstarlet}/bin:$PATH
            upsertTag oauth.access-token.key ${cfg.accessTokenKey} ${configFile}
          '';
        }
      )

      (
        mkIf (cfg.accessTokenSecret != "") {
          home.activation.setupAccessTokenSecret = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
            . ${./josm/upsert-tag.sh}
            export PATH=${pkgs.xmlstarlet}/bin:$PATH
            upsertTag oauth.access-token.secret ${cfg.accessTokenSecret} ${configFile}
          '';
        }
      )
    ]
  );
}
