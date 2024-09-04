{ config, lib, pkgs, sane-lib, ... }:

let
  persist-base = "/nix/persist";
  origin = config.sane.persist.stores."private".origin;
  backing = sane-lib.path.concat [ persist-base "private" ];
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
    sandbox.method = "bwrap";
    sandbox.autodetectCliPaths = "parent";
  };
  sane.programs.gocryptfs-private = {
    packageUnwrapped = pkgs.static-nix-shell.mkBash {
      pname = "gocryptfs-private";
      srcRoot = ./.;
      pkgs = [ "gocryptfs" ];
    };
    sandbox.method = "landlock";
    sandbox.autodetectCliPaths = "existing";
    sandbox.capabilities = [
      # "sys_admin"  #< omitted: not required if using fuse3-sane with -o pass_fuse_fd
      "chown"
      "dac_override"
      "dac_read_search"
      "fowner"
      "lease"
      "mknod"
      "setgid"
      "setuid"
    ];
    sandbox.extraPaths = [
      "/run/gocryptfs"  #< TODO: teach sanebox about `-o FLAG1=VALUE1,FLAG2=VALUE2` style of argument passing, then use `existingOrParent` autodetect, and remove this
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
      "passfile=/run/gocryptfs/private.key"
      # options so that we can block for the password file *without* systemd killing us.
      # see: <https://bbs.archlinux.org/viewtopic.php?pid=1906174#p1906174>
      "x-systemd.mount-timeout=infinity"
      # "retry=10000"
      # "fg"
      "pass_fuse_fd"
    ];
    noCheck = true;
  };

  # let sane.fs know about the mount
  sane.fs."${origin}" = {
    wantedBy = [ "local-fs.target" ];
    mount.depends = [
      config.sane.fs."${backing}".unit
      config.sane.fs."/run/gocryptfs/private.key".unit
    ];
    # unitConfig.DefaultDependencies = "no";
    mount.mountConfig.TimeoutSec = "infinity";

    # hardening (systemd-analyze security mnt-persist-private.mount)
    mount.mountConfig.AmbientCapabilities = "CAP_SYS_ADMIN CAP_DAC_OVERRIDE CAP_DAC_READ_SEARCH CAP_CHOWN CAP_MKNOD CAP_LEASE CAP_SETGID CAP_SETUID CAP_FOWNER";
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
      "@system-service" "@mount" "@sandbox" "~@cpu-emulation" "~@keyring"
    ];
    mount.mountConfig.IPAddressDeny = "any";
    mount.mountConfig.DevicePolicy = "closed";  # only allow /dev/{null,zero,full,random,urandom}
    mount.mountConfig.DeviceAllow = "/dev/fuse";
    mount.mountConfig.SocketBindDeny = "any";
  };
  # it also needs to know that the underlying device is an ordinary folder
  sane.fs."${backing}".dir = {};
  sane.fs."/run/gocryptfs".dir.acl = {
    user = config.sane.defaultUser;  #< must be user-writable so i can unlock it.
    mode = "0770";
  };
  sane.fs."/run/gocryptfs/private.key".generated.command = [
    "${lib.getExe config.sane.programs.provision-private-key.package}"
    "/run/gocryptfs/private.key"
    "${backing}/gocryptfs.conf"
  ];

  sane.programs."gocryptfs-private".enableFor.system = true;
  sane.programs."provision-private-key".enableFor.system = true;
  system.fsPackages = [ pkgs.libfuse-sane ];

  sane.user.services.gocryptfs-private = {
    description = "wait for /mnt/persist/private to be mounted";
    startCommand = "${lib.getExe' pkgs.systemd "systemctl"} start mnt-persist-private.mount";
    # command = "sleep infinity";
    # readiness.waitExists = [ "/mnt/persist/private/init" ];
    partOf = [ "private-storage" ];
  };
}

