{ config, lib, pkgs, sane-lib, utils, ... }:

let
  # TODO: parameterize!
  persist-base = "/nix/persist";
  origin = config.sane.persist.stores."private".origin;
  backing = sane-lib.path.concat [ persist-base "private" ];

  gocryptfs-private = pkgs.writeShellApplication {
    name = "mount.fuse.gocryptfs-private";
    runtimeInputs = with pkgs; [
      coreutils-full
      gocryptfs
      inotify-tools
    ];
    text = ''
      # backing=$1
      # facing=$2
      mountArgs=("$@")
      passdir=/run/gocryptfs
      passfile="$passdir/private.key"

      waitForPassfileOnce() {
        local timeout=$1
        if [ -f "$passfile" ]; then
          return 0
        else
          # wait for some file to be created inside the directory.
          # inotifywait returns 0 if the file was created. 1 or 2 if timeout was hit or it was interrupted by a different event.
          inotifywait --timeout "$timeout" --event create "$passdir"
          return 1  #< maybe it was created; we'll pick that up immediately, on next check
        fi
      }
      waitForPassfile() {
        # there's a race condition between testing the path and starting `inotifywait`.
        # therefore, use a retry loop. exponential backoff to decrease the impact of the race condition,
        # especially near the start of boot to allow for quick reboots even if/when i hit the race.
        for timeout in 4 4 8 8 8 8 16 16 16 16 16 16 16 16; do
          if waitForPassfileOnce "$timeout"; then
            return 0
          fi
        done
        while true; do
          if waitForPassfileOnce 30; then
            return 0
          fi
        done
      }
      tryOpenStore() {
        # try to open the store (blocking), if it fails, then delete the passfile because the user probably entered the wrong password
        echo "mounting with ''${mountArgs[*]}"
        # gocryptfs will unlock the store, and *then* fork into the background.
        # so when it returns, the files are either immediately accessible, or the mount failed (likely due to a bad password
        if ! gocryptfs "''${mountArgs[@]}"; then
          echo "failed mount (transient failure)"
          rm -f "$passfile"
          return 1
        fi
      }

      waitForPassfile
      while ! tryOpenStore; do
        waitForPassfile
      done
      echo "mounted"
      # mount is complete (successful), and backgrounded.
      # remove the passfile even on successful mount, for vague safety reasons (particularly if the user were to explicitly unmount the private store).
      rm -f "$passfile"
    '';
  };
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
    fsType = "fuse.gocryptfs-private";
    options = [
      "auto"
      "nofail"
      # "nodev"   # "Unknown parameter 'nodev'". gocryptfs requires this be passed as `-ko nodev`
      # "noexec"  # handful of scripts in ~/knowledge that are executable
      # "nosuid"  # "Unknown parameter 'nosuid'". gocryptfs requires this be passed as `-ko nosuid` (also nosuid is default)
      "allow_other"  # root ends up being the user that mounts this, so need to make it visible to other users.
      # "quiet"
      # "defaults"  # "unknown flag: --defaults. Try 'gocryptfs -help'"
      "passfile=/run/gocryptfs/private.key"
      # options so that we can block for the password file *without* systemd killing us.
      # see: <https://bbs.archlinux.org/viewtopic.php?pid=1906174#p1906174>
      "x-systemd.mount-timeout=infinity"
      # "retry=10000"
      # "fg"
    ];
    noCheck = true;
  };

  # let sane.fs know about the mount
  sane.fs."${origin}".mount = {};
  # it also needs to know that the underlying device is an ordinary folder
  sane.fs."${backing}" = sane-lib.fs.wanted {
    dir.acl.user = config.sane.defaultUser;
  };

  sane.fs."/run/gocryptfs" = sane-lib.fs.wanted {
    dir.acl.user = config.sane.defaultUser;
    dir.acl.mode = "0700";
  };

  # in order for non-systemd `mount` to work, the mount point has to already be created, so make that a default target
  systemd.units = let
    originUnit = config.sane.fs."${origin}".generated.unit;
  in {
    "${originUnit}".wantedBy = [ "local-fs.target" ];
  };

  system.fsPackages = [ gocryptfs-private ];

  sane.user.services.gocryptfs-private = {
    description = "wait for /mnt/persist/private to be mounted";
    startCommand = "${lib.getExe' pkgs.systemd "systemctl"} start mnt-persist-private.mount";
    # command = "sleep infinity";
    # readiness.waitExists = [ "/mnt/persist/private/init" ];
    partOf = [ "private-storage" ];
  };
}

