{ config, pkgs, lib, ... }: with lib; let
  homeConfig = config;
  cfg = config.programs.firefox;
  wrapperConfig = cfg.wrapperConfig;
  wrapped = cfg.wrapper cfg.packageUnwrapped cfg.wrapperConfig;
  package' = wrapped // {
    # HACK: work around https://github.com/nix-community/home-manager/issues/1962
    override = _: package';
  };
  firefoxConfigPath = if pkgs.hostPlatform.isDarwin then "Library/Application Support/Firefox" else ".mozilla/firefox";
  profilesPath = firefoxConfigPath + optionalString pkgs.hostPlatform.isDarwin "/Profiles";
  profileType = { config, ... }: {
    options = with types; {
      containers = mkOption {
        type = types.attrsOf (types.submodule ({ config, name, ... }: {
          options = with types; {
            order = mkOption {
              description = "Container sort order";
              type = unspecified;
              default = name;
            };
            icon = mkOption {
              type = enum [ "" ];
            };
            color = mkOption {
              type = enum [ "" ];
            };

            public = mkOption {
              description = "Whether the container is visible or not";
              type = bool;
              default = true;
            };

            identityJson = mkOption {
              description = "containers.json";
              type = attrsOf (oneOf [ str bool int ]);
            };
          };
          config = {
            identityJson = mapAttrs (_: mkOptionDefault) {
              userContextId = config.id;
              inherit (config) name icon color public;
            };
          };
        }));
      };
      containersIdentities = mkOption {
        type = listOf (attrsOf (oneOf [ str bool int ]));
        default = [ ];
      };
      importBukuBookmarks = mkOption {
        type = bool;
        default = false;
      };
    };

    config = {
      settings = mkMerge [
        (mkIf (config.containersIdentities != [ ]) {
          "privacy.userContext.enabled" = mkOptionDefault true;
          "privacy.userContext.ui.enabled" = mkOptionDefault true;
        })
        (mkIf (config.userChrome != "" || config.userContent != "") {
          "toolkit.legacyUserProfileCustomizations.stylesheets" = mkOptionDefault true;
        })
      ];
      containersIdentities = let
        containers = sort (a: b: a.order < b.order) (attrValues config.containers);
        identities = map ({ identityJson, ... }: identityJson) containers;
        webextStorage = {
          userContextId = 4294967295;
          name = "userContextIdInternal.webextStorageLocal";
          icon = "";
          color = "";
          public = false;
          accessKey = "";
        };
      in mkIf (config.containers != { }) (mkMerge [
        identities
        (mkAfter [ webextStorage ])
      ]);
      bookmarks = let
        inherit (homeConfig.programs) buku;
        bukuFolders = mapAttrs (_: folder: {
          inherit (folder) tag name;
          bookmarks = filter (bookmark: elem folder.tag bookmark.tags) (attrValues buku.bookmarks);
        }) buku.folders;
        topLevelBookmarks = filter (bookmark: ! any (folder: elem folder.tag bookmark.tags) (attrValues bukuFolders)) (attrValues buku.bookmarks);
        bukuImport = bookmark: {
          name = bookmark.title;
          tags = attrNames (removeAttrs (genAttrs bookmark.tags id) (attrNames bukuFolders));
          inherit (bookmark) url;
        };
        bookmarks = mkMerge [
          (mapAttrs (folder: { name, bookmarks, ... }: {
            inherit name;
            bookmarks = map bukuImport bookmarks;
          }) bukuFolders)
          (map bukuImport topLevelBookmarks)
        ];
      in mkIf config.importBukuBookmarks bookmarks;
    };
  };
in {
  options.programs.firefox = {
    packageUnwrapped = mkOption {
      type = types.package;
      default = pkgs.firefox-unwrapped;
      defaultText = "pkgs.firefox-unwrapped";
      description = "The unwrapped Firefox package to use.";
    };

    wrapper = mkOption {
      type = types.unspecified;
      default = pkgs.wrapFirefox;
      defaultText = "pkgs.wrapFirefox";
      description = "The firefox wrapper function";
    };

    wrapperConfig = mkOption {
      type = with types; attrsOf (oneOf [ (nullOr str) bool (listOf package) (attrsOf bool) ]);
      default = { };
      description = "Extra arguments to pass to the firefox wrapper.";
      example = literalExample ''
        {
          nativeMessagingHosts = [
            pkgs.tridactyl-native
          ];
        }
      '';
    };

    profiles = mkOption {
      type = types.attrsOf (types.submodule profileType);
    };
  };
  config = mkIf cfg.enable {
    programs.firefox = {
      package = mkDefault package';
      wrapperConfig = {
        cfg = {
          enableGnomeExtensions = mkOptionDefault cfg.enableGnomeExtensions;
        };
      };
    };
    home.file = mkMerge (flip mapAttrsToList cfg.profiles (_: profile: {
      "${profilesPath}/${profile.path}/containers.json" = mkIf (profile.containersIdentities != [ ]) {
        text = mkOverride 75 (builtins.toJSON {
          version = 4;
          lastUserContextId = foldl max 0 (map ({ id, ... }: id) (attrValues profile.containers));
          identities = profile.containersIdentities;
        });
      };
    }));
  };
}
