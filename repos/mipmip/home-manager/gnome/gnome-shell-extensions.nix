{ pkgs, config, ... }:


let
  mipmip_pkg = import (../../pkgs){};
in
  {
    home.packages = [
      mipmip_pkg.gnomeExtensions.gs-git
      mipmip_pkg.gnomeExtensions.vitals
    ];

#    dconf.settings = {
#      "org/gnome/shell" = {
#        disable-user-extensions = false;
#
#        enabled-extensions = [
#          "user-theme@gnome-shell-extensions.gcampax.github.com"
#          "trayIconsReloaded@selfmade.pl"
#          "Vitals@CoreCoding.com"
#          "dash-to-panel@jderose9.github.com"
#          "sound-output-device-chooser@kgshank.net"
#          "space-bar@luchrioh"
#        ];
#      };
#    };


  }
