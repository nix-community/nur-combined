{ config, lib, ... }:
{
  sane.user.persist.byStore.plaintext = [
    # TODO: some of ~/dev should be private too, but maybe not all 800+ GB of it
    # perhaps i ought to rethink how it's organized
    "dev"
    "ref"
    "use"
    "Books/Audiobooks"
    "Books/Books"
    "Books/Visual"
    "Books/local"
    "Music"
  ];

  sane.user.persist.byStore.ephemeral = [
    # this is persisted simply to save on RAM. mesa_shader_cache is < 10 MB per boot.
  ];

  sane.user.persist.byStore.private = [
    "archive"
    "Pictures/albums"
    "Pictures/cat"
    "Pictures/from"
    "Pictures/Screenshots"  #< XXX: something is case-sensitive about this?
    "Pictures/Photos"
    "records"
    "tmp"

    "knowledge"
    "Videos/local"

    # TODO: pre-compile mesa shaders, and then run in read-only mode?
    # mesa shader cache can be configured with e.g.:
    # - MESA_SHADER_CACHE_DISABLE=true
    # - MESA_SHADER_CACHE_DIR=/path/to/cache_db
    # - MESA_DISK_CACHE_SINGLE_FILE=1  (in which case default cache file is ~/.cache/mesa_shader_cache_sf)
    # - MESA_DISK_CACHE_MULTI_FILE=1  (in which case default cache dir is ~/.cache/mesa_shader_cache)
    # - MESA_DISK_CACHE_READ_ONLY_FOZ_DBS=foo,bar
    #   - to use read-only mesa caches, one from foo.db the other bar.db
    # - MESA_DISK_CACHE_READ_ONLY_FOZ_DBS_DYNAMIC_LIST=/path/to/txt
    #   - where /path/to/txt contains a list of names which represent read-only caches
    #   - allows to change the cache providers w/o having to update variables
    #
    # see also: <https://github.com/ValveSoftware/Fossilize>
    #   which may help in generating readonly cache files
    #
    # for now, mesa shader cache is persisted because some programs *greatly* benefit from it.
    # esp gnome-contacts has a first-launch bug where it shows a misleading warning if shaders take too long to compile,
    # so we persist to private instead of ephemeral.
    ".cache/mesa_shader_cache_db"
  ];

  # convenience
  sane.user.fs = let
    persistEnabled = config.sane.persist.enable;
  in {
    ".persist/private" = lib.mkIf persistEnabled {
       symlink.target = "${config.sane.persist.stores.private.origin}/home/${config.sane.defaultUser}";
    };
    ".persist/plaintext" = lib.mkIf persistEnabled {
       symlink.target = "${config.sane.persist.stores.plaintext.origin}/home/${config.sane.defaultUser}";
    };
    ".persist/ephemeral" = lib.mkIf persistEnabled {
       symlink.target = "${config.sane.persist.stores.ephemeral.origin}/home/${config.sane.defaultUser}";
    };

    "nixos".symlink.target = "dev/nixos";

    "Books/servo".symlink.target = "/mnt/servo/media/Books";
    "Videos/servo".symlink.target = "/mnt/servo/media/Videos";
    "Pictures/servo-macros".symlink.target = "/mnt/servo/media/Pictures/macros";
  };
}
