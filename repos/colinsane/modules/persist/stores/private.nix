{ config, lib, pkgs, sane-lib, utils, ... }:

let
  # TODO: parameterize!
  persist-base = "/nix/persist";
  origin = config.sane.persist.stores."private".origin;
  backing = sane-lib.path.concat [ persist-base "private" ];
in
lib.mkIf config.sane.persist.enable
{
  sane.persist.stores."private" = {
    storeDescription = ''
      encrypted store which persists across boots.
      typical use case is for the user to encrypt this store using their login password so that it
      can be auto-unlocked at login.
    '';
    origin = lib.mkDefault "/mnt/persist/private";
    defaultOrdering = let
      private-unit = config.sane.fs."${origin}".unit;
    in {
      # auto create only after the store is mounted
      wantedBy = [ private-unit ];
      # we can't create things in private before local-fs.target
      wantedBeforeBy = [ ];
    };
    defaultMethod = "symlink";
  };

  fileSystems."${origin}" = {
    device = backing;
    fsType = "fuse.gocryptfs";
    options = [
      "noauto"  # don't try to mount, until the user logs in!
      "nofail"
      # "nodev"   # "Unknown parameter 'nodev'". gocryptfs requires this be passed as `-ko nodev`
      # "noexec"  # handful of scripts in ~/knowledge that are executable
      # "nosuid"  # "Unknown parameter 'nosuid'". gocryptfs requires this be passed as `-ko nosuid` (also nosuid is default)
      "allow_other"  # root ends up being the user that mounts this, so need to make it visible to other users.
      # "quiet"
      # "defaults"  # "unknown flag: --defaults. Try 'gocryptfs -help'"
    ];
    noCheck = true;
  };

  # let sane.fs know about the mount
  sane.fs."${origin}".mount = {};
  # it also needs to know that the underlying device is an ordinary folder
  sane.fs."${backing}" = sane-lib.fs.wantedDir;
  # in order for non-systemd `mount` to work, the mount point has to already be created, so make that a default target
  systemd.units = let
    originUnit = config.sane.fs."${origin}".generated.unit;
  in {
    "${originUnit}".wantedBy = [ "local-fs.target" ];
  };

  # TODO: could add this *specifically* to the .mount file for the encrypted fs?
  system.fsPackages = [ pkgs.gocryptfs ];  # fuse needs to find gocryptfs
}

