{ config, lib, pkgs, sane-lib, ... }:
with lib;
let
  path-lib = sane-lib.path;
  sane-types = sane-lib.types;
  cfg = config.sane.fs;

  aclOptions = {
    options = {
      acl = mkOption {
        type = sane-types.aclOverride;
        default = {};
      };
    };
  };

  # sane.fs."<path>" top-level options
  fsEntry = types.submodule ({ name, config, ...}: let
    parent = path-lib.parent name;
    has-parent = path-lib.hasParent name;
    parent-cfg = if has-parent then cfg."${parent}" else {};
    parent-acl = if has-parent then parent-cfg.acl else {};
  in {
    options = {
      inherit (aclOptions.options) acl;
      dir = mkOption {
        type = types.nullOr dirEntry;
        default = null;
      };
      file = mkOption {
        type = types.nullOr (fileEntryFor name);
        default = null;
      };
      symlink = mkOption {
        type = types.nullOr (symlinkEntryFor name);
        default = null;
      };
      mount = mkOption {
        type = types.nullOr (mountEntryFor name);
        default = null;
      };
    };
    config = let
      default-acl = {
        user = lib.mkDefault (parent-acl.user or "root");
        group = lib.mkDefault (parent-acl.group or "root");
        mode = lib.mkDefault (parent-acl.mode or "0755");
      };
    in {
      # populate acl from `dir.acl` or `symlinks.acl` shorthands
      # TODO: is this better achieved via `apply`?
      acl = lib.mkMerge [
        default-acl
        (lib.mkIf (config.dir != null)
          (sane-lib.filterNonNull config.dir.acl))
        (lib.mkIf (config.file != null)
          (sane-lib.filterNonNull config.file.acl))
        (lib.mkIf (config.symlink != null)
          (sane-lib.filterNonNull config.symlink.acl))
      ];

      # if we were asked to mount, make sure we create the dir that we mount over
      dir = lib.mkIf (config.mount != null) {};
    };
  });


  # sane.fs."<path>".dir sub-options
  # takes no special options
  dirEntry = types.submodule aclOptions;

  fileEntryFor = path: types.submodule ({ config, ... }: {
    options = {
      inherit (aclOptions.options) acl;
      text = mkOption {
        type = types.nullOr types.lines;
        default = null;
        description = "create a file with this text, overwriting anything that was there before.";
      };
      copyFrom = mkOption {
        type = types.coercedTo types.package toString types.str;
        description = "populate the file based on the content at this provided path";
      };
    };
    config = {
      copyFrom = lib.mkIf (config.text != null) (
        pkgs.writeText (path-lib.leaf path) config.text
      );
    };
  });

  symlinkEntryFor = path: types.submodule ({ config, ... }: {
    options = {
      inherit (aclOptions.options) acl;
      target = mkOption {
        # N.B.: `"${p}"` instead of `toString p` is critical in that it only evaluates if `p` is a path to an actual fs entry
        type = types.coercedTo types.path (p: "${p}")
          (types.coercedTo types.package toString types.str);
        description = "fs path to link to";
      };
      text = mkOption {
        type = types.nullOr types.lines;
        default = null;
        description = "create a file in the /nix/store with the provided text and use that as the target";
      };
    };
    config = let
      name = path-lib.leaf path;
    in {
      target = lib.mkIf (config.text != null) (
        (pkgs.writeTextFile {
          inherit name;
          text = config.text;
          destination = "/${name}";
        }) + "/${name}"
      );
    };
  });

  # sane.fs."<path>".mount sub-options
  mountEntryFor = path: types.submodule {
    options = {
      bind = mkOption {
        type = types.str;
        description = "fs path to bind-mount from";
        default = null;
      };
    };
  };

  # given a mountEntry definition, evaluate its toplevel `config` output.
  mkMountConfig = path: opt: {
    # create the mount point, with desired acl
    systemd.tmpfiles.settings."00-10-sane-fs"."${path}".d = opt.acl;
    fileSystems."${path}" = {
      device = opt.mount.bind;
      options = [
        "bind"
        # noauto: removes implicit `WantedBy=local-fs.target`
        # nofail: removes implicit `Before=local-fs.target` and turns `RequiredBy=local-fs.target` into `WantedBy=local-fs.target`.
        # note that some services will try to write under the mountpoint without declaring `RequiresMountsFor=` on us.
        # systemd-tmpfiles.service is one such example.
        # so, we *prefer* to be ordered before `local-fs.target` (since everything pulls that in),
        # but we generally don't want to *fail* `local-fs.target`, since that breaks everything, even `ssh`
        # on the other hand, /mnt/persist/private can take an indeterminate amount of time to be mounted,
        # and if they block local-fs, that might block things like networking as well...
        # so don't even required `before=local-fs.target`
        # "noauto"
        "nofail"
        # x-systemd options documented here:
        # - <https://www.freedesktop.org/software/systemd/man/systemd.mount.html>
        # "x-systemd.before=local-fs.target"
      ];
      noCheck = true;
    };
    # specify `systemd.mounts` because otherwise systemd doesn't seem to pick up my `x-systemd` fs options?
    # systemd.mounts = let
    #   fsEntry = config.fileSystems."${path}";
    # in [{
    #   where = path;
    #   what = if fsEntry.device != null then fsEntry.device else "";
    #   type = fsEntry.fsType;
    #   options = lib.concatStringsSep "," fsEntry.options;
    #   # before = [ "local-fs.target" ];
    # }];
  };

  mkDirConfig = path: opt: {
    systemd.tmpfiles.settings."00-10-sane-fs"."${path}".d = opt.acl;
  };
  mkFileConfig = path: opt: {
    # "C+" = copy and (hopefully?) overwrite whatever's already there
    systemd.tmpfiles.settings."00-10-sane-fs"."${path}"."C+" = opt.acl // {
      argument = opt.file.copyFrom;
    };
  };
  mkSymlinkConfig = path: opt: {
    # "L+" = symlink and overwrite whatever's already there
    systemd.tmpfiles.settings."00-10-sane-fs"."${path}"."L+" = opt.acl // {
      argument = opt.symlink.target;
    };
  };


  mkFsConfig = path: opt: lib.mkMerge (
    lib.optional (opt.mount != null) (mkMountConfig path opt)
    ++ lib.optional (opt.dir != null) (mkDirConfig path opt)
    ++ lib.optional (opt.file != null) (mkFileConfig path opt)
    ++ lib.optional (opt.symlink != null) (mkSymlinkConfig path opt)
  );

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
          "${p}" = lib.mkDefault {
            dir = {};
          };
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
        systemd.mounts = f.systemd.mounts;
        fileSystems = f.fileSystems;
        systemd.tmpfiles.settings."00-10-sane-fs" = f.systemd.tmpfiles.settings."00-10-sane-fs";
      };
    in take (sane-lib.mkTypedMerge take configs);
}
