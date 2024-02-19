# strictly *decrease* the scope of the default nixos installation/config

{ lib, ... }:
{
  # remove all the non-existent default directories from XDG_DATA_DIRS, XDG_CONFIG_DIRS to simplify debugging.
  # this is defaulted in <repo:nixos/nixpkgs:nixos/modules/programs/environment.nix>,
  # without being gated by any higher config.
  environment.profiles = lib.mkForce [
    "/etc/profiles/per-user/$USER"
    "/run/current-system/sw"
  ];

  # NIXPKGS_CONFIG defaults to "/etc/nix/nixpkgs-config.nix", for idfk why.
  # that's never existed on my system and everything does fine without it set empty (no nixpkgs API to forcibly *unset* it).
  environment.variables.NIXPKGS_CONFIG = lib.mkForce "";
  # XDG_CONFIG_DIRS defaults to "/etc/xdg", which doesn't exist.
  # in practice, pam appends the values i want to XDG_CONFIG_DIRS, though this approach causes an extra leading `:`
  environment.sessionVariables.XDG_CONFIG_DIRS = lib.mkForce [];
  # XCURSOR_PATH: defaults to `[ "$HOME/.icons" "$HOME/.local/share/icons" ]`, neither of which i use, just adding noise.
  # see: <repo:nixos/nixpkgs:nixos/modules/config/xdg/icons.nix>
  environment.sessionVariables.XCURSOR_PATH = lib.mkForce [];

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
}
