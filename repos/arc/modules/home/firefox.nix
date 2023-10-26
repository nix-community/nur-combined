{ config, pkgs, lib, ... }: with lib; let
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
    options = {
      containers = mkOption {
        default = { };
        description = "Firefox multi-account container definitions";
        type = types.submodule ({ ... }: {
          options = {
            identities = mkOption {
              description = "Ordered container identity list";
              default = [ ];
              example = [
                { id = 5; name = "Shopping"; icon = "gift"; color = "turquoise"; }
              ];
              type = types.listOf (types.submodule ({ ... }: {
                options = {
                  id = mkOption {
                    description = "User Context ID";
                    type = types.ints.unsigned;
                  };
                  name = mkOption {
                    description = "Container name";
                    type = types.str;
                  };
                  icon = mkOption {
                    description = "Icon";
                    type = types.enum [
                      "" "fingerprint" "briefcase" "dollar" "cart" "circle" "gift"
                      "vacation" "food" "fruit" "pet" "tree" "chill" "fence"
                    ];
                    default = "circle";
                  };
                  color = mkOption {
                    description = "Color";
                    type = types.enum [
                      "" "toolbar" # what kind of name for black is this???
                      "blue" "turquoise" "green" "yellow" "red" "pink" "purple" "orange"
                    ];
                    default = "toolbar";
                  };
                  public = mkOption {
                    description = "Whether the container is visible or not";
                    type = types.bool;
                    default = true;
                  };
                };
              }));
            };
          };
        });
      };
    };

    config = {
      settings = mkMerge [
        (mkIf (config.containers.identities != [ ]) {
          "privacy.userContext.enabled" = mkOptionDefault true;
          "privacy.userContext.ui.enabled" = mkOptionDefault true;
        })
        (mkIf (config.userChrome != "" || config.userContent != "") {
          "toolkit.legacyUserProfileCustomizations.stylesheets" = mkOptionDefault true;
        })
      ];
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
      "${profilesPath}/${profile.path}/containers.json" = mkIf (profile.containers.identities != [ ]) {
        text = builtins.toJSON {
          version = 4;
          lastUserContextId = foldl max 0 (map ({ id, ... }: id) profile.containers.identities);
          identities = map (c: {
            inherit (c) name icon color public;
            userContextId = c.id;
          }) profile.containers.identities ++ [{
            userContextId = 4294967295;
            name = "userContextIdInternal.webextStorageLocal";
            icon = "";
            color = "";
            public = false;
            accessKey = "";
          }];
        };
      };
    }));
  };
}
