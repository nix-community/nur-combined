# Avahi zeroconf (mDNS) implementation.
# runs as systemd `avahi-daemon.service`
#
# - <https://avahi.org/>
# - code: <https://github.com/avahi/avahi>
# - IRC: #avahi on irc.libera.chat
#
# - `avahi-browse --help` for usage
# - `man avahi-daemon.conf`
# - `LD_LIBRARY_PATH=/nix/store/ngwj3jqmxh8k4qji2z0lj7y1f8vzqrn2-nss-mdns-0.15.1/lib getent hosts desko.local`
#   nss-mdns goes through avahi-daemon, so there IS caching here
#
{ config, lib, pkgs, ... }:
{
  sane.programs.avahi = {
    packageUnwrapped = pkgs.avahi.overrideAttrs (upstream: {
      # avahi wants to do its own sandboxing opaque to systemd & maybe in conflict with my bwrap.
      # --no-drop-root disables that, so that i can e.g. run it as User=avahi, etc.
      # do this here, because the service isn't so easily patched.
      postInstall = (upstream.postInstall or "") + ''
        wrapProgram "$out/sbin/avahi-daemon" \
          --add-flags --no-drop-root
      '';
      nativeBuildInputs = upstream.nativeBuildInputs ++ [
        pkgs.makeBinaryWrapper
      ];
    });
    sandbox.method = "bwrap";
    sandbox.whitelistDbus = [ "system" ];
    sandbox.net = "all";  #< otherwise it will show 'null' in place of each interface name.
    sandbox.extraPaths = [
      "/"  #< TODO: decrease this, but be weary that the daemon might exit immediately
    ];
  };
  services.avahi = lib.mkIf config.sane.programs.avahi.enabled {
    enable = true;
    package = config.sane.programs.avahi.package;
    publish.enable = true;
    publish.userServices = true;
    nssmdns4 = true;
    nssmdns6 = true;
    # reflector = true;
    allowInterfaces = [
      # particularly, the default config disallows loopback, which is kinda fucking retarded, right?
      "ens1"  #< servo
      "enp5s0"  #< desko
      "eth0"
      "lo"
      "wg-home"
      "wlan0"  #< moby
      "wlp3s0"  #< lappy
      "wlp4s0"  #< desko
    ];
  };

  systemd.services.avahi-daemon = lib.mkIf config.sane.programs.avahi.enabled {
    # hardening: see `systemd-analyze security avahi-daemon`
    serviceConfig.User = "avahi";
    serviceConfig.Group = "avahi";
    serviceConfig.AmbientCapabilities = "";
    serviceConfig.CapabilityBoundingSet = "";
    serviceConfig.LockPersonality = true;
    serviceConfig.MemoryDenyWriteExecute = true;
    serviceConfig.NoNewPrivileges = true;
    serviceConfig.PrivateDevices = true;
    serviceConfig.PrivateMounts = true;
    serviceConfig.PrivateTmp = true;
    serviceConfig.PrivateUsers = true;
    serviceConfig.ProcSubset = "all";
    serviceConfig.ProtectClock = true;
    serviceConfig.ProtectControlGroups = true;
    serviceConfig.ProtectHome = true;
    serviceConfig.ProtectHostname = true;
    serviceConfig.ProtectKernelLogs = true;
    serviceConfig.ProtectKernelModules = true;
    serviceConfig.ProtectKernelTunables = true;
    serviceConfig.ProtectProc = "noaccess";
    serviceConfig.ProtectSystem = "strict";
    serviceConfig.RemoveIPC = true;  #< this *might* slow down the initial connection?
    serviceConfig.RestrictAddressFamilies = "AF_UNIX AF_INET AF_INET6 AF_NETLINK";
    serviceConfig.RestrictRealtime = true;
    serviceConfig.RestrictSUIDSGID = true;
    serviceConfig.SystemCallArchitectures = "native";
    serviceConfig.SystemCallFilter = [
      "@system-service"
      "@mount"
      "~@resources"
      # "~@privileged"
    ];
  };
}
