{ config, lib, options, pkgs, sane-lib, ... }:
let
  inherit (builtins) any attrValues elem map;
  inherit (lib)
    concatMapAttrs
    filterAttrs
    hasAttrByPath
    getAttrFromPath
    mapAttrs
    mapAttrs'
    mapAttrsToList
    mkDefault
    mkIf
    mkMerge
    mkOption
    optional
    optionalAttrs
    splitString
    types
  ;
  inherit (sane-lib) joinAttrsets;
  cfg = config.sane.programs;
  pkgSpec = types.submodule ({ config, name, ... }: {
    options = {
      package = mkOption {
        type = types.nullOr types.package;
        description = ''
          package, or `null` if the program is some sort of meta set (in which case it much EXPLICITLY be set null).
        '';
        default =
          let
            pkgPath = splitString "." name;
          in
            # package can be inferred by the attr name, allowing shorthand like
            #   `sane.programs.nano.enable = true;`
            # this indexing will throw if the package doesn't exist and the user forgets to specify
            # a valid source explicitly.
            getAttrFromPath pkgPath pkgs;
      };
      enableFor.system = mkOption {
        type = types.bool;
        default = any (en: en) (
          mapAttrsToList
            (otherName: otherPkg:
              otherName != name && elem name otherPkg.suggestedPrograms && otherPkg.enableSuggested && otherPkg.enableFor.system
            )
            cfg
        );
        description = ''
          place this program on the system PATH
        '';
      };
      enableFor.user = mkOption {
        type = types.attrsOf types.bool;
        default = joinAttrsets (mapAttrsToList (otherName: otherPkg:
           optionalAttrs
             (otherName != name && elem name otherPkg.suggestedPrograms && otherPkg.enableSuggested)
             (filterAttrs (user: en: en) otherPkg.enableFor.user)
        ) cfg);
        description = ''
          place this program on the PATH for some specified user(s).
        '';
      };
      enabled = mkOption {
        type = types.bool;
        description = ''
          generated (i.e. read-only) value indicating if the program is enabled either for any user or for the system.
        '';
      };
      suggestedPrograms = mkOption {
        type = types.listOf types.str;
        default = [];
        description = ''
          list of other programs a user may want to enable alongside this one.
          for example, the gnome desktop environment would suggest things like its settings app.
        '';
      };
      enableSuggested = mkOption {
        type = types.bool;
        default = true;
      };
      persist = {
        plaintext = mkOption {
          type = types.listOf types.str;
          default = [];
          description = "list of home-relative paths to persist for this package";
        };
        private = mkOption {
          type = types.listOf types.str;
          default = [];
          description = "list of home-relative paths to persist (in encrypted format) for this package";
        };
      };
      fs = mkOption {
        type = types.attrs;
        default = {};
        description = "files to populate when this program is enabled";
      };
      secrets = mkOption {
        type = types.attrsOf types.path;
        default = {};
        description = ''
          fs paths to link to some decrypted secret.
          the secret will have same owner as the user under which the program is enabled.
        '';
      };
      configOption = mkOption {
        type = types.raw;
        default = mkOption {
          type = types.submodule {};
          default = {};
        };
        description = ''
          declare any other options the program may be configured with.
          you probably want this to be a submodule.
          the option *definitions* can be set with `sane.programs."foo".config = ...`.
        '';
      };
      config = config.configOption;
    };

    config = {
      enabled = config.enableFor.system || any (en: en) (attrValues config.enableFor.user);
    };
  });
  toPkgSpec = types.coercedTo types.package (p: { package = p; }) pkgSpec;

  configs = mapAttrsToList (name: p: {
    assertions = map (sug: {
      assertion = cfg ? "${sug}";
      message = ''program "${sug}" referenced by "${name}", but not defined'';
    }) p.suggestedPrograms;

    # conditionally add to system PATH
    environment.systemPackages = optional
      (p.package != null && p.enableFor.system)
      p.package;

    # conditionally add to user(s) PATH
    users.users = mapAttrs (user: en: {
      packages = optional (p.package != null && en) p.package;
    }) p.enableFor.user;

    # conditionally persist relevant user dirs and create files
    sane.users = mapAttrs (user: en: optionalAttrs en {
      inherit (p) persist;
      fs = mkMerge [
        p.fs
        (mapAttrs
          # link every secret into the fs
          # TODO: user the user's *actual* home directory, don't guess.
          (homePath: _src: sane-lib.fs.wantedSymlinkTo "/run/secrets/home/${user}/${homePath}")
          p.secrets
        )
      ];
    }) p.enableFor.user;

    # make secrets available for each user
    sops.secrets = concatMapAttrs
      (user: en: optionalAttrs en (
        mapAttrs'
          (homePath: src: {
            # TODO: user the user's *actual* home directory, don't guess.
            # XXX: name CAN'T START WITH '/', else sops creates the directories funny.
            # TODO: report this upstream.
            name = "home/${user}/${homePath}";
            value = {
              owner = user;
              sopsFile = src;
              format = "binary";
            };
          })
          p.secrets
      ))
      p.enableFor.user;

  }) cfg;
in
{
  options = {
    sane.programs = mkOption {
      type = types.attrsOf toPkgSpec;
      default = {};
    };
  };

  config =
    let
      take = f: {
        assertions = f.assertions;
        environment.systemPackages = f.environment.systemPackages;
        users.users = f.users.users;
        sane.users = f.sane.users;
        sops.secrets = f.sops.secrets;
      };
    in mkMerge [
      (take (sane-lib.mkTypedMerge take configs))
      {
        # expose the pkgs -- as available to the system -- as a build target.
        system.build.pkgs = pkgs;
      }
    ];
}
