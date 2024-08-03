{ config, lib, pkgs, sane-lib, utils, ... }:

let
  persist-base = "/nix/persist";
  origin = config.sane.persist.stores."private".origin;
  backing = sane-lib.path.concat [ persist-base "private" ];

  gocryptfs-private = pkgs.writeShellApplication {
    name = "gocryptfs-private";
    runtimeInputs = with pkgs; [
      coreutils-full
      gocryptfs
      inotify-tools
      util-linux  #< gocryptfs complains that it can't exec `logger`, otherwise
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
    device = "${lib.getExe gocryptfs-private}#${backing}";
    fsType = "fuse3";
    options = [
      # "auto"
      "nofail"
      # "noexec"  # handful of scripts in ~/knowledge that are executable
      "nodev"   # only works via mount.fuse; gocryptfs requires this be passed as `-ko nodev`
      "nosuid"  # only works via mount.fuse; gocryptfs requires this be passed as `-ko nosuid` (also, nosuid is default)
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
  sane.fs."${origin}" = {
    wantedBy = [ "local-fs.target" ];
    mount.depends = [
      config.sane.fs."${backing}".unit
      config.sane.fs."/run/gocryptfs".unit
    ];
    # unitConfig.DefaultDependencies = "no";
    mount.mountConfig.TimeoutSec = "infinity";

    # hardening (systemd-analyze security mnt-persist-private.mount)
    mount.mountConfig.AmbientCapabilities = "";
    # CAP_LEASE is probably not necessary -- does any fs user use leases?
    mount.mountConfig.CapabilityBoundingSet = "CAP_SYS_ADMIN CAP_DAC_OVERRIDE CAP_DAC_READ_SEARCH CAP_CHOWN CAP_MKNOD CAP_LEASE CAP_SETGID CAP_SETUID CAP_FOWNER";
    mount.mountConfig.LockPersonality = true;
    mount.mountConfig.MemoryDenyWriteExecute = true;
    mount.mountConfig.NoNewPrivileges = true;
    mount.mountConfig.ProtectClock = true;
    mount.mountConfig.ProtectHostname = true;
    mount.mountConfig.RemoveIPC = true;
    mount.mountConfig.RestrictAddressFamilies = "AF_UNIX";  # "none" works, but then it can't connect to the logger
    mount.mountConfig.RestrictFileSystems = "@common-block @basic-api fuse pipefs";
    mount.mountConfig.RestrictNamespaces = true;
    mount.mountConfig.RestrictNetworkInterfaces = "";
    mount.mountConfig.RestrictRealtime = true;
    mount.mountConfig.RestrictSUIDSGID = true;
    mount.mountConfig.SystemCallArchitectures = "native";
    mount.mountConfig.SystemCallFilter = [
      # unfortunately, i need to keep @network-io (accept, bind, connect, listen, recv, send, socket, ...). not sure why (daemon control socket?).
      "@system-service" "@mount" "~@cpu-emulation" "~@keyring"
    ];
    mount.mountConfig.IPAddressDeny = "any";
    mount.mountConfig.DevicePolicy = "closed";  # only allow /dev/{null,zero,full,random,urandom}
    mount.mountConfig.DeviceAllow = "/dev/fuse";
    mount.mountConfig.SocketBindDeny = "any";
  };
  # it also needs to know that the underlying device is an ordinary folder
  sane.fs."${backing}".dir.acl.user = config.sane.defaultUser;
  sane.fs."/run/gocryptfs".dir.acl = {
    user = config.sane.defaultUser;
    mode = "0700";
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

