{ config, lib, pkgs, sane-lib, utils, ... }:

let
  persist-base = "/nix/persist";
  origin = config.sane.persist.stores."ephemeral".origin;
  backing = sane-lib.path.concat [ persist-base "ephemeral" ];

  gocryptfs-ephemeral = pkgs.writeShellApplication {
    name = "mount.fuse.gocryptfs-ephemeral";
    runtimeInputs = with pkgs; [
      coreutils-full
      gocryptfs
    ];
    text = ''
      # mount invokes us like this. not sure if that's a guarantee or not:
      # <exe> <device> <mountpt> -o <flags>
      backing=$1
      # facing=$2

      # backing might exist from the last boot, so wipe it:
      rm -fr "$backing"
      mkdir -p "$backing"

      # the password shows up in /proc/.../env, briefly.
      # that's inconsequential: we just care that it's not *persisted*.
      pw=$(dd if=/dev/random bs=128 count=1 | base64 --wrap=0)
      echo "$pw" | gocryptfs -quiet -passfile /dev/stdin -init "$backing"
      echo "$pw" | gocryptfs -quiet -passfile /dev/stdin "$@"
    '';
  };
in
lib.mkIf config.sane.persist.enable
{
  sane.persist.stores."ephemeral" = {
    storeDescription = ''
      stored to disk, but encrypted to an in-memory key and cleared on every boot
      so that it's unreadable after power-off
    '';
    origin = lib.mkDefault "/mnt/persist/ephemeral";
  };

  fileSystems."${origin}" = {
    device = backing;
    fsType = "fuse.gocryptfs-ephemeral";
    options = [
      # "nodev"   # "Unknown parameter 'nodev'". gocryptfs requires this be passed as `-ko nodev`
      # "nosuid"  # "Unknown parameter 'nosuid'". gocryptfs requires this be passed as `-ko nosuid` (also, nosuid is default)
      "allow_other"  # root ends up being the user that mounts this, so need to make it visible to other users.
      # "defaults"  # "unknown flag: --defaults. Try 'gocryptfs -help'"
    ];
    noCheck = true;
  };
  # let sane.fs know about our fileSystem and automatically add the appropriate dependencies
  sane.fs."${origin}".mount = { };
  sane.fs."${backing}" = sane-lib.fs.wantedDir;

  system.fsPackages = [ gocryptfs-ephemeral ];  # fuse needs to find gocryptfs
}
