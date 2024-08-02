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

  systemd.mounts = let
    fsEntry = config.fileSystems."${origin}";
  in [{
    #VVV repeat what systemd would ordinarily scrape from /etc/fstab
    where = origin;
    what = fsEntry.device;
    type = fsEntry.fsType;
    options = lib.concatStringsSep "," fsEntry.options;

    # sandbox options
    mountConfig.AmbientCapabilities = "";
    # CAP_LEASE is probably not necessary -- does any fs user use leases?
    mountConfig.CapabilityBoundingSet = "CAP_SYS_ADMIN CAP_DAC_OVERRIDE CAP_DAC_READ_SEARCH CAP_CHOWN CAP_MKNOD CAP_LEASE CAP_SETGID CAP_SETUID CAP_FOWNER";
    mountConfig.LockPersonality = true;
    mountConfig.MemoryDenyWriteExecute = true;
    mountConfig.NoNewPrivileges = true;
    mountConfig.ProtectClock = true;
    mountConfig.ProtectHostname = true;
    mountConfig.RemoveIPC = true;
    mountConfig.RestrictAddressFamilies = "AF_UNIX";  # "none" works, but then it can't connect to the logger
    #VVV this includes anything it reads from, e.g. /bin/sh; /nix/store/...
    # see `systemd-analyze filesystems` for a full list
    mountConfig.RestrictFileSystems = "@common-block devtmpfs fuse pipefs";
    mountConfig.RestrictNamespaces = true;
    mountConfig.RestrictNetworkInterfaces = "";
    mountConfig.RestrictRealtime = true;
    mountConfig.RestrictSUIDSGID = true;
    mountConfig.SystemCallArchitectures = "native";
    mountConfig.SystemCallFilter = [
      # unfortunately, i need to keep @network-io (accept, bind, connect, listen, recv, send, socket, ...). not sure why (daemon control socket?).
      # TODO: @module?
      "@system-service" "@mount" "~@cpu-emulation" "~@keyring"
    ];
    # note that anything which requires mount namespaces (ProtectHome, ReadWritePaths, ...) does NOT work.
    # it's in theory possible, via mount propagation, but systemd provides no way for that.
    # PrivateNetwork = true  BREAKS the mount action; i think systemd or udev needs that internally to communicate with the service manager?
  }];

  system.fsPackages = [ gocryptfs-ephemeral ];  # fuse needs to find gocryptfs
}
