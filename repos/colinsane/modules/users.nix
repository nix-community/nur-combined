{ config, lib, options, sane-lib, utils, ... }:

let
  inherit (builtins) attrValues;
  inherit (lib) count mapAttrs' mapAttrsToList mkIf mkMerge mkOption types;
  sane-user-cfg = config.sane.user;
  cfg = config.sane.users;
  path-lib = sane-lib.path;
  userOptions = {
    options = {
      fs = mkOption {
        # map to listOf attrs so that we can allow multiple assigners to the same path
        # w/o worrying about merging at this layer, and defer merging to modules/fs instead.
        type = types.attrsOf (types.coercedTo types.attrs (a: [ a ]) (types.listOf types.attrs));
        default = {};
        description = ''
          entries to pass onto `sane.fs` after prepending the user's home-dir to the path
          and marking them as wanted.
          e.g. `sane.users.colin.fs."/.config/aerc" = X`
          => `sane.fs."/home/colin/.config/aerc" = { wantedBy = [ "multi-user.target"]; } // X;

          conventions are similar as to toplevel `sane.fs`. so `sane.users.foo.fs."/"` represents the home directory,
          whereas every other entry is expected to *not* have a trailing slash.

          option merging happens inside `sane.fs`, so `sane.users.colin.fs."foo" = A` and `sane.fs."/home/colin/foo" = B`
          behaves identically to `sane.fs."/home/colin/foo" = lib.mkMerge [ A B ];
          (the unusual signature for this type is how we delay option merging)
        '';
      };

      persist = mkOption {
        type = options.sane.persist.sys.type;
        default = {};
        description = ''
          entries to pass onto `sane.persist.sys` after prepending the user's home-dir to the path.
        '';
      };

      environment = mkOption {
        type = types.attrsOf types.str;
        default = {};
        description = ''
          environment variables to place in user's shell profile.
          these end up in ~/.profile
        '';
      };

      services = mkOption {
        # see: <repo:nixos/nixpkgs:nixos/lib/utils.nix>
        type = utils.systemdUtils.types.services;
        default = {};
        description = ''
          systemd user-services to define for this user.
          populates files in ~/.config/systemd.
        '';
      };
    };
  };
  defaultUserOptions = {
    options = userOptions.options // {
      services = mkOption {
        # type = utils.systemdUtils.types.services;
        # map to listOf attrs so that we can pass through
        # w/o worrying about merging at this layer
        type = types.attrsOf (types.coercedTo types.attrs (a: [ a ]) (types.listOf types.attrs));
        default = {};
        inherit (userOptions.options.services) description;
      };
    };
  };
  userModule = let nixConfig = config; in types.submodule ({ name, config, ... }: {
    options = userOptions.options // {
      default = mkOption {
        type = types.bool;
        default = false;
        description = ''
          only one default user may exist.
          this option determines what the `sane.user` shorthand evaluates to.
        '';
      };

      home = mkOption {
        type = types.str;
        # XXX: we'd prefer to set this to `config.users.users.home`, but that causes infinite recursion...
        # TODO: maybe assert that this matches the actual home?
        default = "/home/${name}";
      };
    };

    config = lib.mkMerge [
      # if we're the default user, inherit whatever settings were routed to the default user
      (mkIf config.default {
        inherit (sane-user-cfg) fs persist environment;
        services = lib.mapAttrs (_: lib.mkMerge) sane-user-cfg.services;
      })
      {
        fs."/".dir.acl = {
          user = lib.mkDefault name;
          group = lib.mkDefault nixConfig.users.users."${name}".group;
          # homeMode defaults to 700; notice: no leading 0
          mode = "0" + nixConfig.users.users."${name}".homeMode;
        };
        fs.".profile".symlink.text =
          let
            env = lib.mapAttrsToList
              (key: value: ''export ${key}="${value}"'')
              config.environment
            ;
          in
            lib.concatStringsSep "\n" env;
      }
      {
        fs = lib.mkMerge (mapAttrsToList (serviceName: value:
          let
            # see: <repo:nixos/nixpkgs:nixos/lib/utils.nix>
            # see: <repo:nix-community/home-manager:modules/systemd.nix>
            cleanName = utils.systemdUtils.lib.mkPathSafeName serviceName;
            generatedUnit = utils.systemdUtils.lib.serviceToUnit serviceName (value // {
              environment = (value.environment or {}) // {
                # replicate the default NixOS user PATH (omitting dirs which don't exist)
                # N.B.: user PATH SHOULD be before the service's path.
                # this allows to user to override preferences for things like e.g. bemenu (for theming)
                PATH = lib.removeSuffix ":" (
                  "/run/wrappers/bin:"
                  + "/etc/profiles/per-user/${name}/bin:"
                  + "/run/current-system/sw/bin:"
                  + (value.environment.PATH or "")
                );
              };
            });
            #^ generatedUnit contains keys:
            # - text
            # - aliases  (IGNORED)
            # - wantedBy
            # - requiredBy
            # - enabled  (IGNORED)
            # - overrideStrategy  (IGNORED)
            # TODO: error if one of the above ignored fields are set
            symlinkData = {
              text = generatedUnit.text;
              targetName = "${cleanName}.service";  # systemd derives unit name from symlink target
            };
            serviceEntry = {
              ".config/systemd/user/${serviceName}.service".symlink = symlinkData;
            };
            wants = builtins.map (wantedBy: {
              ".config/systemd/user/${wantedBy}.wants/${serviceName}.service".symlink = symlinkData;
            }) generatedUnit.wantedBy;
            requires = builtins.map (requiredBy: {
              ".config/systemd/user/${requiredBy}.requires/${serviceName}.service".symlink = symlinkData;
            }) generatedUnit.requiredBy;
          in lib.mkMerge ([ serviceEntry ] ++ wants ++ requires)
        ) config.services);
      }
    ];
  });
  processUser = user: defn:
    let
      prefixWithHome = mapAttrs' (path: value: {
        name = path-lib.concat [ defn.home path ];
        inherit value;
      });
      makeWanted = lib.mapAttrs (_path: values: lib.mkMerge (values ++ [{
        # default if not otherwise provided
        wantedBeforeBy = lib.mkDefault [ "multi-user.target" ];
      }]));
    in
    {
      sane.fs = makeWanted (prefixWithHome defn.fs);

      # `byPath` is the actual output here, computed from the other keys.
      sane.persist.sys.byPath = prefixWithHome defn.persist.byPath;
    };
in
{
  options = {
    sane.users = mkOption {
      type = types.attrsOf userModule;
      default = {};
      description = ''
        options to apply to the given user.
        the user is expected to be created externally.
        configs applied at this level are simply transformed and then merged
        into the toplevel `sane` options. it's merely a shorthand.
      '';
    };

    sane.user = mkOption {
      type = types.nullOr (types.submodule defaultUserOptions);
      default = null;
      description = ''
        options to pass down to the default user
      '';
    };
  };
  config =
    let
      configs = mapAttrsToList processUser cfg;
      num-default-users = count (u: u.default) (attrValues cfg);
      take = f: {
        sane.fs = f.sane.fs;
        sane.persist.sys.byPath = f.sane.persist.sys.byPath;
      };
    in mkMerge [
      (take (sane-lib.mkTypedMerge take configs))
      {
        assertions = [
          {
            assertion = sane-user-cfg == null || num-default-users != 0;
            message = "cannot set `sane.user` without first setting `sane.users.<user>.default = true` for some user";
          }
          {
            assertion = num-default-users <= 1;
            message = "cannot set more than one default user";
          }
        ];
      }
    ];
}
