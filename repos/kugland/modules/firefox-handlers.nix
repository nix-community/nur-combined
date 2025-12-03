{ lib
, config
, ...
}:
let
  cfg = config.programs.firefox.handlers;

  handlersJson = ".mozilla/firefox/${config.programs.firefox.profiles.default.path}/handlers.json";

  action = lib.mkOption {
    type = lib.types.enum [ 0 1 2 3 4 ];
    default = 1;
    description = ''
      The action to take. Possible values:

      0 = Save file
      1 = Always ask
      2 = Use helper app
      3 = Open in Firefox
      4 = Use system default
    '';
  };
  ask = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Whether to ask the user before taking the action.";
  };
  handlers = lib.mkOption {
    type = lib.types.listOf (lib.types.submodule {
      options = {
        name = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          description = "Name of the handler application.";
          default = null;
        };
        path = lib.mkOption {
          type = lib.types.nullOr lib.types.path;
          description = "Path to the handler application.";
          default = null;
        };
        uriTemplate = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          description = "URI template for web-based handlers.";
          default = null;
        };
      };
    });
    default = [ ];
    description = "List of handler applications.";
  };

  checkedHandlers = name: value:
    if value.handlers != [ ]
    then
      (
        if value.action == 2
        then {
          handlers = builtins.map
            (handler:
              (
                if handler.path != null && handler.uriTemplate != null
                then throw "'${name}': handler can’t have both ‘path’ and ‘uriTemplate’ set."
                else { }
              )
              // (
                if handler.name != null
                then { inherit (handler) name; }
                else { }
              )
              // (
                if handler.path != null
                then { inherit (handler) path; }
                else { }
              )
              // (
                if handler.uriTemplate != null
                then { inherit (handler) uriTemplate; }
                else { }
              ))
            value.handlers;
        }
        else throw "'${name}': handlers can only be set when ‘action’ is set to 2 (Use helper app)."
      )
    else { };
in
{
  options = {
    programs.firefox.handlers = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = cfg.mimeTypes != { } || cfg.schemes != { };
        description = "Enable custom Firefox handlers.json configuration.";
      };
      mimeTypes = lib.mkOption {
        type = lib.types.attrsOf (lib.types.submodule {
          options = {
            inherit action ask handlers;
            extensions = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              description = "List of file extensions associated with this MIME type.";
            };
          };
        });
        default = { };
        description = "Mapping of MIME types to default applications.";
        example = ''
          "application/pdf" = {
            action = 2;
            ask = true;
            handlers = [
              {
                name = "Okular";
                path = "''${pkgs.okular}/bin/okular";
              }
            ];
            extensions = ["pdf"];
          };
        '';
      };
      schemes = lib.mkOption {
        type = lib.types.attrsOf (lib.types.submodule {
          options = {
            inherit action ask handlers;
          };
        });
        default = { };
        description = "Mapping of URL schemes to default applications.";
        example = ''
          mailto = {
            action = 2;
            ask = false;
            handlers = [
              {
                name = "Google Mail";
                uriTemplate = "https://mail.google.com/mail/?extsrc=mailto&url=%s";
              }
            ];
          };
        '';
      };
    };
  };

  config = {
    home.file.${handlersJson} = {
      enable = cfg.enable;
      force = cfg.enable;
      text = builtins.toJSON {
        defaultHandlersVersion = { };
        isDownloadsImprovementsAlreadyMigrated = false;
        mimeTypes =
          builtins.mapAttrs
            (
              name: value:
                { inherit (value) action ask extensions; }
                // (checkedHandlers name value)
            )
            cfg.mimeTypes;
        schemes =
          builtins.mapAttrs
            (
              name: value:
                { inherit (value) action ask; }
                // (checkedHandlers name value)
            )
            cfg.schemes;
      };
    };
  };
}
