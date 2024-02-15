{ config, lib, pkgs, ... }:

# Fix GNOME3 so it takes keyboard layouts set via services.xserver.extraLayouts
# into account.

{
  config = lib.mkIf (config.services.xserver.extraLayouts != { } &&
    # Fixed upstream, avoid overcorrecting
    # https://github.com/NixOS/nixpkgs/pull/76591
    builtins.compareVersions nixos.system.release "20.03" < 0) {

    # ideally this should be all we need once GNOME properly adopts libxkbcommon.
    environment.sessionVariables = {
      # xkb_patched is added by the extra-layouts module.
      XKB_CONFIG_ROOT = "${pkgs.xkb_patched}/etc/X11/xkb";
    };

    nixpkgs.overlays = lib.singleton (self: super:
      let
        gnome-desktop = super.gnome3.gnome-desktop.override {
          xkeyboard_config = self.xkb_patched;
        };
      in
      {
        gnome3 = super.gnome3 // {
          gnome-control-center = super.gnome3.gnome-control-center.override {
            inherit gnome-desktop;
          };
          gnome-session = super.gnome3.gnome-session.override {
            inherit (self) gnome3;
            inherit gnome-desktop;
          };
          gnome-shell = super.gnome3.gnome-shell.override {
            inherit gnome-desktop;
            gnome-clocks = self.gnome3.gnome-clocks.override {
              inherit gnome-desktop;
            };
            mutter = self.gnome3.mutter.override {
              inherit gnome-desktop;
            };
          };
        };
      });
  };
}
