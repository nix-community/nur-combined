{ config, lib, options, sane-lib, ... }:

let
  inherit (builtins) attrValues;
  inherit (lib) count mapAttrs' mapAttrsToList mkIf mkMerge mkOption types;
  sane-user-cfg = config.sane.user;
  cfg = config.sane.users;
  path-lib = sane-lib.path;
  userOptions = {
    options = {
      fs = mkOption {
        type = types.attrs;
        default = {};
        description = ''
        entries to pass onto `sane.fs` after prepending the user's home-dir to the path
        and marking them as wanted.
          e.g. `sane.users.colin.fs."/.config/aerc" = X`
          => `sane.fs."/home/colin/.config/aerc" = { wantedBy = [ "multi-user.target"]; } // X;

          conventions are similar as to toplevel `sane.fs`. so `sane.users.foo.fs."/"` represents the home directory,
          whereas every other entry is expected to *not* have a trailing slash.
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
    };
  };
  userModule = types.submodule ({ name, config, ... }: {
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
      (mkIf config.default sane-user-cfg)
      {
        fs.".profile".symlink.text =
          let
            env = lib.mapAttrsToList
              (key: value: ''export ${key}="${value}"'')
              config.environment
            ;
          in
            lib.concatStringsSep "\n" env;
      }
    ];
  });
  processUser = user: defn:
    let
      prefixWithHome = mapAttrs' (path: value: {
        name = path-lib.concat [ defn.home path ];
        inherit value;
      });
      makeWanted = lib.mapAttrs (n: v: {
        # default if not otherwise provided
        wantedBeforeBy = [ "multi-user.target" ];
      } // v);
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
      type = types.nullOr (types.submodule userOptions);
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
