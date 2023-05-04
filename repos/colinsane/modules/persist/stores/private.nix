{ config, lib, pkgs, sane-lib, utils, ... }:

let
  persist-base = config.sane.persist.stores."plaintext".origin;
  private-dir = config.sane.persist.stores."private".origin;
  private-backing-dir = sane-lib.path.concat [ persist-base private-dir ];
in
lib.mkIf config.sane.persist.enable
{
  sane.persist.stores."private" = {
    storeDescription = ''
      encrypted store which persists across boots.
      typical use case is for the user to encrypt this store using their login password so that it
      can be auto-unlocked at login.
    '';
    origin = lib.mkDefault "/mnt/private";
    defaultOrdering = let
      private-unit = config.sane.fs."${private-dir}".unit;
    in {
      # auto create only after the store is mounted
      wantedBy = [ private-unit ];
      # we can't create things in private before local-fs.target
      wantedBeforeBy = [ ];
    };
    defaultMethod = "symlink";
  };

  fileSystems."${private-dir}" = {
    device = private-backing-dir;
    fsType = "fuse.gocryptfs";
    options = [
      "noauto"  # don't try to mount, until the user logs in!
      "nofail"
      "allow_other"  # root ends up being the user that mounts this, so need to make it visible to other users.
      "nodev"
      "nosuid"
      "quiet"
      "defaults"
    ];
    noCheck = true;
  };

  # let sane.fs know about the mount
  sane.fs."${private-dir}".mount = {};
  # it also needs to know that the underlying device is an ordinary folder
  sane.fs."${private-backing-dir}".dir = {};

  # TODO: could add this *specifically* to the .mount file for the encrypted fs?
  system.fsPackages = [ pkgs.gocryptfs ];  # fuse needs to find gocryptfs
}

