{ config, pkgs, lib, ... }: with lib; let
  cfg = config.programs.buku;
  database = pkgs.stdenvNoCC.mkDerivation {
    name = "bookmarks.db";
    nativeBuildInputs = [ cfg.package ];
    passAsFile = [ "buildCommand" "bookmarks" ];
    buildCommand = ''
      ln -s $bookmarksPath bookmarks.json
      unset HOME
      ${concatMapStringsSep "\n" (bookmark: escapeShellArgs ([
        "buku"
        "--title" bookmark.title
      ] ++ optionals (bookmark.description != null) [ "-c" bookmark.description ]
        ++ optionals (!cfg.mutable) [ "--immutable" "1" ]
        ++ [ "-a" bookmark.url ]
        ++ optional (bookmark.tags != []) (concatStringsSep "," bookmark.tags)
      )) (attrValues cfg.bookmarks)}
      mv bookmarks.db $out
    '';
  };
in {
  options.programs.buku = {
    enable = mkEnableOption "buku";
    package = mkOption {
      type = types.package;
      default = pkgs.buku;
      defaultText = "pkgs.buku";
    };
    database = mkOption {
      type = types.package;
      default = database;
      defaultText = "bookmarks.db";
    };
    mutable = mkOption {
      type = types.bool;
      default = false;
    };
    bookmarks = let
      type = types.submodule ({ config, name, ... }: {
        options = {
          id = mkOption {
            type = types.str;
            default = name;
          };
          title = mkOption {
            type = types.str;
            default = config.id;
          };
          description = mkOption {
            type = types.nullOr types.str;
            default = null;
          };
          url = mkOption {
            type = types.str;
          };
          tags = mkOption {
            type = types.listOf types.str;
            default = [ ];
          };
        };
      });
    in mkOption {
      type = types.attrsOf type;
      default = { };
    };

    folders = let
      type = types.submodule ({ config, name, ... }: {
        options = {
          tag = mkOption {
            type = types.str;
            default = name;
          };
          folders = mkOption {
            type = types.attrsOf types.type;
            default = { };
          };
          name = mkOption {
            type = types.str;
            default = config.tag;
          };
          description = mkOption {
            type = types.nullOr types.str;
            default = null;
          };
        };
      });
    in mkOption {
      type = types.attrsOf type;
      default = { };
      description = "Categorize bookmarks by using a tag as a folder";
    };
    containers = let
      type = types.submodule ({ config, name, ... }: {
        options = {
          tags = mkOption {
            type = types.listOf types.str;
            default = [ name ];
          };
          container = mkOption {
            type = types.nullOr types.str;
            default = name;
          };
        };
      });
    in mkOption {
      type = types.attrsOf type;
      default = { };
      description = "Map tags to open in a specific container";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];
    home.symlink = if !cfg.mutable then {
      ".local/share/buku/bookmarks.db".target = toString cfg.database.outPath;
    } else { };
    # TODO: if mutable, activation script should run buku -i ${cfg.database}?
  };
}
