{ config, lib, pkgs, ... }:
let
  cfg = config.sane.hal.static;
in
{
  options = {
    sane.hal.static.enable = (lib.mkEnableOption "tweaks required on a statically linked system") // {
      default = pkgs.stdenv.hostPlatform.isStatic;
    };
  };

  config = lib.mkIf cfg.enable {
    documentation.nixos.enable = false;  #< stack overflow when building nixos-configuration-reference-manpage -> man-paths -> man-cache

    hardware.enableAllFirmware = false;  # blocked on bluez -> pygobject, which fails eval when hasSharedLibraries == false

    networking.networkmanager.enable = false;  # blocked on networkmanager -> gobject-introspection, which fails eval when hasSharedLibraries == false
    # networking.networkmanager.package = null;
    users.groups.networkmanager = { gid = 57; };  #< `networking.networkmanager.enable` would normally provide this for us

    security.apparmor.enable = false;  # blocked on apparmor-utils -> pygobject, which fails eval when hasSharedLibraries == false

    sane.programs.alsa-utils.enableFor.user.colin = false;  # blocked on sdl3, which fails eval when hasSharedLibraries == false
    sane.programs.fftest.enableFor = { system = false; user.colin = false; };  # blocked on sdl3, which fails eval when hasSharedLibraries == false
    sane.programs.lpac.enableFor.user.colin = false;  # activates services.pcscd; blocked on pcscd-plugins -> ccid, which fails eval when hasSharedLibraries == false
    sane.programs.mercurial.enableFor.user.colin = false;  # blocked on tk, which fails eval when hasSharedLibraries == false
    sane.programs.nmcli.enableFor = { system = false; user.colin = false; };  # blocked on networkmanager -> gobject-introspection, which fails eval when hasSharedLibraries == false
    sane.programs.pulsemixer.enableFor.user.colin = false;  # fails eval when hasSharedLibraries == false
    sane.programs.python3-repl.enableFor.user.colin = false;  # blocked on python3Packages.scipy -> pythran, which fails eval when hasSharedLibraries == false
    sane.programs."sane-scripts.vpn".enableFor.user.colin = false;  # blocked on networkmanager -> gobject-introspection, which fails eval when hasSharedLibraries == false
    sane.programs.tcpdump.enableFor.system = false;  # blocked on bluez -> pygobject, which fails eval when hasSharedLibraries == false
  };
}
