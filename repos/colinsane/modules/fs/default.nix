{ config, lib, pkgs, utils, sane-lib, ... }:
with lib;
let
  path-lib = sane-lib.path;
  sane-types = sane-lib.types;
  cfg = config.sane.fs;

  mountNameFor = path: "${utils.escapeSystemdPath path}.mount";
  serviceNameFor = path: "ensure-${utils.escapeSystemdPath path}";

  # sane.fs."<path>" top-level options
  fsEntry = types.submodule ({ name, config, ...}: let
    parent = path-lib.parent name;
    has-parent = path-lib.hasParent name;
    parent-cfg = if has-parent then cfg."${parent}" else {};
    parent-acl = if has-parent then parent-cfg.generated.acl else {};
  in {
    options = {
      dir = mkOption {
        type = types.nullOr dirEntry;
        default = null;
      };
      symlink = mkOption {
        type = types.nullOr (symlinkEntryFor name);
        default = null;
      };
      generated = mkOption {
        type = generatedEntry;
        default = {};
      };
      mount = mkOption {
        type = types.nullOr (mountEntryFor name);
        default = null;
      };
      wantedBy = mkOption {
        type = types.listOf types.str;
        default = [];
        description = ''
          list of units or targets which, when activated, should trigger this fs entry to be created.
        '';
      };
      wantedBeforeBy = mkOption {
        type = types.listOf types.str;
        default = [];
        description = ''
          list of units or targets which, when activated, should first start and wait for this fs entry to be created.
          if this unit fails, it will not block the targets in this list.
        '';
      };
      unit = mkOption {
        type = types.str;
        description = "name of the systemd unit which ensures this entry";
      };
    };
    config = let
      default-acl = {
        user = lib.mkDefault (parent-acl.user or "root");
        group = lib.mkDefault (parent-acl.group or "root");
        mode = lib.mkDefault (parent-acl.mode or "0755");
      };
    in {
      # we put this here instead of as a `default` to ensure that users who specify additional
      # dependencies still get a dep on the parent (unless they assign with `mkForce`).
      generated.depends = if has-parent then [ parent-cfg.unit ] else [];

      # populate generated items from `dir` or `symlink` shorthands
      generated.acl = lib.mkMerge [
        default-acl
        (lib.mkIf (config.dir != null)
          (sane-lib.filterNonNull config.dir.acl))
        (lib.mkIf (config.symlink != null)
          (sane-lib.filterNonNull config.symlink.acl))
      ];

      # actually generate the item
      generated.script = lib.mkMerge [
        (lib.mkIf (config.dir != null) (ensureDirScript name config.dir))
        (lib.mkIf (config.symlink != null) (ensureSymlinkScript name config.symlink))
      ];

      # make the unit file which generates the underlying thing available so that `mount` can use it.
      generated.unit = (serviceNameFor name) + ".service";

      # if we were asked to mount, make sure we create the dir that we mount over
      dir = lib.mkIf (config.mount != null) {};

      # if defaulted, this module is responsible for finalizing the entry.
      # the user could override this if, say, they finalize some aspect of the entry
      # with a custom service.
      unit = lib.mkDefault (
        if config.mount != null then
          config.mount.unit
        else
          config.generated.unit
      );
    };
  });

  # options which can be set in dir/symlink generated items,
  # with intention that they just propagate down
  propagatedGenerateMod = {
    options = {
      acl = mkOption {
        type = sane-types.aclOverride;
        default = {};
      };
    };
  };

  # sane.fs."<path>".dir sub-options
  # takes no special options
  dirEntry = types.submodule propagatedGenerateMod;

  symlinkEntryFor = path: types.submodule ({ config, ...}: {
    options = {
      inherit (propagatedGenerateMod.options) acl;
      target = mkOption {
        type = types.coercedTo types.package toString types.str;
        description = "fs path to link to";
      };
      text = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "create a file in the /nix/store with the provided text and use that as the target";
      };
    };
    config = {
      target = lib.mkIf (config.text != null) (
        pkgs.writeText (path-lib.leaf path) config.text
      );
    };
  });

  generatedEntry = types.submodule {
    options = {
      acl = mkOption {
        type = sane-types.acl;
      };
      depends = mkOption {
        type = types.listOf types.str;
        description = ''
          list of systemd units needed to be run before this item can be generated.
        '';
        default = [];
      };
      script.script = mkOption {
        type = types.lines;
      };
      script.scriptArgs = mkOption {
        type = types.listOf types.str;
        default = [];
      };
      unit = mkOption {
        type = types.str;
        description = "name of the systemd unit which ensures this directory";
      };
    };
  };

  # sane.fs."<path>".mount sub-options
  mountEntryFor = path: types.submodule {
    options = {
      bind = mkOption {
        type = types.nullOr types.str;
        description = "fs path to bind-mount from";
        default = null;
      };
      depends = mkOption {
        type = types.listOf types.str;
        description = ''
          list of systemd units needed to be run before this entry can be mounted
        '';
        default = [];
      };
      unit = mkOption {
        type = types.str;
        description = "name of the systemd unit which mounts this path";
        default = mountNameFor path;
      };
    };
  };

  mkGeneratedConfig = path: opt: let
    gen-opt = opt.generated;
    wrapper = generateWrapperScript path gen-opt;
  in {
    systemd.services."${serviceNameFor path}" = {
      description = "prepare ${path}";
      serviceConfig.Type = "oneshot";

      script = wrapper.script;
      scriptArgs = escapeShellArgs wrapper.scriptArgs;

      after = gen-opt.depends;
      wants = gen-opt.depends;
      # prevent systemd making this unit implicitly dependent on sysinit.target.
      # see: <https://www.freedesktop.org/software/systemd/man/systemd.special.html>
      unitConfig.DefaultDependencies = "no";

      before = opt.wantedBeforeBy;
      wantedBy = opt.wantedBy ++ opt.wantedBeforeBy;
    };
  };

  # given a mountEntry definition, evaluate its toplevel `config` output.
  mkMountConfig = path: opt: (let
    device = config.fileSystems."${path}".device;
    underlying = cfg."${device}";
    isBind = opt.mount.bind != null;
    ifBind = lib.mkIf isBind;
    # before mounting:
    # - create the target directory
    # - prepare the source directory -- assuming it's not an external device
    # - satisfy any user-specified prerequisites ("depends")
    requires = [ opt.generated.unit ]
      ++ (if lib.hasPrefix "/dev/disk/" device then [] else [ underlying.unit ])
      ++ opt.mount.depends;
  in {
    fileSystems."${path}" = {
      device = ifBind opt.mount.bind;
      options = (if isBind then ["bind"] else [])
        ++ [
          # disable defaults: don't require this to be mount as part of local-fs.target
          # we'll handle that stuff precisely.
          "noauto"
          "nofail"
          # x-systemd options documented here:
          # - <https://www.freedesktop.org/software/systemd/man/systemd.mount.html>
        ]
        ++ (builtins.map (unit: "x-systemd.requires=${unit}") requires)
        ++ (builtins.map (unit: "x-systemd.before=${unit}") opt.wantedBeforeBy)
        ++ (builtins.map (unit: "x-systemd.wanted-by=${unit}") (opt.wantedBy ++ opt.wantedBeforeBy));
      noCheck = ifBind true;
    };
  });


  mkFsConfig = path: opt: lib.mkMerge [
    (mkGeneratedConfig path opt)
    (lib.mkIf (opt.mount != null) (mkMountConfig path opt))
  ];

  generateWrapperScript = path: gen-opt: {
    script = ''
      fspath="$1"
      acluser="$2"
      aclgroup="$3"
      aclmode="$4"
      shift 4

      # ensure any things created by the user script have the desired mode.
      # chmod doesn't work on symlinks, so we *have* to use this umask approach.
      decmask=$(( 0777 - "$aclmode" ))
      octmask=$(printf "%o" "$decmask")
      umask "$octmask"

      # try to chmod/chown the result even if the user script errors
      _status=0
      trap "_status=\$?" ERR

      ${gen-opt.script.script}

      # claim ownership of the new thing (DON'T traverse symlinks)
      chown --no-dereference "$acluser:$aclgroup" "$fspath"
      # AS LONG AS IT'S NOT A SYMLINK, try to fix perms in case the entity existed before this script was called
      if ! test -L "$fspath"
      then
        chmod "$aclmode" "$fspath"
      fi

      exit "$_status"
    '';
    scriptArgs = [ path gen-opt.acl.user gen-opt.acl.group gen-opt.acl.mode ] ++ gen-opt.script.scriptArgs;
  };

  # systemd/shell script used to create and set perms for a specific dir
  ensureDirScript = path: dir-cfg: {
    script = ''
      dirpath="$1"

      if ! test -d "$dirpath"
      then
        # if the directory *doesn't* exist, try creating it
        # if we fail to create it, ensure we raced with something else and that it's actually a directory
        mkdir "$dirpath" || test -d "$dirpath"
      fi
    '';
    scriptArgs = [ path ];
  };

  # systemd/shell script used to create a symlink
  ensureSymlinkScript = path: link-cfg: {
    script = ''
      lnfrom="$1"
      lnto="$2"

      # ln is clever when there's something else at the place we want to create the link
      # only create the link if nothing's there or what is there is another link,
      # otherwise you'll get links at unexpected fs locations
      ! test -e "$lnfrom" || test -L "$lnfrom"  && ln -sf --no-dereference "$lnto" "$lnfrom"
    '';
    scriptArgs = [ path link-cfg.target ];
  };

  # return all ancestors of this path.
  # e.g. ancestorsOf "/foo/bar/baz" => [ "/" "/foo" "/foo/bar" ]
  ancestorsOf = path: lib.init (path-lib.walk "/" path);

  # attrsOf fsEntry type which for every entry ensures that all ancestor entries are created.
  # we do this with a custom type to ensure that users can access `config.sane.fs."/parent/path"`
  # when inferred.
  fsTree = let
    baseType = types.attrsOf fsEntry;
    # merge is called once, with all collected `sane.fs` definitions passed and we coalesce those
    # into a single value `x` as if the user had wrote simply `sane.fs = x` in a single location.
    # so option defaulting and such happens *after* `merge` is called.
    merge = loc: defs: let
      # loc is the location of the option holding this type, e.g. ["sane" "fs"].
      # each def is an { value = attrsOf fsEntry instance; file = "..."; }
      pathsForDef = def: attrNames def.value;
      origPaths = concatLists (builtins.map pathsForDef defs);
      extraPaths = concatLists (builtins.map ancestorsOf origPaths);
      extraDefs = builtins.map (p: {
        file = ./.;
        value = {
          "${p}".dir = {};
        };
      }) extraPaths;
    in
      baseType.merge loc (defs ++ extraDefs);
  in
    lib.mkOptionType {
      inherit merge;
      name = "fsTree";
      description = "attrset representation of a file-system tree";
      # ensure that every path is in canonical form, else we might get duplicates and subtle errors
      check = tree: builtins.all (p: p == path-lib.norm p) (builtins.attrNames tree);
    };

in {
  options = {
    sane.fs = mkOption {
      # type = types.attrsOf fsEntry;
      # TODO: can we use `types.lazyAttrsOf fsEntry`??
      # - this exists specifically to let attrs reference eachother
      type = fsTree;
      default = {};
    };
  };

  config =
    let
      configs = lib.mapAttrsToList mkFsConfig cfg;
      take = f: {
        systemd.services = f.systemd.services;
        fileSystems = f.fileSystems;
      };
    in take (sane-lib.mkTypedMerge take configs);
}
