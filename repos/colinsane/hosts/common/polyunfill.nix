# strictly *decrease* the scope of the default nixos installation/config

{ lib, ... }:
{
  # disable non-required packages like nano, perl, rsync, strace
  environment.defaultPackages = [];

  # remove all the non-existent default directories from XDG_DATA_DIRS, XDG_CONFIG_DIRS to simplify debugging.
  # this is defaulted in <repo:nixos/nixpkgs:nixos/modules/programs/environment.nix>,
  # without being gated by any higher config.
  environment.profiles = lib.mkForce [
    "/etc/profiles/per-user/$USER"
    "/run/current-system/sw"
  ];

  # NIXPKGS_CONFIG defaults to "/etc/nix/nixpkgs-config.nix" in <nixos/modules/programs/environment.nix>.
  # that's never existed on my system and everything does fine without it set empty (no nixpkgs API to forcibly *unset* it).
  environment.variables.NIXPKGS_CONFIG = lib.mkForce "";
  # XDG_CONFIG_DIRS defaults to "/etc/xdg", which doesn't exist.
  # in practice, pam appends the values i want to XDG_CONFIG_DIRS, though this approach causes an extra leading `:`
  environment.sessionVariables.XDG_CONFIG_DIRS = lib.mkForce [];
  # XCURSOR_PATH: defaults to `[ "$HOME/.icons" "$HOME/.local/share/icons" ]`, neither of which i use, just adding noise.
  # see: <repo:nixos/nixpkgs:nixos/modules/config/xdg/icons.nix>
  environment.sessionVariables.XCURSOR_PATH = lib.mkForce [];

  # disable nixos' portal module, otherwise /share/applications gets linked into the system and complicates things (sandboxing).
  # instead, i manage portals myself via the sane.programs API (e.g. sane.programs.xdg-desktop-portal).
  xdg.portal.enable = false;
  xdg.menus.enable = false;  #< links /share/applications, and a bunch of other empty (i.e. unused) dirs

  # xdg.autostart.enable defaults to true, and links /etc/xdg/autostart into the environment, populated with .desktop files.
  # see: <repo:nixos/nixpkgs:nixos/modules/config/xdg/autostart.nix>
  # .desktop files are a questionable way to autostart things: i generally prefer a service manager for that.
  xdg.autostart.enable = false;

  # nix.channel.enable: populates `/nix/var/nix/profiles/per-user/root/channels`, `/root/.nix-channels`, `$HOME/.nix-defexpr/channels`
  #   <repo:nixos/nixpkgs:nixos/modules/config/nix-channel.nix>
  # TODO: may want to recreate NIX_PATH, nix.settings.nix-path
  nix.channel.enable = false;

  # environment.stub-ld: populate /lib/ld-linux.so with an object that unconditionally errors on launch,
  # so as to inform when trying to run a non-nixos binary?
  # IMO that's confusing: i thought /lib/ld-linux.so was some file actually required by nix.
  environment.stub-ld.enable = false;

  # `less.enable` sets LESSKEYIN_SYSTEM, LESSOPEN, LESSCLOSE env vars, which does confusing "lesspipe" things, so disable that.
  # it's enabled by default from `<nixos/modules/programs/environment.nix>`, who also sets `PAGER="less"` and `EDITOR="nano"` (keep).
  programs.less.enable = lib.mkForce false;
  environment.variables.PAGER = lib.mkOverride 900 "";  # mkDefault sets 1000. non-override is 100. 900 will beat the nixpkgs `mkDefault` but not anyone else.
  environment.variables.EDITOR = lib.mkOverride 900 "";

  # several packages (dconf, modemmanager, networkmanager, gvfs, polkit, udisks, bluez/blueman, feedbackd, etc)
  # will add themselves to the dbus search path.
  # i prefer dbus to only search XDG paths (/share/dbus-1) for service files, as that's more introspectable.
  # see: <repo:nixos/nixpkgs:nixos/modules/services/system/dbus.nix>
  # TODO: sandbox dbus? i pretty explicitly don't want to use it as a launcher.
  services.dbus.packages = lib.mkForce [
    "/run/current-system/sw"
    # config.system.path
    # pkgs.dbus
    # pkgs.polkit.out
    # pkgs.modemmanager
    # pkgs.networkmanager
    # pkgs.udisks
    # pkgs.wpa_supplicant
  ];

  # systemd by default forces shitty defaults for e.g. /tmp/.X11-unix.
  # nixos propagates those in: <nixos/modules/system/boot/systemd/tmpfiles.nix>
  # by overwriting this with an empty file, we can effectively remove it.
  environment.etc."tmpfiles.d/x11.conf".text = "# (removed by Colin)";
}
