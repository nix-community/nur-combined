# you can grab policies from a few packages:
# - `roddhjav-apparmor-rules` (etc/apparmor.d/profiles-*/$mainProgram)
# - `apparmor-profiles` (etc/apparmor.d)
# - `pname.apparmor` (for nix packages which explicitly ship apparmor rules)
#
# docs/examples for apparmor on nixos:
# - <https://hedgedoc.grimmauld.de/s/hWcvJEniW#>
#   - LordGrimmauld's first apparmor writeup; shows ways to use `security.apparmor.policies`
#   - links to OpenSuSE apparmor manual: https://documentation.suse.com/en-us/sles/12-SP5/html/SLES-all/part-apparmor.html>
# - <https://discourse.nixos.org/t/apparmor-on-nixos-roadmap/57217>
# - <https://git.grimmauld.de/Grimmauld/grimm-nixos-laptop/src/branch/main/hardening/apparmor/default.nix>
#   - mirrored, with README: <https://github.com/AaronVerDow/nix/tree/main/common/apparmor>
# - <https://gitlab.com/StillerHarpo/nixosconfiguration/-/blob/master/modules/apparmor.nix>
#
# LordGrimmauld says `alias` rules will be necessary for using FHS-based profiles from nixos,
# but i have yet to see that in practice (i expect `apparmorRulesFromClosure` is good enough for 80% of cases;
#   Grimmauld just overrides `<abstractions/base>` to give everything ro access to /nix/store/**/*)
# Grimmauld's tool for automating alias creation: <https://github.com/LordGrimmauld/aa-alias-manager/blob/main/README.md#installingmaking-use-of-aa-alias-manager>
{ config, lib, pkgs, ... }:
{
  security.apparmor.enable = lib.mkDefault true;
  # security.apparmor.killUnconfinedConfinables = true;

  environment.systemPackages = [
    # for `man 5 apparmor.d`
    pkgs.apparmor-parser
  ];

  # security.pam.services.sudo.enableAppArmor = true;
  # # security.pam.services.sshd.enableAppArmor = true;
  # security.pam.services.login.enableAppArmor = true;

  security.apparmor.policies."bin.ping".profile = ''
    include "${pkgs.iputils.apparmor}/bin.ping"
  '';
  security.apparmor.policies."bin.hostname".profile = ''
    # N.B.: i think this only works because `ldd hostname` has only ld-linux.so;
    # if it were to load other .so files i'd need to add `apparmorRulesFromClosure` here.
    @{bin}=${lib.getBin pkgs.net-tools}/bin
    include "${pkgs.roddhjav-apparmor-rules}/etc/apparmor.d/profiles-g-l/hostname"
  '';
  # @{exec_path}=${lib.getExe' pkgs.net-tools "hostname"}
  # @{bin}=${lib.getBin pkgs.net-tools}/bin
  # security.apparmor.includes."local/bin.ping" = "";

  # abstractions/nameservice includes abstractions/nss-systemd.
  # nss-systemd needs to invoke:
  # - libnss_mymachines.so (a.k.a "mymachines" in /etc/nsswitch.conf)
  # - libnss_myhostname.so (a.k.a "myhostname" in /etc/nsswitch.conf)
  #   -> reads /proc/sys/net/ipv6/conf/all/disable_ipv6 to decide whether to return IPv6 response (socket_ipv6_is_enabled)
  #      see with e.g. `ping $(hostname).`
  #      trailing . ensures it's not resolved by /etc/hosts; make sure to disable avahi-daemon else it'll be fielded by $(hostname).local.
  security.apparmor.includes."abstractions/nss-systemd" = ''
    include "${
      pkgs.apparmorRulesFromClosure { name = "systemd"; } [ pkgs.systemd ]
    }"
  '';

  # TODO: add this to nixpkgs:nixos/modules/security/apparmor/includes.nix
  #       upstream this by just including _all_ of `config.system.nssModules.list` in the apparmor closure?
  security.apparmor.includes."abstractions/nameservice-strict" = let
    etcRule = path:
      lib.optionalString
      (builtins.hasAttr path config.environment.etc)
      "${config.environment.etc.${path}.source} r,"
      ;
  in ''
    include "${pkgs.apparmor-profiles}/etc/apparmor.d/abstractions/nameservice-strict"
  '' + lib.optionalString (lib.elem pkgs.nssmdns config.system.nssModules.list) ''
    include "${
      pkgs.apparmorRulesFromClosure { name = "nssmdns"; } [ pkgs.nssmdns ]
    }"
  '' + lib.optionalString (lib.elem pkgs.tcb config.system.nssModules.list) ''
    include "${
      pkgs.apparmorRulesFromClosure { name = "tcb"; } [ pkgs.tcb ]
    }"
  '' + lib.concatMapStringsSep "\n" etcRule [
    "group"
    "host.conf"
    "hosts"
    "nsswitch.conf"
    "gai.conf"
    "passwd"
    "protocols"
    "resolv.conf"
    "services"
  ];
}
