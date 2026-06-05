# gvfs is used by e.g. nautilus to mount remote filesystems (ftp://, etc)
# and by several programs to open http://... URIs.
# - TODO: to add https:// support, add `glib-networking` to the gvfs environment
#
# N.B.: the security model here is **questionable**:
# - gvfs accepts a URI from an application, and then makes a network request to that URI.
#   in effect then, the application could issue totally arbitrary requests and exfiltrate data.
#   enabling this service grants any dbus application the ability to use the network.
# - i should probably **keep this disabled** until i can control who's allowed to use which dbus endpoints.
{ config, lib, ... }:
let
  cfg = config.sane.programs.gvfs;
in
{
  sane.programs.gvfs = {
    sandbox.net = "all";
    env.GIO_EXTRA_MODULES = "/etc/profiles/per-user/${config.sane.defaultUser}/lib/gio/modules:/run/current-system/sw/lib/gio/modules";

    services.gvfs-daemon = {
      description = "Gnome Virtual File System: allows glib programs to work with rich URIs";
      partOf = [ "graphical-session" ];
      command = "${lib.getLib cfg.package}/libexec/gvfsd";
    };
  };

  environment.pathsToLink = lib.mkIf cfg.enabled [ "/lib/gio/modules" ];
}
