{ config, lib, ... }:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.abszero.i18n.inputMethod.fcitx5;
in

{
  options.abszero.i18n.inputMethod.fcitx5.enable =
    mkEnableOption "next-generation input method framework. Complementary to the NixOS module";

  # https://fcitx-im.org/wiki/Using_Fcitx_5_on_Wayland
  # Use fcitx im module for XWayland Gtk applications
  # Wayland Gtk applications will still use wayland im module
  config.gtk = mkIf cfg.enable {
    gtk3.extraConfig.gtk-im-module = "fcitx";
    gtk4.extraConfig.gtk-im-module = "fcitx";
  };
}
