{ config, lib, pkgs, sane-lib, ... }:

let
  persist-base = "/nix/persist";
  origin = config.sane.persist.stores."private".origin;
  backing = sane-lib.path.concat [ persist-base "private" ];

  # fileSystems.* options
  device = "gocryptfs-private#${backing}";
  fsType = "fuse3.sane";
  options = [
    # "auto"
    "nofail"
    # "noexec"  # handful of scripts in ~/knowledge that are executable
    "nodev"   # only works via mount.fuse; gocryptfs requires this be passed as `-ko nodev`
    "nosuid"  # only works via mount.fuse; gocryptfs requires this be passed as `-ko nosuid` (also, nosuid is default)
    "allow_other"  # root ends up being the user that mounts this, so need to make it visible to other users.
    # "quiet"
    # "defaults"  # "unknown flag: --defaults. Try 'gocryptfs -help'"
    # "passfile=/run/gocryptfs/private.key"
    # options so that we can block for the password file *without* systemd killing us.
    # see: <https://bbs.archlinux.org/viewtopic.php?pid=1906174#p1906174>
    # "x-systemd.mount-timeout=infinity"
    # "retry=10000"
    # "fg"
    "pass_fuse_fd"
  ];
in
lib.mkIf config.sane.persist.enable
{
  sane.programs."provision-private-key" = {
    packageUnwrapped = pkgs.static-nix-shell.mkBash {
      pname = "provision-private-key";
      srcRoot = ./.;
      pkgs = [
        "coreutils-full"
        "gocryptfs"
        "inotify-tools"
      ];
    };
    sandbox.autodetectCliPaths = "parent";
    # this is required if provision-private-key runs as a different user than the user who wrote `private.key` to disk.
    # e.g. if we're running as `root`, and `colin` wrote it with umask 027, then root can only read it if it keeps the user namespace.
    sandbox.tryKeepUsers = true;
    sandbox.capabilities = [ "dac_read_search" ];
  };
  sane.programs.gocryptfs-private = {
    packageUnwrapped = pkgs.static-nix-shell.mkBash {
      pname = "gocryptfs-private";
      srcRoot = ./.;
      pkgs = [ "gocryptfs" ];
    };
    sandbox.autodetectCliPaths = "existing";
    sandbox.capabilities = [
      "sys_admin"  #< XXX: this is required to keep user mappings; for single-user it's actually not necessary if using fuse3-sane with -o pass_fuse_fd
      "chown"
      "dac_override"
      "dac_read_search"
      "fowner"
      "lease"
      "mknod"
      "setgid"
      "setuid"
    ];
    sandbox.tryKeepUsers = true;
    sandbox.keepPids = true;
    sandbox.extraPaths = [
      "/run/gocryptfs/private.key"  #< TODO: teach sandbox about `-o FLAG1=VALUE1,FLAG2=VALUE2` style of argument passing, then use `existing` autodetect, and remove this
    ];
    suggestedPrograms = [ "gocryptfs" ];
  };

  sane.persist.stores."private" = {
    storeDescription = ''
      encrypted store which persists across boots.
      typical use case is for the user to encrypt this store using their login password so that it
      can be auto-unlocked at login.
    '';
    origin = lib.mkDefault "/mnt/persist/private";
    defaultMethod = "symlink";
  };

  fileSystems."${origin}" = {
    inherit device fsType options;
    noCheck = true;
  };

  # tell systemd about the mount so that i can sandbox it
  systemd.mounts = [{
    where = origin;
    what = device;
    type = fsType;
    options = lib.concatStringsSep "," options;
    after = [ "gocryptfs-private-key.service" ];
    wants = [ "gocryptfs-private-key.service" ];

    unitConfig.RequiresMountsFor = [ backing ];
    # unitConfig.DefaultDependencies = "no";
    # mountConfig.TimeoutSec = "infinity";

    # hardening (systemd-analyze security mnt-persist-private.mount)
    mountConfig.AmbientCapabilities = "CAP_SYS_ADMIN CAP_DAC_OVERRIDE CAP_DAC_READ_SEARCH CAP_CHOWN CAP_MKNOD CAP_LEASE CAP_SETGID CAP_SETUID CAP_FOWNER";
    # CAP_LEASE is probably not necessary -- does any fs user use leases?
    mountConfig.CapabilityBoundingSet = "CAP_SYS_ADMIN CAP_DAC_OVERRIDE CAP_DAC_READ_SEARCH CAP_CHOWN CAP_MKNOD CAP_LEASE CAP_SETGID CAP_SETUID CAP_FOWNER";
    mountConfig.LockPersonality = true;
    mountConfig.MemoryDenyWriteExecute = true;
    mountConfig.NoNewPrivileges = true;
    mountConfig.ProtectClock = true;
    mountConfig.ProtectHostname = true;
    mountConfig.RemoveIPC = true;
    mountConfig.RestrictAddressFamilies = "AF_UNIX";  # "none" works, but then it can't connect to the logger
    mountConfig.RestrictFileSystems = "@common-block @basic-api fuse pipefs";
    # mountConfig.RestrictNamespaces = true;
    mountConfig.RestrictNetworkInterfaces = "";
    mountConfig.RestrictRealtime = true;
    mountConfig.RestrictSUIDSGID = true;
    mountConfig.SystemCallArchitectures = "native";
    mountConfig.SystemCallFilter = [
      # unfortunately, i need to keep @network-io (accept, bind, connect, listen, recv, send, socket, ...). not sure why (daemon control socket?).
      "@system-service" "@mount" "@sandbox" "~@cpu-emulation" "~@keyring"
    ];
    mountConfig.IPAddressDeny = "any";
    mountConfig.DevicePolicy = "closed";  # only allow /dev/{null,zero,full,random,urandom}
    mountConfig.DeviceAllow = "/dev/fuse";
    mountConfig.SocketBindDeny = "any";
  }];
  # let sane.fs know about the mount
  sane.fs."${origin}" = { };
  # it also needs to know that the underlying device is an ordinary folder
  sane.fs."${backing}".dir = {};

  sane.programs."gocryptfs-private".enableFor.system = true;
  sane.programs."provision-private-key".enableFor.system = true;
  system.fsPackages = [ pkgs.libfuse-sane ];

  systemd.tmpfiles.settings."20-sane-persist-private"."/run/gocryptfs".d = {
    user = config.sane.defaultUser;  #< must be user-writable so i can unlock it.
    mode = "0770";
  };
  systemd.services.gocryptfs-private-key = {
    description = "wait for /run/gocryptfs/private.key to appear";
    serviceConfig.ExecStart = "${lib.getExe config.sane.programs.provision-private-key.package} /run/gocryptfs/private.key ${backing}/gocryptfs.conf";
    serviceConfig.Type = "oneshot";
  };

  sane.user.services.gocryptfs-private = {
    description = "wait for /mnt/persist/private to be mounted";
    startCommand = "${lib.getExe' pkgs.systemd "systemctl"} start mnt-persist-private.mount";
    # command = "sleep infinity";
    # readiness.waitExists = [ "/mnt/persist/private/init" ];
    partOf = [ "private-storage" ];
  };
}

